--------------------------------------------------------
--  DDL for Package Body PA_REPORT_TYPES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REPORT_TYPES_UTILS" as
/* $Header: PARTYPUB.pls 120.1 2005/08/19 17:02:40 mwasowic noship $ */

Procedure get_page_id_from_layout(p_init_msg_list IN VARCHAR2 := 'T',
                                  p_page_layout   IN VARCHAR2,
                                  x_page_id       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

Begin
  x_return_status := 'S';

  if nvl(p_init_msg_list,'T') = 'T' then
       fnd_msg_pub.initialize;
  end if;

  begin
      select page_id
        into x_page_id
        from pa_page_layouts
       where page_type_code = 'PPR'
         and page_name = p_page_layout
         and trunc(SYSDATE) between trunc(Start_Date_Active) and  nvl(trunc(End_Date_Active),trunc(SYSDATE));
  exception
       when no_data_found then
         x_return_status := 'E';
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_PAGE_LAYOUT_NAME_INV');
  end ;

End get_page_id_from_layout;

Procedure get_report_type_info( p_report_type_id   IN NUMBER,
                                x_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_msg_index_out        NUMBER;
Begin
  x_return_status := 'S';

  begin
      select name
        into x_name
        from pa_report_types
       where report_type_id = p_report_type_id;
  exception
       when no_data_found then
         x_return_status := 'E';
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_REPORT_NAME_INV');
  end ;
  x_msg_count := FND_MSG_PUB.Count_Msg;
  If x_msg_count = 1 then
     pa_interface_utils_pub.get_messages(p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  end if;

End get_report_type_info;

Function page_used_by_report_type (p_page_id  IN NUMBER) return varchar2 Is
  l_return_char   varchar2(1) := 'N';
begin
  select 'Y'
    into l_return_char
    from pa_report_types
   where page_id = p_page_id;

  return l_return_char;

exception when others then
  return 'N';
end;

END  PA_REPORT_TYPES_UTILS;


/
