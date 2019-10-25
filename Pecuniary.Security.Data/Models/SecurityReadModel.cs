using Newtonsoft.Json;
using Pecuniary.Security.Data.ViewModels;

namespace Pecuniary.Security.Data.Models
{
    public class SecurityReadModel : BaseReadModel
    {
        [JsonProperty("_source")]
        public SecuritySource Source { get; set; }
    }

    public class SecuritySource : ViewModel
    {
        public SecurityViewModel Security { get; set; }
    }
}