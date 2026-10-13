using Abp.AspNetCore.Mvc.Authorization;
using KiemTraGiuaKy.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace KiemTraGiuaKy.Web.Controllers;

[AbpMvcAuthorize]
public class HomeController : KiemTraGiuaKyControllerBase
{
    public ActionResult Index()
    {
        return View();
    }
}
