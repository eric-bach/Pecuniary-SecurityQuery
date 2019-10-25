using System;
using System.Threading;
using System.Threading.Tasks;
using EricBach.CQRS.QueryRepository;
using EricBach.LambdaLogger;
using MediatR;
using Newtonsoft.Json;
using Pecuniary.Security.Data.Models;
using Pecuniary.Security.Query.Queries;

namespace Pecuniary.Security.Query.QueryHandlers
{
    public class SecurityQueryHandlers : IRequestHandler<GetSecurityQuery, SecurityReadModel>
    {
        private readonly IReadRepository<SecurityReadModel> _repository;

        public SecurityQueryHandlers(IReadRepository<SecurityReadModel> repository)
        {
            _repository = repository ?? throw new InvalidOperationException("Repository is not initialized.");
        }

        public async Task<SecurityReadModel> Handle(GetSecurityQuery query, CancellationToken cancellationToken)
        {
            Logger.Log($"{nameof(GetSecurityQuery)} handler invoked");

            if (query == null)
                throw new ArgumentNullException(nameof(query));

            var response = await _repository.GetByIdAsync(query.Id);

            // Deserialize back to read model
            return JsonConvert.DeserializeObject<SecurityReadModel>(response);
        }
    }
}
