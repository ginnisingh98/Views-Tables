--------------------------------------------------------
--  DDL for Package Body OE_PC_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_CONC_REQUESTS" as
/* $Header: OEXPCRQB.pls 120.0 2005/05/31 23:37:04 appldev noship $ */

G_PKG_NAME	 constant varchar2(30) := 'OE_PC_Conc_Requests';

G_APPLSYS_SCHEMA		varchar2(30);

g_conc_mode			varchar2(1);


-------------------------------------
-- Local Procedure
-------------------------------------

-------------------------------------------------------------------------
PROCEDURE Put_Line
     (Text Varchar2)
IS
BEGIN

   if g_conc_mode is null then

     if nvl(fnd_profile.value('CONC_REQUEST_ID'),0) <> 0 then
          g_conc_mode := 'Y';
     else
          g_conc_mode := 'N';
     end if;

   end if;

   if g_conc_mode = 'Y' then
     FND_FILE.PUT_LINE( FND_FILE.LOG, Text);
   end if;

END Put_Line;

------------------------------------------------------------------------
PROCEDURE Init_Applsys_Schema
IS
l_app_info          BOOLEAN;
l_status            VARCHAR2(30);
l_industry          VARCHAR2(30);
BEGIN

     if g_applsys_schema is null then

      l_app_info := FND_INSTALLATION.GET_APP_INFO
         ('FND',l_status, l_industry, g_applsys_schema);

     end if;

END;

------------------------------------------------------------------------
PROCEDURE Create_Package_From_Buffer(
   p_buffer       long
  ,p_pkg_name		 varchar2
  ,p_is_pkg_body     varchar2
)
Is

  l_bufferLength    number;
  l_lengthToWrite   number;
  l_startIndex      number;
  l_breakIndex      number;
  l_line_number	number;
  n                 NUMBER := 0;
  CURSOR errors IS
     select line, text
     from user_errors
     where name = p_pkg_name
       and type = decode(p_is_pkg_body,'FALSE','PACKAGE',
                         'TRUE','PACKAGE BODY');

begin
   l_bufferLength   :=  length(p_buffer);
   l_lengthToWrite  := l_bufferLength;
   l_startIndex      := 1;

   l_line_number := 0;

   while (l_lengthToWrite  > 0) loop

      l_breakIndex      := instr(p_buffer, OE_PC_GLOBALS.NEWLINE,l_startIndex);

	 l_line_number := l_line_number + 1;

      ad_ddl.build_package(substr(p_buffer, l_startIndex, (l_breakIndex-l_startIndex)),
						l_line_number);
	 l_lengthToWrite := l_bufferLength - l_breakIndex;
      l_startIndex := l_breakIndex+1;


   end loop;

   if p_is_pkg_body = 'FALSE' then
     PUT_LINE('Create PACKAGE SPEC :'||
					p_pkg_name||' using AD_DDL');
   else
     PUT_LINE('Create PACKAGE BODY :'||
					p_pkg_name||' using AD_DDL');
   end if;

    ad_ddl.create_package
    (applsys_schema => g_applsys_schema
	,application_short_name	=> 'ONT'
	,package_name			=> p_pkg_name
	,is_package_body		=> p_is_pkg_body
	,lb					=> 1
	,ub					=> l_line_number);

    -- if there were any errors when creating this package, print out
    -- the errors in the log file
    FOR error IN errors LOOP
      if n= 0 then
        PUT_LINE('ERROR in creating PACKAGE :'||p_pkg_name);
     end if;
        PUT_LINE(
          'Line :'||error.line||' Error:'||substr(error.text,1,200));
        n := 1;
    END LOOP;

    -- if there was an error in compiling the package, raise
    -- an error
    if  n > 0 then
       RAISE FND_API.G_EXC_ERROR;
    end if;

End Create_Package_From_Buffer;

/*
-- BUG 2935346
-- This is an obsolete procedure. The code is now executed directly from
-- procedure Create_Validation_Packages procedure.
-------------------------------------
PROCEDURE Update_Validation_Pkgs_Table
( l_sql_stmt			VARCHAR2
)
IS
BEGIN

	PUT_LINE('Execute Control Tbl Insert/Update Script');

	EXECUTE IMMEDIATE l_sql_stmt;

END Update_Validation_Pkgs_Table;
*/

-------------------------------------
--  Create_Validation_Packages
--  Called by the concurrent program OEPCGEN
-------------------------------------
PROCEDURE Create_Validation_Packages
			(ERRBUF		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
			,RETCODE	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
			)
is
  l_pkg_name		varchar2(30);
  l_control_tbl_sql     varchar2(2000);
  l_pkg_spec		LONG;
  l_pkg_body 		LONG;
  l_return_status  	varchar2(1);
  l_msg_data            varchar2(255);
  l_msg_count           number;
  l_concReqId	      number;
  l_global_record_name  varchar2(61);
  -- SQL selects only the ones that needs to be generated (new) or regenerated.
  -- based on timestamping of the corresponding records
  -- Selective regeneration:
  --   to regenrate all the the packages again, one could delete all the records in
  --   OE_PC_VALIDATION_PKGS and run this procedure. To selectively generate
  --   validation for a specific validation tmplt or a record set, one could touch
  --   (update the last update date) of the corresponding records and run this
  --   procedure.
  CURSOR C_CR IS
  SELECT distinct
         ve.application_id,
         ve.application_short_name,
         ve.entity_id,
         ve.db_object_name,
         ve.entity_short_name,
         ve.entity_display_name,
         ve.validation_entity_id,
         ve.validation_db_object_name,
         ve.validation_entity_short_name,
         ve.VALIDATION_ENTITY_DISPLAY_NAME,
         vt.validation_tmplt_id,
         vt.validation_tmplt_short_name,
	    vt.validation_tmplt_display_name,
         rs.record_set_id,
         rs.record_set_short_name,
	    rs.record_set_display_name
  FROM   oe_pc_vtmplts_vl vt,
         oe_pc_rsets_vl rs,
         oe_pc_ventities_v ve
  WHERE  ve.validation_entity_id = vt.entity_id
  AND    vt.validation_type      <> 'API'
  AND    ve.validation_entity_id = rs.entity_id
  -- Fix bug 1260054: if validating entity <> validation entity,
  -- then generate packages only for the primary key record set
  AND    (ve.entity_id = ve.validation_entity_id
	    OR (ve.entity_id <> ve.validation_entity_id
		   AND rs.pk_record_set_flag = 'Y'))
  AND   (ve.entity_id, ve.validation_entity_id,
         vt.validation_tmplt_id, rs.record_set_id)
         NOT IN
            (SELECT vp.validating_entity_id, vp.validation_entity_id,
                    vp.validation_tmplt_id, vp.record_set_id
             FROM  OE_PC_VALIDATION_PKGS vp
             WHERE vp.validating_entity_id = ve.entity_id
             AND   vp.validation_entity_id = ve.validation_entity_id
             AND   vp.validation_tmplt_id  = vt.validation_tmplt_id
             AND   vp.record_set_id        = rs.record_set_id
             AND   vp.last_update_date     > vt.last_update_date
             AND   vp.last_update_date     > rs.last_update_date);
compile_file		VARCHAR2(100);
compile_block		VARCHAR2(200);
l_pkg_count		NUMBER;
begin

   Init_Applsys_Schema;

   --
   PUT_LINE(  'Create_Validation_Packages: BEGIN');
   --

   -- get the rules for which validation pkags need to be created
   l_pkg_count		:= 0;

   FOR pkg_rec IN C_CR LOOP

	 PUT_LINE(' ');
      PUT_LINE(  '-- Generating Stored Procedure for Record Set/Validation tmplt:-----');
      PUT_LINE(  'Entity : ' || pkg_rec.entity_display_name);
      PUT_LINE(  'Validation Entity : ' || pkg_rec.validation_entity_display_name);
      PUT_LINE(  'Validation Tmplt : ' || pkg_rec.validation_tmplt_display_name);
      PUT_LINE(  'Record Set  : ' || pkg_rec.record_set_display_name);

      l_global_record_name := 'OE_' || pkg_rec.entity_short_name || '_SECURITY.g_record';

      l_pkg_name := '';
      l_pkg_spec := '';
      l_pkg_body := '';
      l_control_tbl_sql := '';
      l_return_status := '';
      l_msg_data := '';
      l_msg_count := '';

      -- make the validation pkg PL/SQL and the update/inset SQL
      OE_PC_Constraints_Admin_Pvt.Make_Validation_Pkg(
                    p_entity_id                     => pkg_rec.entity_id
                    ,p_entity_short_name            => pkg_rec.entity_short_name
                    ,p_db_object_name               => pkg_rec.db_object_name
                    ,p_validation_entity_id         => pkg_rec.validation_entity_id
                    ,p_validation_entity_short_name => pkg_rec.validation_entity_short_name
                    ,p_validation_db_object_name    => pkg_rec.validation_db_object_name
                    ,p_validation_tmplt_id          => pkg_rec.validation_tmplt_id
                    ,p_validation_tmplt_short_name  => pkg_rec.validation_tmplt_short_name
                    ,p_record_set_id                => pkg_rec.record_set_id
                    ,p_record_set_short_name        => pkg_rec.record_set_short_name
                    ,p_global_record_name           => l_global_record_name
                    ,x_pkg_name                     => l_pkg_name
                    ,x_pkg_spec                     => l_pkg_spec
                    ,x_pkg_body                     => l_pkg_body
                    ,x_control_tbl_sql              => l_control_tbl_sql
                    ,x_return_status                => l_return_status
                    ,x_msg_data                     => l_msg_data
                    ,x_msg_count                    => l_msg_count);

      IF (l_return_status = fnd_api.G_RET_STS_SUCCESS)
      THEN

        PUT_LINE(  'Successfully generated Validation Package');

	   BEGIN

            Create_Package_From_Buffer(l_pkg_spec, l_pkg_name, 'FALSE');
            Create_Package_From_Buffer(l_pkg_body, l_pkg_name, 'TRUE');

            -- PUT_LINE(l_control_tbl_sql);

            -- BUG 2935346
            -- Execute control tbl sql using bind values.

            IF substr(l_control_tbl_sql,1,6) = 'INSERT' THEN

	       PUT_LINE('Execute Control Tbl Insert Script');
	       EXECUTE IMMEDIATE l_control_tbl_sql
                       USING pkg_rec.entity_id
                           , pkg_rec.validation_entity_id
                           , pkg_rec.validation_tmplt_id
                           , pkg_rec.record_set_id
                           , l_pkg_name
                           , l_pkg_name;

            ELSIF substr(l_control_tbl_sql,1,6) = 'UPDATE' THEN

	       PUT_LINE('Execute Control Tbl Update Script');
	       EXECUTE IMMEDIATE l_control_tbl_sql
                       USING pkg_rec.entity_id
                           , pkg_rec.validation_entity_id
                           , pkg_rec.validation_tmplt_id
                           , pkg_rec.record_set_id
                           , l_pkg_name;

            END IF;

	   -- Continue creating other validation pkgs even if there were errors
	   -- when creating this package
	   EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			NULL;
	   END;

      ELSE

	   FND_MSG_PUB.Count_And_Get(p_count	=> l_msg_count
				, p_data	=> l_msg_data);

        PUT_LINE(  'Error in Generating the Validation Package :'||l_msg_data);

      END IF;

   END LOOP;

  PUT_LINE(' ');
  PUT_LINE(  'Returning with SUCCESS');

  retcode := 0;

EXCEPTION
  when FND_API.G_EXC_ERROR then
	retcode := 2;
	errbuf := 'Please fix the error in the log file';
     PUT_LINE(
		'Please fix the errors in this log file and re-run the concurrent program.');
  when others then
	retcode := 2;
	errbuf := sqlerrm;
     PUT_LINE(
			'An Exception has occured. Returning with ERROR :'||sqlerrm);
END Create_Validation_Packages;


END OE_PC_Conc_Requests;

/
