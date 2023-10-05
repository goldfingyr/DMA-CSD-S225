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
        private string createTable = "CREATE TABLE \"Cars\" (\"Licensplate\" NCHAR(16) NOT NULL DEFAULT '''NULL''',\"Make\" NCHAR(128) NULL DEFAULT '''NULL''' ,\"Model\" NCHAR(128) NULL DEFAULT '''NULL''' ,\"Color\" NCHAR(128) NULL DEFAULT '''NULL''' ,PRIMARY KEY (\"Licensplate\"));";
        // GET: api/<CarsController>
        [HttpGet]
        public IActionResult Get()
        {
            using (var connection = new SqlConnection(System.Environment.GetEnvironmentVariable("ConnectionString")))
            {
                connection.Open();
                try
                {
                    return Ok(connection.Query<Car>("SELECT * FROM dbo.Cars").ToList());
                }
                catch
                {
                    connection.Execute(createTable);
                }
                return Ok(connection.Query<Car>("SELECT * FROM dbo.Cars").ToList());
            }
        }

        // GET api/<CarsController>/cm57812
        [HttpGet("{Licensplate}")]
        public IActionResult Get(string Licensplate)
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
