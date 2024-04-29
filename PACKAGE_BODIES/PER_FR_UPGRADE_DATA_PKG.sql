--------------------------------------------------------
--  DDL for Package Body PER_FR_UPGRADE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_UPGRADE_DATA_PKG" AS
/* $Header: perfrupd.pkb 115.5 2002/11/25 16:35:34 sfmorris noship $ */

g_package varchar2(30) := 'per_fr_upgrade_data_pkg';


------------------------------------------------------------------------
-- PROCEDURE WRITE_LOG
-- This PROCEDURE writes a text string to the concurrent manager log
------------------------------------------------------------------------
procedure write_log(p_message in varchar2)
is
   l_proc varchar2(72) := g_package||'.write_log';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   fnd_file.put_line(FND_FILE.LOG,substrb(p_message,1,1024));

   hr_utility.set_location('leaving '||l_proc,100);

exception when others then
   null;
end write_log;

------------------------------------------------------------------------
-- PROCEDURE WRITE_LOG_MESSAGE
-- This PROCEDURE is used to obtain a fnd message and write it out to
-- the concurrent manager log file.
-- The token parameters must be of the form 'TOKEN_NAME:TOKEN_VALUE' i.e.
-- If you want to set the value of a token called EMPLOYEE to 'Bill Smith'
-- the token parameter would be 'EMPLOYEE:Bill Smith'
------------------------------------------------------------------------
procedure write_log_message(p_message_name      in varchar2
                        ,p_token1       in varchar2
                        ,p_token2       in varchar2
                        ,p_token3       in varchar2)
is
   l_message varchar2(2000);
   l_token_name varchar2(20);
   l_token_value varchar2(80);
   l_colon_position number;
   l_proc varchar2(72) := g_package||'.write_log_message';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('.  Message Name: '||p_message_name,40);

   fnd_message.set_name('PER', p_message_name);

   if p_token1 is not null then
      /* Obtain token 1 name and value */
      l_colon_position := instr(p_token1,':');
      l_token_name  := substr(p_token1,1,l_colon_position-1);
      l_token_value := substr(p_token1,l_colon_position+1,length(p_token1));
      fnd_message.set_token(l_token_name, l_token_value);
      hr_utility.set_location('.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
   end if;

   if p_token2 is not null  then
      /* Obtain token 2 name and value */
      l_colon_position := instr(p_token2,':');
      l_token_name  := substr(p_token2,1,l_colon_position-1);
      l_token_value := substr(p_token2,l_colon_position+1,length(p_token2));
      fnd_message.set_token(l_token_name, l_token_value);
      hr_utility.set_location('.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
   end if;

   if p_token3 is not null then
      /* Obtain token 3 name and value */
      l_colon_position := instr(p_token3,':');
      l_token_name  := substr(p_token3,1,l_colon_position-1);
      l_token_value := substr(p_token3,l_colon_position+1,length(p_token3));
      fnd_message.set_token(l_token_name, l_token_value);
      hr_utility.set_location('.  Token3: '||l_token_name||'. Value: '||l_token_value,70);
   end if;

   l_message := fnd_message.get;

   fnd_file.put_line(FND_FILE.LOG,substrb(l_message,1,1024));

   hr_utility.set_location('leaving '||l_proc,100);

exception when others then
   null;
   hr_utility.set_location('error occured in:'||l_proc,200);
   hr_utility.set_location(sqlcode,210);
end write_log_message;


/*************************************************************
*  Function GET_TRANSLATION                                  *
*  This function gets the meaning for values that need to be *
*  tranlated before they are written to the log              *
*  Using the lookup NAME_TRANSLATIONS                        *
*************************************************************/
function get_translation(p_lookup_code in varchar2) return varchar2
IS
    l_proc varchar2(72) := g_package||'.get_translation';
    l_meaning hr_lookups.meaning%type := hr_general.decode_lookup(p_lookup_type => 'NAME_TRANSLATIONS'
                                                    ,p_lookup_code => p_lookup_code);
    --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   return l_meaning;

END get_translation;


/*******************************************************************
*  CHECK_LOOKUPS                                                   *
*  This function takes a french lookup type and a core lookup type *
*  It checks that any lookup codes in the french lookup exist in   *
*  the core lookup.  It takes into account active dates and        *
*  enabled_flag                                                    *
*  Return = 0 means OK                                             *
*  Return = 1 means an error occured.                             *
*******************************************************************/
function check_lookups(p_fr_lookup_type in varchar2,
                       p_core_lookup_type in varchar2) return number
IS
--
  /* Find which lookups are in the french lookup but not the core lookup
     Note: fnd_lookup_values is used for the source table as we need to check
           lookups for any dates.  hr_lookups only gets lookup at session date
           The destination table is hr_leg_lookups.  This is necessary as some
           APIs validate to this view and we need to ensure that the TAG column
           is taken into account.  This view obtains at session date, this is
           acceptable as the API will expect the lookups to be available on
           session date.  */
  cursor csr_missing_lookup
  IS
    select lup1.lookup_code
           ,lup1.meaning
    from fnd_lookup_values lup1
    where lup1.lookup_type = p_fr_lookup_type
    and NOT exists (select lup2.lookup_code
                  from hr_leg_lookups lup2
                 where lup2.lookup_type = p_core_lookup_type
                   and lup2.lookup_code = lup1.lookup_code
                   and lup2.enabled_flag = lup1.enabled_flag
                   and nvl(lup2.start_date_active,to_date('01010001','DDMMYYYY')) <= nvl(lup1.start_date_active,to_date('01010001','DDMMYYYY'))
                   and nvl(lup2.end_date_active,to_date('31124712','DDMMYYYY')) >= nvl(lup1.end_date_active,to_date('01010001','DDMMYYYY'))
               );
--
    l_counter number :=0;
    l_proc varchar2(72) := g_package||'.check_lookups';
    --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   write_log_message(p_message_name => 'PER_74988_STRT_CHK_LKP'
                     ,p_token1 => 'FR_LKP_TYPE:'||p_fr_lookup_type
                     ,p_token2 => 'CORE_LKP_TYPE:'||p_core_lookup_type);

   for l_lookup_rec in csr_missing_lookup LOOP
      --
      l_counter:= l_counter +1;
      write_log_message(p_message_name => 'PER_74989_MISS_LKP'
                    , p_token1 => 'LOOKUP_CODE:'||l_lookup_rec.lookup_code);
      --
   END LOOP;

   if l_counter =0 then   -- counter =0 means all lookups found
      write_log_message(p_message_name => 'PER_74990_END_CHK_LKP'
                     ,p_token1  => 'STATUS:'||get_translation('COMPLETE'));

   else   -- Otherwise some lookups were missing so error
      write_log_message(p_message_name => 'PER_74990_END_CHK_LKP'
                     ,p_token1  => 'STATUS:'||get_translation('ERROR'));
   end if;

   hr_utility.set_location('leaving '||l_proc,100);
   return l_counter;

end check_lookups;

/*******************************************************************
*  CHECK_DFS                                                       *
*  This function takes a DF and checks whether the Segment values  *
*  validate against the Value Set associated.                      *
*  Return = 0 means OK                                             *
*  Return = 1 means an error occured.                              *
*******************************************************************/
function check_dfs(p_df in varchar2) return number
IS
--
  /* Find which DF has required segments.*/
  cursor csr_required_df_seg(p_df varchar2, p_application_id number, p_table_id number)
  IS
  SELECT	g.descriptive_flex_context_code,
		g.end_user_column_name
	FROM fnd_descr_flex_column_usages g, fnd_columns c
	WHERE g.application_id = p_application_id
	  AND g.required_flag = 'Y'
	  AND g.descriptive_flexfield_name = p_df
	  AND g.enabled_flag = 'Y'
	  AND c.application_id = p_application_id
	  AND c.table_id = p_table_id
	  AND c.column_name = g.application_column_name
	ORDER BY g.descriptive_flex_context_code;

  cursor csr_user_df
  IS
  SELECT        t.table_id,
		df.application_id,
		df.context_required_flag,
		df.table_application_id,
		df.concatenated_segment_delimiter,
                df.description,
                df.form_context_prompt
	  FROM fnd_tables t, fnd_descriptive_flexs_vl df, fnd_application a
	  WHERE a.application_short_name = 'PER'
	  AND df.application_id = a.application_id
	  AND df.descriptive_flexfield_name = p_df
	  AND t.application_id = df.table_application_id
	  AND t.table_name = df.application_table_name;
--
    l_counter number :=0;
    l_proc varchar2(72) := g_package||'.check_dfs';
    l_table_id number := 0;
    l_df_title varchar2(240) := p_df;
    l_df_context_field varchar2(45);
    l_application_id number := 0;
    l_table_application_id number := 0;
    l_segment_delimiter varchar2(1) := '.';
    l_context_required_flag varchar2(1):= 'N';
--
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   Open csr_user_df;
   Fetch csr_user_df Into l_table_id, l_application_id, l_context_required_flag, l_table_application_id,l_segment_delimiter,l_df_title,l_df_context_field;

   IF csr_user_df%NOTFOUND THEN
      CLOSE csr_user_df;
      l_counter := 0;
      return l_counter;
   END IF;

   Close csr_user_df;

   write_log_message(p_message_name => 'PER_75005_STRT_CHK_DF'
                     ,p_token1 => 'DF:'||l_df_title);

   IF (l_context_required_flag = 'Y') THEN
      write_log_message(p_message_name => 'PER_75006_REQ_CTX'
                      , p_token1 => 'DF_CONTEXT_FIELD:'||l_df_context_field);
   END IF;

   for l_df_rec in csr_required_df_seg(p_df, l_application_id, l_table_id)  LOOP
      --
      l_counter:= l_counter +1;
      write_log_message(p_message_name => 'PER_75007_REQ_SEG'
                      , p_token1 => 'DF_CONTEXT_CODE:'||l_df_rec.descriptive_flex_context_code
                      , p_token2 => 'DF_SEGMENT:'||l_df_rec.end_user_column_name);
      --
   END LOOP;

   if l_counter =0 then   -- counter =0 means no required Segment found.
      write_log_message(p_message_name => 'PER_75008_END_CHK_DF'
                       ,p_token1  => 'STATUS:'||get_translation('COMPLETE'));

   else   -- Otherwise some required segments found so error
      write_log_message(p_message_name => 'PER_75008_END_CHK_DF'
                       ,p_token1  => 'STATUS:'||get_translation('ERROR'));
   end if;

   hr_utility.set_location('leaving '||l_proc,100);
   return l_counter;

end check_dfs;

/*****************************************************************************
*  This procedure is called from concurrent manager, and runs the correct    *
*  upgrade depending on which upgrade the user selected                      *
*  retcode = 0 for Status Normal                                             *
*  retcode = 1 for Status Warning                                            *
*  retcode = 2 for Status Error                                              *
*****************************************************************************/
Procedure run_upgrade(errbuf          OUT NOCOPY VARCHAR2
                 ,retcode             OUT NOCOPY NUMBER
                 ,p_business_group_id IN NUMBER
                 ,p_upgrade_type      IN VARCHAR2)
IS
   l_status number :=0;    /* Zero means upgrade OK. 1 means error */
   l_proc varchar2(72) := g_package||'.run_upgrade';
   --
   l_upg_type_meaning hr_lookups.meaning%type  := hr_general.decode_lookup(p_lookup_type => 'FR_DATA_UPGRADE_TYPES'
                                                             ,p_lookup_code => p_upgrade_type);
   --
begin

   --
   hr_utility.set_location('Entered '||l_proc,5);
   --
   write_log_message(p_message_name => 'PER_74987_DAT_UPG_PROC'
                                                    ,p_token1  => 'STATUS:'||get_translation('STARTING')
                                                    ,p_token2 => 'UPG_TYPE:'||l_upg_type_meaning);
   --
   if p_upgrade_type = 'DISABILITIES' then
      l_status := PER_FR_DISABILITY_UPG_PKG.run_upgrade(p_business_group_id => p_business_group_id);
   elsif p_upgrade_type = 'MEDICAL_EXAMS' then
       l_status := PER_FR_MEDICAL_EXAMS_UPG_PKG.run_upgrade(p_business_group_id => p_business_group_id);
   elsif p_upgrade_type = 'WORK_ACCIDENTS' then
       l_status := PER_FR_WORK_ACC_UPG_PKG.run_upgrade(p_business_group_id => p_business_group_id);
   elsif p_upgrade_type = 'TERMINATION' then
       l_status := PER_FR_TERMINATION_UPG_PKG.run_upgrade(p_business_group_id => p_business_group_id);
   else
       l_status := 2;
       -- This error should never happen.  therefore no translation required.
       write_log('Invalid Upgrade Type:'||p_upgrade_type);
   end if;
   --

   /* Zero means OK, 1 means warning, 2 means Error - Write out correct message to log */
   if l_status = 0 then
      write_log_message(p_message_name => 'PER_74987_DAT_UPG_PROC'
                                                    ,p_token1  => 'STATUS:'||get_translation('COMPLETE')
                                                    ,p_token2 => 'UPG_TYPE:'||l_upg_type_meaning);
   elsif l_status = 1 then /* Complete with Warnings */
      write_log_message(p_message_name => 'PER_74987_DAT_UPG_PROC'
                                                    ,p_token1  => 'STATUS:'||get_translation('COMP_WARN')
                                                    ,p_token2 => 'UPG_TYPE:'||l_upg_type_meaning);
   else  /*Status 2 - Error */
      write_log_message(p_message_name => 'PER_74987_DAT_UPG_PROC'
                                                    ,p_token1  => 'STATUS:'||get_translation('ERROR')
                                                    ,p_token2 => 'UPG_TYPE:'||l_upg_type_meaning);
   end if;


   retcode := l_status;
   hr_utility.set_location('leaving '||l_proc,100);

exception when others then
   write_log_message(p_message_name => 'PER_74991_DAT_UPG_FATAL'
                    ,p_token1  => 'STEP:10');
   write_log(sqlcode);
   write_log(sqlerrm);
   retcode := 2;   /* Fatal Error */

END run_upgrade;


END PER_FR_UPGRADE_DATA_PKG;

/
