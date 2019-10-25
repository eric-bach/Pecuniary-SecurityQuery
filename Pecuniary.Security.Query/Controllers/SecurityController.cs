using System;
using System.Threading.Tasks;
using EricBach.LambdaLogger;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Pecuniary.Security.Data.Models;
using Pecuniary.Security.Query.Queries;

namespace Pecuniary.Security.Query.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SecurityController : ControllerBase
    {
        private readonly IMediator _mediator;

        public SecurityController(IMediator mediator)
        {
            _mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
        }

        // GET api/security/5
        [HttpGet("{id}")]
        public async Task<ActionResult<SecurityReadModel>> GetAsync(Guid id)
        {
            Logger.Log($"Received {nameof(GetSecurityQuery)} for {id}");

            return await _mediator.Send(new GetSecurityQuery {Id = id});
        }
    }
}
