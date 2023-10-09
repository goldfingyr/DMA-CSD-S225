using CarAPI.Models;
using Dapper;
using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Net;

// Author: Karsten Jeppesen, UCN, 2023
// CarAPI is used to demonstrate the potential of a REST API
// The exercise suggested is building a total API which may be accessed
// from PostMan or possibly from another Razor based application
// Oc as Swagger is enabled that would be a possibility too.

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace CarAPI.Controllers
{
    [Route("apiV1/[controller]")]
    [ApiController]
    public class CarsController : ControllerBase
    {
        private string createTable = "CREATE TABLE Cars (Licensplate VARCHAR(16),Make VARCHAR(128),Model VARCHAR(128),Color VARCHAR(128),PRIMARY KEY (Licensplate))";
        // GET: api/Car
        /// <summary>
        /// Gets all cars in the table. Optional search arguments "make" and "color"
        /// </summary>
        /// <param name="make"> Optional search argument</param>
        /// <param name="color"> Optional search argument</param>
        /// <returns> List of Car</returns>
        //
        // Name of method is irrelevant. It is the routing that matters: [HttpGet]
        [HttpGet]
        public IActionResult Get(string? make="%", string? color="%")
        {
            using (var connection = new SqlConnection(System.Environment.GetEnvironmentVariable("ConnectionString")))
            {
                connection.Open();
                try
                {
                    return Ok(connection.Query<Car>("SELECT * FROM dbo.Cars WHERE Make LIKE @make AND Color LIKE @color", new
                    {
                        make = make,
                        color = color
                    }).ToList());
                }
                catch
                {
                    connection.Execute(createTable);
                }
                // This Query could be very simple as its function is to return an empty array.
                // The table just created most likely is .... empty
                return Ok(connection.Query<Car>("SELECT * FROM dbo.Cars WHERE Make LIKE @make AND Color LIKE @color", new
                {
                    make = make,
                    color = color
                }).ToList());
            }
        }

        // GET api/Cars/cm57812
        /// <summary>
        /// Get a car identified by its licensplate
        /// </summary>
        /// <param name="Licensplate"></param>
        /// <returns>Car</returns>
        //
        // Name of method is irrelevant. It is the routing that matters: [HttpGet("{Licensplate}")]
        [HttpGet("{Licensplate}")]
        public IActionResult GetByLicenceplate(string Licensplate)
        {
            using (var connection = new SqlConnection(System.Environment.GetEnvironmentVariable("ConnectionString")))
            {
                connection.Open();
                try
                {
                    return Ok(connection.Query<Car>("SELECT * FROM dbo.Cars WHERE Licensplate='" + Licensplate + "'"));
                }
                catch
                {
                    connection.Execute(createTable);
                }
                return Ok(connection.Query<Car>("SELECT * FROM dbo.Cars WHERE Licensplate='" + Licensplate + "'"));
            }
        }

        // POST api/<CarsController>
        [HttpPost]
        public void Post([FromBody] string value)
        {
        }

        // PUT api/<CarsController>/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/<CarsController>/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
