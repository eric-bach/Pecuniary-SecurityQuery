using System;
using MediatR;
using Pecuniary.Security.Data.Models;

namespace Pecuniary.Security.Query.Queries
{
    public class GetSecurityQuery : IRequest<SecurityReadModel>
    {
        public Guid Id { get; set; }
    }
}
