--------------------------------------------------------
--  DDL for Package Body PA_REPORT_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REPORT_TYPES_PUB" as
/* $Header: PARTYPPB.pls 120.1 2005/08/19 17:02:31 mwasowic noship $ */

PROCEDURE CREATE_REPORT_TYPE
(
 p_api_version                 IN NUMBER :=  1.0,
 p_init_msg_list               IN VARCHAR2 := 'T',
 p_commit                      IN VARCHAR2 := 'F',
 p_validate_only               IN VARCHAR2 := 'F',
 p_max_msg_count               IN NUMBER := 100,
 P_NAME                        IN VARCHAR2,
 P_PAGE_ID                     IN NUMBER,
 P_PAGE_LAYOUT                 IN VARCHAR2 := '^',
 P_OVERRIDE_PAGE_LAYOUT        IN VARCHAR2 := 'N',
 P_DESCRIPTION                 IN VARCHAR2 := '',
 P_GENERATION_METHOD           IN VARCHAR2 := '',
 P_START_DATE_ACTIVE           IN DATE := trunc(sysdate),
 P_END_DATE_ACTIVE             IN DATE := to_date(null),

 x_report_type_id              OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

  l_page_id        number;
  l_dummy          varchar2(1) := 'N';
  l_msg_index_out  number;
BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_REPORT_TYPES_PUB.Create_Report_Type');

  -- Initialize the return status to success
  x_return_status := 'S';

  if nvl(p_init_msg_list,'T') = 'T' then
       fnd_msg_pub.initialize;
  end if;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = 'T' THEN
    SAVEPOINT CREATE_REPORT_TYPE;
  END IF;

  -- check the mandatory report_name
  IF (p_name IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
		         ,p_msg_name       => 'PA_REPORT_NAME_INV');
    x_return_status := 'E';
  else
    begin
      select 'Y'
        into l_dummy
        from pa_report_types
       where upper(name) = upper(p_name);
      exception when no_data_found then
       null;
    end;
    if l_dummy = 'Y' then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REPORT_NAME_DUPLICATE');
       x_return_status := 'E';
    end if;
  End if;

  -- check the page id is not null
  IF (p_page_id IS NULL)THEN
    If (p_page_layout is null or p_page_layout = '^') then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
         		    ,p_msg_name       => 'PA_PAGE_LAYOUT_NAME_INV');
       x_return_status := 'E';
    else
       --- get page_id from page layout
    pa_report_Types_utils.get_page_id_from_layout(p_init_msg_list => 'F',
                            p_page_layout   => p_page_layout,
                            x_page_id       => l_page_id,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data);
    end if;
  else
    l_page_id := p_page_id;
  End If;

     -- check the end date and start date
  IF (p_end_date_active IS NOT NULL AND p_end_date_active < p_start_date_active) THEN
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_EFFECTIVE_ED_DATE_INV');
      x_return_status := 'E';
  End If;


    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
    End If;
    if (x_msg_count > 0) then
        x_return_status := 'E';
    end if;

     IF (p_validate_only <> 'T' AND x_return_status = 'S') then

	pa_report_types_pkg.Insert_Row
	  (
	   p_name                    => p_name,
	   p_page_id                 => l_page_id,
           p_override_page_layout    => p_override_page_layout,
	   p_description             => p_description,
	   p_generation_method       => p_generation_method,
	   p_start_date_active       => p_start_date_active,
	   p_end_date_active         => p_end_date_active,
	   x_report_type_id          => x_report_type_id,
           p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID,
           p_CREATED_BY              => FND_GLOBAL.USER_ID,
           p_LAST_UPDATE_LOGIN       => FND_GLOBAL.LOGIN_ID
	   );

     END IF;


     -- Commit if the flag is set and there is no error
     IF (p_commit = 'T' AND  x_return_status = 'S')THEN
	COMMIT;
     END IF;


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO CREATE_REPORT_TYPE;
        END IF;
        x_return_status := 'U' ;
        RAISE;  -- This is optional depending on the needs

END create_report_type;



PROCEDURE Update_Report_Type
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 100,
 P_REPORT_TYPE_ID              IN NUMBER,
 P_NAME                        IN VARCHAR2 := '^',
 P_PAGE_ID                     IN NUMBER   := -99,
 P_PAGE_LAYOUT                 IN VARCHAR2 := '^',
 P_OVERRIDE_PAGE_LAYOUT        IN VARCHAR2 := '^',
 P_DESCRIPTION                 IN VARCHAR2 := '^',
 P_GENERATION_METHOD           IN VARCHAR2 := '',
 P_START_DATE_ACTIVE           IN DATE     := TO_DATE('01/01/4712','DD/MM/YYYY'),
 P_END_DATE_ACTIVE             IN DATE     := TO_DATE('01/01/4712','DD/MM/YYYY'),
 P_RECORD_VERSION_NUMBER       IN NUMBER,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

  l_page_id           number;
  l_dummy             varchar2(1) := 'N';
  l_start_date_active date;
  l_end_date_active   date;
  l_created_by        number;
  l_msg_index_out     number;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_REPORT_TYPES_PUB.Update_Report_Type');

  -- Initialize the return status to success
  x_return_status := 'S';

  if nvl(p_init_msg_list,'T') = 'T' then
       fnd_msg_pub.initialize;
  end if;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = 'T' THEN
    SAVEPOINT UPDATE_REPORT_TYPE;
  END IF;

/*  -- check if the record is seeded or not
  begin
     select created_by
       into l_created_by
       from pa_report_Types
      where report_Type_id = p_report_type_id;
  exception when others then
      null;
  end;

  if (l_created_by = 1) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REPORT_TYPE_SEED');
    x_return_status := 'E';
    return;
  end if; */

  -- check the mandatory report_name
  IF (p_name IS NULL or p_name = '^') then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REPORT_NAME_INV');
    x_return_status := 'E';
  else
    begin
      select 'Y'
        into l_dummy
        from pa_report_types
       where upper(name) = upper(p_name)
         and report_type_id <> p_report_type_id;
      exception when no_data_found then
       null;
    end;
    if l_dummy = 'Y' then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REPORT_NAME_DUPLICATE');
       x_return_status := 'E';
    end if;
  End if;

  -- check the page id is not null
  IF (p_page_id IS NULL or p_page_id = -99)THEN
    If (p_page_layout is null or p_page_layout = '^') then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_PAGE_LAYOUT_NAME_INV');
       x_return_status := 'E';
    else
       --- get page_id from page layout
    pa_report_Types_utils.get_page_id_from_layout(p_init_msg_list => 'F',
                            p_page_layout   => p_page_layout,
                            x_page_id       => l_page_id,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data);
    end if;
  else
    l_page_id := p_page_id;
  End If;

     -- check the end date and start date
  If (p_start_date_active is null or p_start_date_active = TO_DATE('01/01/4712','DD/MM/YYYY'))  then
      l_start_date_active := trunc(sysdate);
  else
      l_start_date_active := p_start_date_active;
  end if;

  If (p_end_date_active is null or p_end_date_active = TO_DATE('01/01/4712','DD/MM/YYYY'))  then
      l_end_date_active := to_date(null);
  else
      l_end_date_active := p_end_date_active;
  end if;

  IF (l_end_date_active IS NOT NULL AND l_end_date_active < l_start_date_active) THEN
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_EFFECTIVE_ED_DATE_INV');
      x_return_status := 'E';
  End If;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
    End If;
    if (x_msg_count > 0) then
        x_return_status := 'E';
    end if;

     IF (p_validate_only <> 'T' AND x_return_status = 'S') then

        pa_report_types_pkg.Update_Row
          (
           p_name                    => p_name,
           p_page_id                 => l_page_id,
           p_override_page_layout    => p_override_page_layout,
           p_description             => p_description,
	   p_generation_method       => p_generation_method,
           p_start_date_active       => l_start_date_active,
           p_end_date_active         => l_end_date_active,
           p_report_type_id          => p_report_type_id,
           p_record_version_number   => p_record_version_number,
           p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID,
           p_LAST_UPDATE_LOGIN       => FND_GLOBAL.LOGIN_ID,
           x_return_status           => x_return_status
           );

     END IF;


     -- Commit if the flag is set and there is no error
     IF (p_commit = 'T' AND  x_return_status = 'S')THEN
        COMMIT;
     END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO UPDATE_REPORT_TYPE;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END update_report_type;



PROCEDURE Delete_Report_Type
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 100,

 p_report_type_id              IN NUMBER,
 p_record_version_number       IN NUMBER ,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

  l_dummy             varchar2(1) := 'N';
  l_created_by        number;
  l_msg_index_out     number;
BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_REPORT_TYPES_PUB.Delete_Report_Type');

  -- Initialize the return status to success
  x_return_status := 'S';

  if nvl(p_init_msg_list,'T') = 'T' then
       fnd_msg_pub.initialize;
  end if;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = 'T' THEN
    SAVEPOINT DELETE_REPORT_TYPE;
  END IF;

  -- check if the record is seeded or not
  begin
     select created_by
       into l_created_by
       from pa_report_Types
      where report_Type_id = p_report_type_id;
  exception when others then
      null;
  end;

  if (l_created_by = 1) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REPORT_TYPE_SEED');
    x_return_status := 'E';
    return;
  end if;

  begin
      select 'Y'
        into l_dummy
        from pa_object_page_layouts               ----pa_progress_report_vers
       where report_type_id = p_report_type_id;
      exception when no_data_found then
        null;
      when too_many_rows then
        l_dummy := 'Y';
  end;
  if (l_dummy = 'Y') then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_REPORT_TYPE_IN_USE');
      x_return_status := 'E';
  else
     if (p_validate_only <> 'T' and x_return_status = 'S') then
        pa_report_Types_pkg.delete_row(P_REPORT_TYPE_ID        => p_report_Type_id,
                                     P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
                                     x_return_status         => x_return_status);
     end if;
  end if;

  -- Commit if the flag is set and there is no error
  IF (p_commit = 'T' AND  x_return_status = 'S')THEN
      COMMIT;
  END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
    End If;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO DELETE_REPORT_TYPE;
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

END delete_report_type;

END  PA_REPORT_TYPES_PUB;


/
