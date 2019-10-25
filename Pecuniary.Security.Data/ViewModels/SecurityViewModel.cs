using System;
using Newtonsoft.Json;

namespace Pecuniary.Security.Data.ViewModels
{
    /// <summary>
    /// This has to match AccountViewModel in Pecuniary.ViewModels
    /// </summary>
    public class SecurityViewModel
    {
        [JsonProperty("Id")]
        public Guid SecurityId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string ExchangeTypeCode { get; set; }
    }
}
