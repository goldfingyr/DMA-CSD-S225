using CarAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Newtonsoft.Json;

namespace UI.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        [BindProperty]
        public string? CarSelected { get; set; }

        [BindProperty]
        public List<Car> Cars { get; set; }

        private void SetMyCookie(string carSelected)
        {
            HttpContext.Session.SetString("IndexCookie", JsonConvert.SerializeObject(carSelected));
        }


        private void GetMyCookie()
        {
            string? jsonString;
            try
            {
                jsonString = HttpContext.Session.GetString("IndexCookie");
            }
            catch {
                jsonString = null;
            }
            if (jsonString != null)
            {
                CarSelected = JsonConvert.DeserializeObject<string>(jsonString);
                return;
            } else
            {
                CarSelected = null;
            }
        }



        public string APIURI = "http://localhost:5285";
        public void OnGet()
        {
            GetMyCookie();
            if (CarSelected != null) {
                // Now use API
                HttpClient httpClient = new HttpClient();
                httpClient.BaseAddress = new Uri(APIURI);
                string result = httpClient.GetStringAsync("/apiV1/Cars/"+CarSelected).Result;

            }
        }

        public IActionResult OnPost(string action="NA", string target="NA")
        {
            switch (action)
            {
                case "findCar":
                    SetMyCookie(target);
                    return Redirect("/");
                    break;
                default:
                    break;
            }
            return null;
        }
    }
}