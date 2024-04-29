--------------------------------------------------------
--  DDL for Package Body PJI_MAP_ROWSET_MEASURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_MAP_ROWSET_MEASURE" as
-- $Header: PJIRWSTB.pls 120.1 2007/02/01 15:57:54 pschandr ship $

   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;

procedure insert_row
	(p_rowset_code           IN VARCHAR2,
	 p_name                  IN VARCHAR2,
	 p_description           IN VARCHAR2,
	 x_msg_count             IN OUT NOCOPY NUMBER,
	 x_return_status         OUT NOCOPY VARCHAR2,
	 x_err_msg_data          OUT NOCOPY VARCHAR2)
  IS

  NULL_VALUE            EXCEPTION;
  l_number              NUMBER(2);
  l_check               VARCHAR2(1);
  l_rowid               ROWID := NULL;
  l_return_status       VARCHAR2(100);
  l_msg_data            VARCHAR2(100);
  l_msg_count           NUMBER(10);

  BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_msg_count := 0;
       l_check := 'N';

	if p_rowset_code is NULL then
	     PA_UTILS.ADD_MESSAGE
	         (p_app_short_name => 'PJI',
		  p_msg_name       => 'PJI_ROWSET_CODE_NULL');
	     l_check:='Y';

	else
	    BEGIN
	       select 1 into l_number from PJI_MT_ROWSET_B
	       where rowset_code=p_rowset_code;

	       PA_UTILS.ADD_MESSAGE
	          (p_app_short_name => 'PJI',
		   p_msg_name       => 'PJI_ROWSET_CODE_UNIQUE');
	       l_check:='Y';

	    EXCEPTION
	    WHEN NO_DATA_FOUND then
	        null;
	    END;
        end if;

	 if p_name is NULL then
	     PA_UTILS.ADD_MESSAGE
	         (p_app_short_name => 'PJI',
		  p_msg_name       => 'PJI_ROWSET_NAME_NULL');
	     l_check:='Y';
	 end if;

	if l_check = 'Y' then
	raise NULL_VALUE;
	end if;

        pji_mt_rowset_pkg.Insert_Row(X_Rowid => l_rowid,
	                            X_rowset_Code => p_rowset_code,
				    X_Object_Version_Number => 1,
				    X_Name => p_name,
				    X_Description => p_description,
				    X_Last_Update_Date => g_last_update_date,
				    X_Last_Updated_By => g_last_updated_by,
				    X_Creation_Date => g_creation_date,
				    X_Created_By => g_created_by,
				    X_Last_Update_Login => g_last_update_login,
				    X_Return_Status => l_return_status,
				    X_Msg_Data => l_msg_data,
				    X_Msg_Count => l_msg_count);

   EXCEPTION
   WHEN NULL_VALUE then
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := x_msg_count + 1;
      pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Map_Rowset_Measure.insert_row');
   WHEN OTHERS THEN
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := x_msg_count + 1;
      pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Map_Rowset_Measure.insert_row');
       ROLLBACK;
       --return;
END insert_row;

procedure create_map
	(p_rowset_code               IN VARCHAR2,
	 p_measure_set_code_add_tb1  IN SYSTEM.pa_varchar2_30_tbl_type,
	 p_measure_set_code_del_tb1  IN SYSTEM.pa_varchar2_30_tbl_type,
	 p_object_version_number     IN NUMBER,
	 x_msg_count                 IN OUT NOCOPY NUMBER,
	 x_return_status             OUT NOCOPY VARCHAR2,
	 x_err_msg_data              OUT NOCOPY VARCHAR2)
  IS
	 l_display_order_tbl	SYSTEM.pa_num_tbl_type;
  BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_msg_count := 0;
	   --Bug 3798976. Lock the header table before operating on the details.
	   --p_object_version_number passed in corresponds to the OVN of the rowset table.
	   PJI_MT_ROWSET_PKG.LOCK_ROW(
				 p_rowset_code			 => p_rowset_code
				,p_object_version_number => p_object_version_number
	   );

	   --Bug 3798976. Delete all the detail records and populate with the new list
	   --with the correct order.
	   delete from pji_mt_rowset_det
	   where rowset_code = p_rowset_code;

	   l_display_order_tbl := SYSTEM.pa_num_tbl_type();

       if p_measure_set_code_add_tb1.count <> 0 then
		   l_display_order_tbl.extend(p_measure_set_code_add_tb1.count);
		   for i in 1..p_measure_set_code_add_tb1.count loop
				l_display_order_tbl(i) := i;
		   end loop;

	       forall i in p_measure_set_code_add_tb1.FIRST .. p_measure_set_code_add_tb1.LAST
		       insert into PJI_MT_ROWSET_DET(
			      ROWSET_CODE,
			      MEASURE_SET_CODE,
			      OBJECT_VERSION_NUMBER,
			      DISPLAY_ORDER,
			      CREATED_BY,
			      CREATION_DATE,
			      LAST_UPDATED_BY,
			      LAST_UPDATE_DATE,
			      LAST_UPDATE_LOGIN)
		       values
			   (p_rowset_code,
			    p_measure_set_code_add_tb1(i),
			    1,
				l_display_order_tbl(i),
			    g_created_by,
			    g_creation_date,
			    g_last_updated_by,
			    g_last_update_date,
			    g_last_update_login);
	end if;

        if p_measure_set_code_del_tb1.count <> 0 then
		forall i in p_measure_set_code_del_tb1.FIRST .. p_measure_set_code_del_tb1.LAST
			delete from PJI_MT_ROWSET_DET
			where rowset_code=p_rowset_code
			and measure_set_code=p_measure_set_code_del_tb1(i);
	end if;


   EXCEPTION
   WHEN OTHERS THEN
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := x_msg_count + 1;
       x_err_msg_data      := SQLERRM;
       ROLLBACK;
 END create_map;

procedure update_row
	(p_rowset_code           IN VARCHAR2,
	 p_name                  IN VARCHAR2,
	 p_description           IN VARCHAR2,
	 p_object_version_number IN NUMBER,
	 x_msg_count             IN OUT NOCOPY NUMBER,
	 x_return_status         OUT NOCOPY VARCHAR2,
	 x_err_msg_data          OUT NOCOPY VARCHAR2)
   IS

   NULL_VALUE    EXCEPTION;
   l_return_status       VARCHAR2(100);
   l_msg_data            VARCHAR2(100);
   l_msg_count           NUMBER(10);

   BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_msg_count := 0;

       if(p_name is NULL) then
	     PA_UTILS.ADD_MESSAGE
	         (p_app_short_name => 'PJI',
		  p_msg_name       => 'PJI_ROWSET_NAME_NULL');
	      raise NULL_VALUE;
       end if;

       pji_mt_rowset_pkg.update_row(x_rowset_code => p_rowset_code,
                                    x_object_version_number => p_object_version_number,
				    x_name =>  p_name,
				    x_description => p_description,
                                    x_last_update_date => g_last_update_date,
                                    X_Last_Updated_by => g_last_updated_by,
				    X_Last_Update_Login => g_last_update_login,
				    X_Return_Status => l_return_status,
				    X_Msg_Data => l_msg_data,
				    X_Msg_Count => l_msg_count);

    EXCEPTION
    WHEN NULL_VALUE THEN
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := x_msg_count + 1;
      pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Map_Rowset_Measure.update_row');
       RAISE;
    WHEN OTHERS THEN
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := x_msg_count + 1;
      pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Map_Rowset_Measure.update_row');
       ROLLBACK;
       RAISE;
END update_row;

procedure delete_row
	(p_rowset_code           IN VARCHAR2,
	 x_msg_count             IN OUT NOCOPY NUMBER,
	 x_return_status         OUT NOCOPY VARCHAR2,
	 x_err_msg_data          OUT NOCOPY VARCHAR2)
    IS

    BEGIN
         x_return_status :=  FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;

	 pji_mt_rowset_pkg.delete_row(p_rowset_code => p_rowset_code);

	 delete from pji_mt_rowset_det where rowset_code=p_rowset_code;

         EXCEPTION
	 WHEN OTHERS THEN
            x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := x_msg_count + 1;
          pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Map_Rowset_Measure.delete_row');
END delete_row;

end PJI_MAP_ROWSET_MEASURE;

/
