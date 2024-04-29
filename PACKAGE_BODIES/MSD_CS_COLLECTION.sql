--------------------------------------------------------
--  DDL for Package Body MSD_CS_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_COLLECTION" as
/* $Header: msdcsclb.pls 120.2.12010000.1 2008/05/15 07:09:28 lannapra ship $ */
    /*
       Constants
    */
    C_LOG_PROCESSED Constant varchar2(30) :='PROCESSED';
    C_LOG_ERROR     Constant varchar2(30) :='ERROR';
    C_DEFAULT_STREAM_NAME Constant varchar2(30) := 'SINGLE_STREAM';
    C_COLLECT             Constant varchar2(10)  := 'C';
    C_PULL                Constant varchar2(10)  := 'P';
    /* Debug */
    C_DEBUG               Constant varchar2(1) := 'N';
    /* Bug# 4349618  To commit in Batches */
    C_BATCH_SIZE          Constant NUMBER := 30000;
    /*
       Process Types
    */
    C_SOURCE_TO_STAGE Constant NUMBER := 1;
    C_SOURCE_TO_FACT  Constant NUMBER := 2;
    C_STAGE_TO_FACT   Constant NUMBER := 3;
    /*  == */
    g_level_pk_not_found    varchar2(30):='%%^^)(::Error::%%^^)(';
    /*  Error Status of prog */
    g_retcode   varchar2(30);
    g_errbuf    varchar2(255);
    /*                       */
    /*
    == Local Function/Procedures
    */

Procedure insert_update_Into_Headers (	p_cs_definition_id  in  number,
					p_cs_name           in  varchar2,
					p_instance_id       in  number,
                                        p_refresh_num       in  number);

Procedure Insert_Data_Into_Headers (  	p_cs_definition_id  in  number,
					p_cs_name           in  varchar2,
					p_instance_id       in  number,
                                        p_refresh_num       in  number);
Procedure Process_1_Sub (
        p_cs_rec         in out NOCOPY  msd_cs_definitions_v1%rowtype,
        p_cs_name           in  varchar2,
        p_source_view       in  varchar2,
        p_target_table      in  varchar2,
        p_instance_id       in  number,
        p_sql_stmt          in  varchar2,
        p_new_refresh_num   in  NUMBER);

    Function Build_SQL_Source(
        p_cs_definition_id in number,
        p_process_type     in number,
        p_instance_id      in varchar2,
        p_cs_name          in varchar2) return varchar2;

    Function Build_SQL_FOR_COLLECT_AND_VAL(
        p_cs_definition_id in number,
        p_process_type     in number,
        p_source_view      in varchar2,
        p_db_link          in varchar2,
        p_cs_name          in varchar2) return varchar2;

    Function Build_SQL_INS_AS_SELECT(
        p_cs_definition_id in number,
        p_instance_id      in varchar2,
        p_cs_name          in varchar2,
        p_source_view      in varchar2,
        p_db_link          in varchar2) return varchar2;

    Function Build_Where_Clause (
        p_tokenized_where   in  varchar2,
        p_default_where     in  varchar2,
        p_parameter1        in  varchar2,
        p_parameter2        in  varchar2,
        p_parameter3        in  varchar2,
        p_parameter4        in  varchar2,
        p_parameter5        in  varchar2,
        p_parameter6        in  varchar2,
        p_parameter7        in  varchar2,
        p_parameter8        in  varchar2,
        p_parameter9        in  varchar2,
        p_parameter10       in  varchar2,
        p_request_id        in  number) return varchar2;

    Procedure log_processed (
        crec_data in msd_cs_dfn_utl.g_typ_source_stream,
        p_cs_rec        in msd_cs_definitions_v1%rowtype,
        p_cs_name       in varchar2,
        p_instance_id   in varchar2,
        p_source_view   in varchar2,
        p_target_table  in varchar2);

    Procedure log_error (
        crec_data in msd_cs_dfn_utl.g_typ_source_stream,
        p_cs_rec        in msd_cs_definitions_v1%rowtype,
        p_cs_name       in varchar2,
        p_instance_id   in varchar2,
        p_error_message in varchar2,
        p_source_view   in varchar2,
        p_target_table  in varchar2);

    Procedure upd_stage_error (p_pk_id in number, p_process_status in varchar2, p_error_mesg in varchar2);

    Procedure Refresh_Target(p_process_type in varchar2,
                             p_cs_definition_id in number,
                             p_cs_name in varchar2,
                             p_comp_refresh in varchar2,
                             p_instance_id in number,
                             p_new_refresh_num in NUMBER);

    Procedure ins_row_fact(
        crec_data          in msd_cs_dfn_utl.g_typ_source_stream,
        p_cs_rec           in msd_cs_definitions_v1%rowtype,
        p_cs_name          in varchar2,
        p_instance_id      in varchar2,
        p_new_refresh_num  IN NUMBER);

    Procedure ins_row_staging (
        crec_data       in  msd_cs_dfn_utl.g_typ_source_stream,
        p_cs_rec        in msd_cs_definitions_v1%rowtype,
        p_cs_name       in varchar2,
        p_instance_id   in varchar2,
        p_process_status in varchar2,
        p_error_message in varchar2);


    Procedure cs_collect_post_process (
        p_cs_Rec        in msd_cs_definitions_v1%rowtype,
        p_cs_name       in varchar2,
        p_instance_id   in varchar2 );

    Procedure Process_1 (
        p_cs_rec        in out NOCOPY  msd_cs_definitions_v1%rowtype,
        p_cs_name           in  varchar2,
        p_db_link           in  varchar2,
        p_source_view       in  varchar2,
        p_target_table      in  varchar2,
        p_process_type      in  number,
        p_default_where     in  varchar2,
        p_tokenized_where   in  varchar2,
        p_comp_refresh      in  varchar2,
        p_instance_id       in  number,
        p_parameter1        in  varchar2,
        p_parameter2        in  varchar2,
        p_parameter3        in  varchar2,
        p_parameter4        in  varchar2,
        p_parameter5        in  varchar2,
        p_parameter6        in  varchar2,
        p_parameter7        in  varchar2,
        p_parameter8        in  varchar2,
        p_parameter9        in  varchar2,
        p_parameter10       in  varchar2,
        p_new_refresh_num   IN  NUMBER,
        p_request_id        in  number);

    Procedure Process_2 (
        p_cs_rec        in out NOCOPY  msd_cs_definitions_v1%rowtype,
        p_cs_name           in  varchar2,
        p_db_link           in  varchar2,
        p_source_view       in  varchar2,
        p_target_table      in  varchar2,
        p_process_type      in  number,
        p_default_where     in  varchar2,
        p_tokenized_where   in  varchar2,
        p_comp_refresh      in  varchar2,
        p_instance_id       in  number,
        p_parameter1        in  varchar2,
        p_parameter2        in  varchar2,
        p_parameter3        in  varchar2,
        p_parameter4        in  varchar2,
        p_parameter5        in  varchar2,
        p_parameter6        in  varchar2,
        p_parameter7        in  varchar2,
        p_parameter8        in  varchar2,
        p_parameter9        in  varchar2,
        p_parameter10       in  varchar2,
        p_request_id        in  number);

    Function get_level_pk (
        p_instance          in varchar2,
        p_level_id          in number,
        p_sr_level_value_pk in OUT NOCOPY varchar2 ,
        p_level_value       in OUT NOCOPY varchar2,
        p_level_value_pk    in OUT NOCOPY varchar2) return varchar2;


    Procedure show_line(p_sql in    varchar2);

    Procedure debug_line(p_sql in    varchar2);

    Function validate_record (
        crec_data       in out NOCOPY  msd_cs_dfn_utl.g_typ_source_stream,
        p_cs_rec        in out NOCOPY  msd_Cs_definitions_v1%rowtype,
        p_instance_id   in      varchar2,
        p_err_mesg      out    NOCOPY  varchar2) return boolean;

    Function Build_Designator_Where_Clause(
        p_cs_rec        in  msd_cs_definitions_v1%rowtype,
        p_process_type  in  varchar2,
        p_cs_name       in  varchar2) return varchar2;

/* Logic Starts here */
Procedure Custom_Stream_Collection (
                  errbuf           OUT NOCOPY  varchar2,
                  retcode          OUT NOCOPY  varchar2,
                  p_collection_type in  varchar2,
                  p_validate_data   in  varchar2,
                  p_definition_id   in  number,
                  p_cs_name         in  varchar2,
                  p_comp_refresh    in  varchar2,
                  p_instance_id     in  number,
                  p_parameter1      in  varchar2,
                  p_parameter2      in  varchar2,
                  p_parameter3      in  varchar2,
                  p_parameter4      in  varchar2,
                  p_parameter5      in  varchar2,
                  p_parameter6      in  varchar2,
                  p_parameter7      in  varchar2,
                  p_parameter8      in  varchar2,
                  p_parameter9      in  varchar2,
                  p_parameter10     in  varchar2,
                  p_request_id      in  number default 0) is


    l_single_step_collection    varchar2(30):='Y';

    ll_name varchar2(80) := null;

    cursor c_get_cs is
        select * from msd_cs_definitions_v1
        where
            cs_definition_id = p_definition_id and
            nvl(valid_flag, 'N') = 'Y';

    l_sql_stmt      varchar2(32767);
    l_cs_rec        msd_cs_definitions_v1%rowtype;
    l_target        varchar2(60);
    l_source        varchar2(60);
    l_dblink        varchar2(60);
    l_default_where varchar2(200);
    l_cs_name       varchar2(255);
    l_retcode       VARCHAR2(30);
    L_PROCESS_TYPE  number;
    l_conc_request_id  number;

    l_new_refresh_num  NUMBER;
    l_comp_refresh     VARCHAR2(30);

Begin

  select DESCRIPTION
  into ll_name
  from msd_cs_definitions
  where cs_definition_id = p_definition_id;

  show_line('Stream Name   : ' || ll_name);

  debug_line('In Custom Stream Collection');
  /* Initialize */
  errbuf := 'Program Completed with Success';
  retcode := '0';

  /*  Get profile */
  l_single_step_collection := nvl(fnd_profile.value('MSD_ONE_STEP_COLLECTION'), 'N');

  l_conc_request_id := fnd_global.conc_request_id;
  debug_line('Conc Reuquest ID : ' || l_conc_request_id);

  /* Validate definition id */
  open c_get_cs;
  fetch c_get_cs into l_cs_rec;
  if c_get_cs%notfound then
        /*  raise error */
        retcode := 2;
        errbuf := 'Custom Definition Not Found : ' || p_definition_id;
        /* DWK close cursor */
        close c_get_cs;
        return;
  end if;
  /* DWK close cursor */
  close c_get_cs;

  if p_collection_type = C_COLLECT  and l_cs_rec.source_view_name is null then
        /* Print message/ raise error */
        retcode := 2;
        errbuf := 'Can not preform Collection - Source View is not specified.';
        return;
  end if;

  if nvl(l_cs_rec.multiple_stream_flag, 'N') <> 'Y' then
      l_cs_name := C_DEFAULT_STREAM_NAME;
  else
      l_cs_name := p_cs_name;
  end if;
  /* Instance must be specified for collection */
  if p_collection_type = C_COLLECT  and p_instance_id is null then
        /* Print message/raise error */
        retcode :=2;
        errbuf := 'Instance must be specified';
        return;
  end if;
  /*
     Fetch database link only if stream source type is 'SOURCE'
  */
  if l_cs_rec.cs_type in ('SOURCE') and p_collection_type = C_COLLECT then
       msd_common_utilities.get_db_link(p_instance_id, l_dblink, l_retcode);
	   if (l_retcode = -1) then
	      	retcode := 2;
	      	errbuf := 'Error while getting db_link';
	        return;
	   end if;
  end if;

  /*--------------  For Collection ----------------------------*/
  IF ( p_collection_type = C_COLLECT )  THEN

      /* Check and push setup parameters if it is not done so previously */
      MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                            retcode,
                                            p_instance_id);
      IF (nvl(retcode, 0) <> 0) THEN
          return;
      END IF;

      IF (l_single_step_collection = 'Y' and p_validate_data = 'Y') THEN
          /* One Step Collection will be internally transformed into
             Two Step Collection and Pull.
             Set Source and Target
             Set Global var for  processing error record and marking processed */

          /* Collect into staging without Validation. Validation will be done in PULL */
          l_target := 'MSD_ST_CS_DATA';
          l_process_type := C_SOURCE_TO_STAGE;
          l_source := l_cs_rec.source_view_name;
          /* Internally transformed 2 step collection, always performs complete
             refresh for collection part */
          l_comp_refresh := 'Y';

          l_default_where := Build_Designator_Where_Clause( l_cs_rec,
                                                            l_process_type,
                                                            p_cs_name);
          Refresh_Target(l_process_type, l_cs_rec.cs_definition_id,
                         l_cs_name, l_comp_refresh, p_instance_id,
                         l_new_refresh_num);
          Process_2(
                     p_cs_rec            => l_cs_rec,
                     p_cs_name           => l_cs_name,
                     p_db_link           => l_dblink,
                     p_source_view       => l_source,
                     p_target_table      => l_target,
                     p_process_type      => l_process_type,
                     p_default_where     => l_default_where,
                     p_tokenized_where   => l_cs_rec.collect_addtl_where_clause,
                     p_comp_refresh      => l_comp_refresh,
                     p_instance_id       => p_instance_id,
                     p_parameter1        => p_parameter1,
                     p_parameter2        => p_parameter2,
                     p_parameter3        => p_parameter3,
                     p_parameter4        => p_parameter4,
                     p_parameter5        => p_parameter5,
                     p_parameter6        => p_parameter6,
                     p_parameter7        => p_parameter7,
                     p_parameter8        => p_parameter8,
                     p_parameter9        => p_parameter9,
                     p_parameter10       => p_parameter10,
                     p_request_id        => l_conc_request_id);

       /* Custom Steam Collection Post Process
          After data has been collected from source to staging */
       cs_collect_post_process(l_cs_rec,
                           l_cs_name,
                           p_instance_id);

          /* Pull
              Set Source and Target
              Set Global var for  processing error record and marking processed */
          l_target := 'MSD_CS_DATA';
          l_source := 'MSD_ST_CS_DATA';
          l_process_type := C_STAGE_TO_FACT;
          l_default_where := Build_Designator_Where_Clause( l_cs_rec,
                                                            l_process_type,
                                                            p_cs_name);
          /* Get a new seq number for pull part */
          SELECT msd.msd_last_refresh_number_s.nextval into
                 l_new_refresh_Num from dual;

          /* Refresh Target */
          Refresh_Target(l_process_type, l_cs_rec.cs_definition_id,
                         l_cs_name, p_comp_refresh, p_instance_id,
                         l_new_refresh_num);
          Process_1(
                     p_cs_rec            => l_cs_rec,
                     p_cs_name           => l_cs_name,
                     p_db_link           => l_dblink,
                     p_source_view       => l_source,
                     p_process_type      => C_STAGE_TO_FACT,
                     p_target_table      => l_target,
                     p_default_where     => l_default_where,
                     p_tokenized_where   => NULL,
                     p_comp_refresh      => p_comp_refresh,
                     p_instance_id       => p_instance_id,
                     p_parameter1        => p_parameter1,
                     p_parameter2        => p_parameter2,
                     p_parameter3        => p_parameter3,
                     p_parameter4        => p_parameter4,
                     p_parameter5        => p_parameter5,
                     p_parameter6        => p_parameter6,
                     p_parameter7        => p_parameter7,
                     p_parameter8        => p_parameter8,
                     p_parameter9        => p_parameter9,
                     p_parameter10       => p_parameter10,
                     p_new_refresh_num   => l_new_refresh_num,
                     p_request_id        => l_conc_request_id);

      ELSIF (l_single_step_collection = 'N' and p_validate_data = 'Y') THEN
          /*
            Set Source and Target
            Set Global var for  processing error record and marking processed
          */
          l_target := 'MSD_ST_CS_DATA';
          l_process_type := C_SOURCE_TO_STAGE;
          l_source := l_cs_rec.source_view_name;
          l_default_where := Build_Designator_Where_Clause( l_cs_rec,
                                                            l_process_type,
                                                            p_cs_name);
          Refresh_Target(l_process_type, l_cs_rec.cs_definition_id,
                         l_cs_name, p_comp_refresh, p_instance_id,
                         l_new_refresh_num);
          Process_1(
                     p_cs_rec            => l_cs_rec,
                     p_cs_name           => l_cs_name,
                     p_db_link           => l_dblink,
                     p_source_view       => l_source,
                     p_target_table      => l_target,
                     p_process_type      => l_process_type,
                     p_default_where     => l_default_where,
                     p_tokenized_where   => l_cs_rec.collect_addtl_where_clause,
                     p_comp_refresh      => p_comp_refresh,
                     p_instance_id       => p_instance_id,
                     p_parameter1        => p_parameter1,
                     p_parameter2        => p_parameter2,
                     p_parameter3        => p_parameter3,
                     p_parameter4        => p_parameter4,
                     p_parameter5        => p_parameter5,
                     p_parameter6        => p_parameter6,
                     p_parameter7        => p_parameter7,
                     p_parameter8        => p_parameter8,
                     p_parameter9        => p_parameter9,
                     p_parameter10       => p_parameter10,
                     p_new_refresh_num   => l_new_refresh_num,
                     p_request_id        => l_conc_request_id);

       /* Custom Steam Collection Post Process
          After data has been collected from source to staging
       */
          cs_collect_post_process(l_cs_rec,
                                  l_cs_name,
                                  p_instance_id);

      ELSIF (l_single_step_collection = 'Y' and p_validate_data = 'N') THEN
          /* Invalid Option. Raise Error */
          retcode := 2;
          errbuf := 'Invalid option - Single Step Collection must perform Validation';
          return;
      ELSIF (l_single_step_collection = 'N' and p_validate_data = 'N') THEN
          /* Collect into staging without Validation */
          l_target := 'MSD_ST_CS_DATA';
          l_process_type := C_SOURCE_TO_STAGE;
          l_source := l_cs_rec.source_view_name;
          l_default_where := Build_Designator_Where_Clause( l_cs_rec,
                                                            l_process_type,
                                                            p_cs_name);
          Refresh_Target(l_process_type, l_cs_rec.cs_definition_id,
                         l_cs_name, p_comp_refresh, p_instance_id,
                         l_new_refresh_num);
          Process_2(
                     p_cs_rec            => l_cs_rec,
                     p_cs_name           => l_cs_name,
                     p_db_link           => l_dblink,
                     p_source_view       => l_source,
                     p_target_table      => l_target,
                     p_process_type      => l_process_type,
                     p_default_where     => l_default_where,
                     p_tokenized_where   => l_cs_rec.collect_addtl_where_clause,
                     p_comp_refresh      => p_comp_refresh,
                     p_instance_id       => p_instance_id,
                     p_parameter1        => p_parameter1,
                     p_parameter2        => p_parameter2,
                     p_parameter3        => p_parameter3,
                     p_parameter4        => p_parameter4,
                     p_parameter5        => p_parameter5,
                     p_parameter6        => p_parameter6,
                     p_parameter7        => p_parameter7,
                     p_parameter8        => p_parameter8,
                     p_parameter9        => p_parameter9,
                     p_parameter10       => p_parameter10,
                     p_request_id        => l_conc_request_id);

       /* Custom Steam Collection Post Process
          After data has been collected from source to staging
       */
          cs_collect_post_process(l_cs_Rec,
                                  l_cs_name,
                                  p_instance_id);


      END IF;  /* End of ELSE IF */

  /*---------------------  For Pull ----------------------------*/
  ELSIF (p_collection_type = C_PULL) THEN
     IF p_validate_data = 'Y' THEN
        /*
         Set Source and Target
         Set Global var for  processing error record and marking processed
        */
        l_target := 'MSD_CS_DATA';
        l_source := 'MSD_ST_CS_DATA';
        l_process_type := C_STAGE_TO_FACT;
        l_default_where := Build_Designator_Where_Clause(
            l_cs_rec        ,
            l_process_type  ,
            p_cs_name       );

        /* Get a new seq number for PULL part  */
        SELECT msd.msd_last_refresh_number_s.nextval into
               l_new_refresh_Num from dual;

        /* Refresh Target */
        Refresh_Target(l_process_type, l_cs_rec.cs_definition_id,
                       l_cs_name,p_comp_refresh, p_instance_id,
                       l_new_refresh_num);

        Process_1(
            p_cs_rec            => l_cs_rec,
            p_cs_name           => l_cs_name,
            p_db_link           => l_dblink,
            p_source_view       => l_source,
            p_process_type      => C_STAGE_TO_FACT,
            p_target_table      => l_target,
            p_default_where     => l_default_where,
            p_tokenized_where   => NULL,
            p_comp_refresh      => p_comp_refresh,
            p_instance_id       => p_instance_id,
            p_parameter1        => p_parameter1,
            p_parameter2        => p_parameter2,
            p_parameter3        => p_parameter3,
            p_parameter4        => p_parameter4,
            p_parameter5        => p_parameter5,
            p_parameter6        => p_parameter6,
            p_parameter7        => p_parameter7,
            p_parameter8        => p_parameter8,
            p_parameter9        => p_parameter9,
            p_parameter10       => p_parameter10,
            p_new_refresh_num   => l_new_refresh_num,
            p_request_id        => l_conc_request_id);

     ELSE
         /* Invalid Option. Raise Error;*/
         retcode := 2;
         errbuf := 'Invalid option - Pull must perform Validation';
         return;
     END IF;  /* End of  p_validate_data = 'Y'  */
  END IF;  /* End of Collect or Pull */


  IF (l_target = 'MSD_CS_DATA') THEN
     /* Delete cs fact rows that are not used by any demand plans */
     MSD_TRANSLATE_FACT_DATA.clean_fact_data( errbuf,
                                              retcode,
                                              l_target);
  END IF;


  retcode := g_retcode;
  errbuf  := g_errbuf;

  commit;

Exception
    When others then
        retcode := 2;
        errbuf := substr( sqlerrm, 1, 255);
        rollback;
End;

Procedure Process_1 (
    p_cs_rec        in out NOCOPY  msd_cs_definitions_v1%rowtype,
    p_cs_name           in  varchar2,
    p_db_link           in  varchar2,
    p_source_view       in  varchar2,
    p_target_table      in  varchar2,
    p_process_type      in  number,
    p_default_where     in  varchar2,
    p_tokenized_where   in  varchar2,
    p_comp_refresh      in  varchar2,
    p_instance_id       in  number,
    p_parameter1        in  varchar2,
    p_parameter2        in  varchar2,
    p_parameter3        in  varchar2,
    p_parameter4        in  varchar2,
    p_parameter5        in  varchar2,
    p_parameter6        in  varchar2,
    p_parameter7        in  varchar2,
    p_parameter8        in  varchar2,
    p_parameter9        in  varchar2,
    p_parameter10       in  varchar2,
    p_new_refresh_num   IN  NUMBER,
    p_request_id        in  number) is

    TYPE cur_type is REF CURSOR;

    l_cur       cur_type;
    l_rec       msd_cs_dfn_utl.G_TYP_SOURCE_STREAM;
    l_valid     boolean;
    l_err_msg   varchar2(1000);
    l_sql_stmt  varchar2(5000);
    l_where     varchar2(3000);

Begin
debug_line('In Process_1');
    /*
     This process does following
     1. Fetches data using cursor (source/staging)
     2. Validates data
     3. If Error
          3.1 Mark/Save Erroneous data in staging
        else
          3.100 Save in Target (Fact/Staging)
          3.101 Mark record Processed
        end if
    */

    l_sql_stmt := Build_SQL_FOR_COLLECT_AND_VAL
        (p_cs_rec.cs_definition_id, p_process_type,
         p_source_view, p_db_link, p_cs_name);

    l_sql_stmt :=  l_sql_stmt || ' WHERE 1 = 1';

    l_where := build_where_clause(
                                   p_tokenized_where   ,
                                   p_default_where     ,
                                   p_parameter1        ,
                                   p_parameter2        ,
                                   p_parameter3        ,
                                   p_parameter4        ,
                                   p_parameter5        ,
                                   p_parameter6        ,
                                   p_parameter7        ,
                                   p_parameter8        ,
                                   p_parameter9        ,
                                   p_parameter10       ,
                                   p_request_id      );

    if l_where is not null then
        l_sql_stmt := l_sql_stmt || ' AND ' || l_where;
    end if;

    /* DWK.  Do not include instace = 0 into fact table when we PULL data */
    IF (p_process_type =  C_STAGE_TO_FACT) THEN
	l_sql_stmt := l_sql_stmt ||
		' AND ' || 'attribute_1 <> 0';
    END IF;

debug_line('length for l_sql_stmt :' || length(l_sql_stmt));
debug_line('length for l_where :' || length(l_where));
debug_line('before debug line');
debug_line(l_sql_stmt);
debug_line('after debug line');

    /* Use Dynamic SQL to fetch and process rows */
    Process_1_Sub (
                     p_cs_rec        ,
                     p_cs_name       ,
                     p_source_view   ,
                     p_target_table  ,
                     p_instance_id   ,
                     l_sql_stmt,
                     p_new_refresh_num);

    /* Delete Successfully processed Staging rows if the process was Staging to Fact */
    /* DWK  Don't delete any row with instance = 0 */
    /* Also, removed cs_name = p_cs_name condition from WHERE clause */

    IF p_process_type = C_STAGE_TO_FACT THEN
        delete from MSD_ST_CS_DATA
        where
            cs_definition_id = p_cs_rec.cs_definition_id and
     	    process_Status = C_LOG_PROCESSED and
	    attribute_1 <> '0';
    END IF;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;


Procedure cs_collect_post_process (
        p_cs_rec        in msd_cs_definitions_v1%rowtype,
        p_cs_name       in varchar2,
        p_instance_id   in varchar2 ) is

    cursor c1 is
        select 'Y'
        from msd_st_cs_data
        where cs_definition_id = p_cs_rec.cs_definition_id
        and cs_name = p_cs_name
        and attribute_1 = p_instance_id
        and attribute_49 = '1'
        and rownum < 2;

        l_exists varchar2(10):='N';

Begin

    /* Is this Sales Forecast Stream */
    if p_cs_rec.name in (
        'MSD_SALES_FCST_BESTCASE', 'MSD_SALES_FCST_PIPELINE',
        'MSD_SALES_FCST_REALISTIC', 'MSD_SALES_FCST_WGTPLINE',
        'MSD_SALES_FCST_WORSTCASE' ) then

        open c1;
        fetch c1 into l_exists;
        close c1;

        If l_exists = 'Y' then
           delete from msd_st_cs_data
           where cs_definition_id = p_cs_Rec.cs_definition_id
           and cs_name = p_cs_name
           and attribute_1 = p_instance_id
           and attribute_49 = '2';

        end if;

    end if;

    /* Collect Current On-Hand Inventory data from ODS table for SOP data stream */

    if p_cs_rec.name = 'MSD_ONHAND_INVENTORY' then

        insert into msd_st_cs_data (
           CS_ST_DATA_ID,
           CS_DEFINITION_ID,
           CS_NAME,
           ATTRIBUTE_1,
           ATTRIBUTE_2,
           ATTRIBUTE_3,
           ATTRIBUTE_6,
           ATTRIBUTE_7,
           ATTRIBUTE_10,
           ATTRIBUTE_11,
           ATTRIBUTE_34,
           ATTRIBUTE_41,
           ATTRIBUTE_43,
           ATTRIBUTE_50,
           ATTRIBUTE_51,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
           )
         select msd_st_cs_data_s.nextval,
                to_char(p_cs_rec.cs_definition_id),
                'SINGLE_STREAM',
                to_char(inv.sr_instance_id),
                inv.prd_level_id,
                inv.prd_sr_level_pk,
                inv.geo_level_id,
                inv.geo_sr_level_pk,
                inv.org_level_id,
                inv.org_sr_level_pk,
                inv.time_level_id,
                to_char(inv.quantity),
                to_char(sysdate, 'YYYY/MM/DD'),
                inv.dcs_level_id,
                inv.dcs_sr_level_pk,
                to_char(sysdate),
                to_char(fnd_global.user_id),
                to_char(sysdate),
                to_char(fnd_global.user_id),
                to_char(fnd_global.login_id)
         from msd_curr_onhand_inventory_v inv
         where inv.sr_instance_id = p_instance_id;

    end if;

Exception
When others then
    show_line(sqlerrm);
    raise;
End;


Procedure log_error (
    crec_data       in msd_cs_dfn_utl.g_typ_source_stream,
    p_cs_rec        in msd_cs_definitions_v1%rowtype,
    p_cs_name       in varchar2,
    p_instance_id   in varchar2,
    p_error_message in varchar2,
    p_source_view   in varchar2,
    p_target_table  in varchar2) is
Begin
    /*
     Error Logging depends on source and target.
    */
    debug_line('In Log Error');
    if (p_target_table = 'MSD_CS_DATA' and p_source_view <> 'MSD_ST_CS_DATA') or
       (p_target_table = 'MSD_ST_CS_DATA') then
        /*
         if data is collected directly from source to Fact table or
         data is collected into staging table then
         insert erroneous row in staging table with Status "Error"
        */
        ins_row_staging(crec_data, p_cs_rec, p_cs_name,
                       nvl(p_instance_id, crec_data.instance),
                       C_LOG_ERROR,
                       p_error_message);
    else
        /* i.e. Data is Pulled from Staging to Fact. Then update the staging row
           with Status 'invalid'
        */
        upd_stage_error(crec_data.pk_id, C_LOG_ERROR, p_error_message);
    end if;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure upd_stage_error (p_pk_id in number, p_process_status in varchar2, p_error_mesg in varchar2) is
Begin
    debug_line('In upd_stage_error');
    update msd_st_cs_data
    set
        error_desc = p_error_mesg,
        process_status = p_process_status
    where cs_st_data_id = p_pk_id;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure log_processed (
    crec_data       in msd_cs_dfn_utl.g_typ_source_stream,
    p_cs_rec        in msd_cs_definitions_v1%rowtype,
    p_cs_name       in varchar2,
    p_instance_id   in varchar2,
    p_source_view   in varchar2,
    p_target_table  in varchar2) is
Begin
    debug_line('In log_processed');
    /* Process Logging depends on source and target.
    */
    if (p_target_table = 'MSD_CS_DATA' and p_source_view <> 'MSD_ST_CS_DATA') or
       (p_target_table = 'MSD_ST_CS_DATA') then
        /*
         if data is collected directly from source to Fact table or
         data is collected into staging table then
         Processing can not be logged or is not yet done
        */
        null;
    else
        /* i.e. Data is Pulled from Staging to Fact. Then update the staging row
         with Status PROCESSED
       */
        upd_stage_error(crec_data.pk_id, C_LOG_PROCESSED, null);
    end if;

    if p_target_table = 'MSD_CS_DATA' then

        null;
    end if;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure ins_row_staging (
    crec_data in  msd_cs_dfn_utl.g_typ_source_stream,
    p_cs_rec        in msd_cs_definitions_v1%rowtype,
    p_cs_name       in varchar2,
    p_instance_id   in varchar2,
    p_process_status in varchar2,
    p_error_message in varchar2) is
Begin
--    debug_line('In ins_row_staging');
    insert into msd_st_cs_data
        (cs_st_data_id, cs_definition_id, cs_name,
         attribute_1, attribute_2, attribute_3, attribute_4,
         attribute_5, attribute_6, attribute_7, attribute_8, attribute_9,
         attribute_10, attribute_11, attribute_12, attribute_13,
         attribute_14, attribute_15, attribute_16, attribute_17,
         attribute_18, attribute_19, attribute_20, attribute_21, attribute_22,
         attribute_23, attribute_24, attribute_25, attribute_26, attribute_27,
         attribute_28, attribute_29, attribute_30, attribute_31,
         attribute_32, attribute_33, attribute_34, attribute_35, attribute_36,
         attribute_37, attribute_38, attribute_39, attribute_40,
         attribute_41, attribute_42, attribute_43, attribute_44, attribute_45,
         attribute_46, attribute_47, attribute_48, attribute_49,
         attribute_50, attribute_51, attribute_52, attribute_53, attribute_54,
	 attribute_55, attribute_56, attribute_57, attribute_58, attribute_59,
	 attribute_60,
         process_status, error_desc,
         created_by, creation_date, last_update_date, last_updated_by, last_update_login
         )
    values
    /* Fix for designator name crec_data.designator instead of p_cs_name */
        (msd_st_cs_data_s.nextval, p_cs_rec.cs_definition_id, crec_data.designator,
         p_instance_id,
         crec_data.prd_level_id, crec_data.prd_sr_level_value_pk, crec_data.prd_level_value, crec_data.prd_level_value_pk,
         crec_data.geo_level_id, crec_data.geo_sr_level_value_pk, crec_data.geo_level_value, crec_data.geo_level_value_pk,
         crec_data.org_level_id, crec_data.org_sr_level_value_pk, crec_data.org_level_value, crec_data.org_level_value_pk,
         crec_data.prd_parent_level_id,    crec_data.prd_parent_sr_level_value_pk,
         crec_data.prd_parent_level_value, crec_data.prd_parent_level_value_pk,
         crec_data.rep_level_id, crec_data.rep_sr_level_value_pk, crec_data.rep_level_value, crec_data.rep_level_value_pk,
         crec_data.chn_level_id, crec_data.chn_sr_level_value_pk, crec_data.chn_level_value, crec_data.chn_level_value_pk,
         crec_data.ud1_level_id, crec_data.ud1_sr_level_value_pk, crec_data.ud1_level_value, crec_data.ud1_level_value_pk,
         crec_data.ud2_level_id, crec_data.ud2_sr_level_value_pk, crec_data.ud2_level_value, crec_data.ud2_level_value_pk,
         crec_data.tim_level_id, crec_data.attribute_35, crec_data.attribute_36, crec_data.attribute_37,
         crec_data.attribute_38, crec_data.attribute_39, crec_data.attribute_40, crec_data.attribute_41,
         crec_data.attribute_42, crec_data.attribute_43, crec_data.attribute_44, crec_data.attribute_45,
         crec_data.attribute_46, crec_data.attribute_47, crec_data.attribute_48, crec_data.attribute_49,
         crec_data.dcs_level_id, crec_data.dcs_sr_level_value_pk, crec_data.dcs_level_value, crec_data.dcs_level_value_pk,
	 crec_data.attribute_54, crec_data.attribute_55, crec_data.attribute_56, crec_data.attribute_57,
	 crec_data.attribute_58, crec_data.attribute_59, crec_data.attribute_60,
         p_process_status, p_error_message,
         fnd_global.user_id, sysdate, sysdate, fnd_global.user_id, fnd_global.login_id);

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure ins_row_fact(
                       crec_data                in msd_cs_dfn_utl.g_typ_source_stream,
                       p_cs_rec                 in msd_cs_definitions_v1%rowtype,
                       p_cs_name                in varchar2,
                       p_instance_id            in varchar2,
                       p_new_refresh_num        in NUMBER) is
Begin
    debug_line('In ins_row_fact');
    insert into msd_cs_data
        (cs_data_id, cs_definition_id, cs_name,
         attribute_1, attribute_2, attribute_3, attribute_4,
         attribute_5, attribute_6, attribute_7, attribute_8, attribute_9,
         attribute_10, attribute_11, attribute_12, attribute_13,
         attribute_14, attribute_15, attribute_16, attribute_17,
         attribute_18, attribute_19, attribute_20, attribute_21, attribute_22,
         attribute_23, attribute_24, attribute_25, attribute_26, attribute_27,
         attribute_28, attribute_29, attribute_30, attribute_31,
         attribute_32, attribute_33, attribute_34, attribute_35, attribute_36,
         attribute_37, attribute_38, attribute_39, attribute_40,
         attribute_41, attribute_42, attribute_43, attribute_44, attribute_45,
         attribute_46, attribute_47, attribute_48, attribute_49,
         attribute_50, attribute_51, attribute_52, attribute_53, attribute_54,
	 attribute_55, attribute_56, attribute_57, attribute_58, attribute_59,
	 attribute_60,
         created_by, creation_date, last_update_date, last_updated_by,last_update_login,
         created_by_refresh_num, last_refresh_num, action_code)
    values
        /* Fix for designator name crec_data.designator instead of p_cs_name */
        (msd_cs_data_s.nextval, p_cs_rec.cs_definition_id, crec_data.designator ,
         p_instance_id,
         crec_data.prd_level_id, crec_data.prd_sr_level_value_pk, crec_data.prd_level_value, crec_data.prd_level_value_pk,
         crec_data.geo_level_id, crec_data.geo_sr_level_value_pk, crec_data.geo_level_value, crec_data.geo_level_value_pk,
         crec_data.org_level_id, crec_data.org_sr_level_value_pk, crec_data.org_level_value, crec_data.org_level_value_pk,
         crec_data.prd_parent_level_id, crec_data.prd_parent_sr_level_value_pk,
         crec_data.prd_parent_level_value, crec_data.prd_parent_level_value_pk,
         crec_data.rep_level_id, crec_data.rep_sr_level_value_pk, crec_data.rep_level_value, crec_data.rep_level_value_pk,
         crec_data.chn_level_id, crec_data.chn_sr_level_value_pk, crec_data.chn_level_value, crec_data.chn_level_value_pk,
         crec_data.ud1_level_id, crec_data.ud1_sr_level_value_pk, crec_data.ud1_level_value, crec_data.ud1_level_value_pk,
         crec_data.ud2_level_id, crec_data.ud2_sr_level_value_pk, crec_data.ud2_level_value, crec_data.ud2_level_value_pk,
         crec_data.tim_level_id, crec_data.attribute_35, crec_data.attribute_36, crec_data.attribute_37,
         crec_data.attribute_38, crec_data.attribute_39, crec_data.attribute_40, crec_data.attribute_41,
         crec_data.attribute_42, crec_data.attribute_43, crec_data.attribute_44, crec_data.attribute_45,
         crec_data.attribute_46, crec_data.attribute_47, crec_data.attribute_48, crec_data.attribute_49,
         crec_data.dcs_level_id, crec_data.dcs_sr_level_value_pk, crec_data.dcs_level_value, crec_data.dcs_level_value_pk,
	 crec_data.attribute_54, crec_data.attribute_55, crec_data.attribute_56, crec_data.attribute_57,
	 crec_data.attribute_58, crec_data.attribute_59, crec_data.attribute_60,
	 fnd_global.user_id, sysdate, sysdate, fnd_global.user_id,fnd_global.login_id,
         p_new_refresh_num, p_new_refresh_num, 'I');

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure Process_2 (
    p_cs_rec        in out NOCOPY  msd_cs_definitions_v1%rowtype,
    p_cs_name           in  varchar2,
    p_db_link           in  varchar2,
    p_source_view       in  varchar2,
    p_target_table      in  varchar2,
    p_process_type      in  number,
    p_default_where     in  varchar2,
    p_tokenized_where   in  varchar2,
    p_comp_refresh      in  varchar2,
    p_instance_id       in  number,
    p_parameter1        in  varchar2,
    p_parameter2        in  varchar2,
    p_parameter3        in  varchar2,
    p_parameter4        in  varchar2,
    p_parameter5        in  varchar2,
    p_parameter6        in  varchar2,
    p_parameter7        in  varchar2,
    p_parameter8        in  varchar2,
    p_parameter9        in  varchar2,
    p_parameter10       in  varchar2,
    p_request_id          in  number) is

    l_ins_stmt  varchar2(32767);
    l_where     varchar2(500);


Begin
    debug_line('In Process_2');
    /*
     This Procedure inserts data in staging table from source view
     without performing any validation.
    */


    l_ins_stmt := Build_SQL_INS_AS_SELECT(
        p_cs_definition_id => p_cs_rec.cs_definition_id,
        p_instance_id      => p_instance_id,
        p_cs_name          => p_cs_name,
        p_source_view      => p_source_view,
        p_db_link          => p_db_link);


    l_where := build_where_clause(
        p_tokenized_where   ,
        p_default_where     ,
        p_parameter1        ,
        p_parameter2        ,
        p_parameter3        ,
        p_parameter4        ,
        p_parameter5        ,
        p_parameter6        ,
        p_parameter7        ,
        p_parameter8        ,
        p_parameter9        ,
        p_parameter10       ,
        p_request_id );


    if l_where is not null then
        l_ins_stmt := l_ins_stmt || ' where ' || l_where;
    end if;



    /* Execute SQL */
    debug_line(l_ins_stmt);

    Execute immediate l_ins_stmt;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Function Build_SQL_FOR_COLLECT_AND_VAL(
                                        p_cs_definition_id in number,
                                        p_process_type     in number,
                                        p_source_view      in varchar2,
                                        p_db_link          in varchar2,
                                        p_cs_name          in varchar2)
                                        return varchar2 is

    l_sql_stmt  varchar2(32767);
Begin
    debug_line('In Build_SQL_FOR_COLLECT_AND_VAL');
    /*
     This method will be used in the following cases
      Source  ------ Staging (Process - Collect (Single Step = 'N'). Validation - 'Y')
      Source  ------ Fact    (Process - Collect (Single Step = 'Y'). Validation - 'Y')
      Staging ------ Fact    (Process - Pull    (Single Step = N/A). Validation - 'Y')
    */
    l_sql_stmt := Build_SQL_Source(p_cs_definition_id, p_process_type, NULL, p_cs_name);
    /*
     Append data specific to Single Step needs
    */
    if p_source_view = 'MSD_ST_CS_DATA' then
        l_sql_stmt := 'Select  cs_st_data_id PK_ID, ' || l_sql_stmt || ' from ' || p_source_view ;
    else
        l_sql_stmt := 'Select null pk_id, ' || l_sql_stmt || ' from ' || p_source_view || p_db_link;
    end if;

    return l_sql_stmt;


Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Function Build_SQL_INS_AS_SELECT(
    p_cs_definition_id in number,
    p_instance_id      in varchar2,
    p_cs_name          in varchar2,
    p_source_view      in varchar2,
    p_db_link          in varchar2) return varchar2 is

    l_sql_stmt  varchar2(32767);
Begin
    debug_line('In Build_SQL_INS_AS_SELECT');
    /*
     This method will be used in the following cases
      Source  ------ Staging (Process - Collect (Single Step = 'N'). Validation - 'N')
    */
    l_sql_stmt := Build_SQL_Source(p_cs_definition_id, C_SOURCE_TO_STAGE,
                                   p_instance_id, p_cs_name);

/* DWK Move cs_name from top to at the bottom of insert statement since
   l_sql_stmt will have forecast_designator inside. */
    l_sql_stmt := 'Insert into MSD_ST_CS_DATA (cs_st_data_id , cs_definition_id, ' ||
        'attribute_1, attribute_2, attribute_3, attribute_4, attribute_5, '      ||
        'attribute_6, attribute_7, attribute_8, attribute_9, attribute_10,'      ||
        'attribute_11, attribute_12, attribute_13, attribute_14, attribute_15, ' ||
        'attribute_16, attribute_17, attribute_18, attribute_19, attribute_20, ' ||
        'attribute_21, attribute_22, attribute_23, attribute_24, attribute_25, ' ||
        'attribute_26, attribute_27, attribute_28, attribute_29, attribute_30,'  ||
        'attribute_31, attribute_32, attribute_33, attribute_34, attribute_35, ' ||
        'attribute_36, attribute_37, attribute_38, attribute_39, attribute_40,'  ||
        'attribute_41, attribute_42, attribute_43, attribute_44, attribute_45, ' ||
        'attribute_46, attribute_47, attribute_48, attribute_49, attribute_50, ' ||
        'attribute_51, attribute_52, attribute_53, attribute_54, attribute_55, ' ||
        'attribute_56, attribute_57, attribute_58, attribute_59, attribute_60,'  ||
        'cs_name ) ' || ' select ' || 'msd_st_cs_Data_s.nextval, ' || p_cs_definition_id ||
        ', ' ||  l_sql_stmt || ' from ' || p_source_view || p_db_link;

    return l_sql_stmt;


Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Function Build_SQL_Source(
    p_cs_definition_id in number,
    p_process_type     in number,
    p_instance_id      in varchar2,
    p_cs_name          in varchar2) return varchar2 is

    Type l_type_sql_struct is RECORD (
        tabcol_name    varchar2(60),
        srccol_name    varchar2(60));
    Type l_type_sql_struct_array is TABLE of l_type_sql_struct;

    CURSOR c1 IS
    select * from msd_cs_defn_column_dtls_v
    where cs_definition_id = p_cs_definition_id;

    CURSOR c_multi_stream IS
    SELECT multiple_stream_flag FROM msd_cs_definitions
    WHERE cs_definition_id = p_cs_definition_id;

    CURSOR c_cs_name IS
    select source_view_column_name
    from msd_cs_defn_column_dtls_v
    where cs_definition_id = p_cs_definition_id and
          table_column = 'CS_NAME';

    l_struct l_type_sql_struct_array;
    l_sql_stmt       varchar2(32767);
    l_multi_stream   VARCHAR2(30);

/*
    Function conv_to_sql_struct (a in varchar2, b in varchar2)
                                return l_type_sql_struct is
        x l_type_sql_struct;
    Begin
        x.tabcol_name := a;
        x.srccol_name := b;
        return x;
    End;
*/

Begin
    debug_line('In Build_SQL_Source');
    /* p_source_or_stage  = 0 menas build select for source view,
       p_source_or_stage  = non 0 menas build select for staging  */
    /* Initialize array */

    l_struct := l_type_sql_struct_array(null);

    /* Build Array with default values - Table_column_name is 'cs_name, attribute_1' ...
     and source_column_name is 'NULL' */

    for i in 1..60 loop
       l_struct.extend;
       l_struct(i).tabcol_name := 'ATTRIBUTE_' || i;
       l_struct(i).srccol_name := 'NULL';
    end loop;
    l_struct.extend;
    l_struct(61).tabcol_name := 'CS_NAME';

    /* Fetch source column name from the mappings table and update the array */
    for c1_rec in c1 loop

        for i IN 1..61 loop
            if l_struct(i).tabcol_name = c1_rec.table_column then
                if c1_rec.identifier_type = 'INSTANCE' then
                    if p_instance_id is not null then
                        l_struct(i).srccol_name := '''' || p_instance_id || '''';
                    end if;
                elsif c1_rec.identifier_type = 'DATE' then
                    if c1_rec.source_view_column_name  is not null then
                        l_struct(i).srccol_name := 'to_char(' ||c1_rec.source_view_column_name || ', ''YYYY/MM/DD'')';
                    end if;
                else
                    if c1_rec.source_view_column_name  is not null then
                        l_struct(i).srccol_name := c1_rec.source_view_column_name ;
                    end if;
                end if;
                exit;
            end if;
        end loop;
    end loop;

    /* DWK If this stream is multiple stream and there is no column mapping
       for CS_NAME then, assume user will populate the CS_NAME
       from Collection */

    OPEN  c_multi_stream;
    FETCH c_multi_stream INTO l_multi_stream;
    CLOSE c_multi_stream;

    IF nvl(l_multi_stream, 'N') = 'Y' THEN
       /* After column mapping, if source column for CS_NAME is still null
          then  assume user will populate the CS_NAME  from Collection */

       IF ( l_struct(61).srccol_name IS NULL ) THEN
          l_struct(61).srccol_name := '''' || replace(p_cs_name, '''', '''''') || '''';
       END IF;

    ELSE   /* Single stream */
       l_struct(61).srccol_name := '''' || C_DEFAULT_STREAM_NAME || '''' ;
    END IF;

    /* Builds SQL stmt */
    for i in 1..61 loop

        if p_process_type in (C_SOURCE_TO_FACT, C_SOURCE_TO_STAGE) then
            if l_sql_stmt is null then
                l_sql_stmt := l_sql_stmt || l_struct(i).srccol_name;
            else
                l_sql_stmt := l_sql_stmt || ', ' || l_struct(i).srccol_name;
            end if;
        else
            /* staging to fact (assumption always for Validate = 'Yes'
               append staging table column name + column alias ("Source view name")
            */
            if l_sql_stmt is null then
                l_sql_stmt := l_sql_stmt || l_struct(i).tabcol_name;
            else
                l_sql_stmt := l_sql_stmt || ', ' || l_struct(i).tabcol_name ;
            end if;
        end if;

    end loop;

    debug_line('l_sql_stmt : ' || l_sql_stmt);
    return l_sql_stmt;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure show_line(p_sql in    varchar2) is
    i   number:=1;
Begin
    while i <= length(p_sql)
    loop
 --     dbms_output.put_line (substr(p_sql, i, 255));
        fnd_file.put_line(fnd_file.log,substr(p_sql, i, 255));
	null;
        i := i+255;
    end loop;
End;

Function validate_record (
    crec_data       in out NOCOPY  msd_cs_dfn_utl.g_typ_source_stream,
    p_cs_rec        in out NOCOPY  msd_Cs_definitions_v1%rowtype,
    p_instance_id   in     varchar2,
    p_err_mesg      out    NOCOPY  varchar2) return boolean is

    l_comments1         varchar2(1000);
    l_comments2         varchar2(1000);
    l_first_record      boolean:=TRUE;
    l_dummy_date        date;
    l_dummy_number      number;

    l_prd_found        varchar2(30);
    l_prd_parent_found varchar2(30);
    l_geo_found        varchar2(30);
    l_org_found        varchar2(30);
    l_chn_found        varchar2(30);
    l_rep_found        varchar2(30);
    l_ud1_found        varchar2(30);
    l_ud2_found        varchar2(30);
    l_tim_found        varchar2(30);
    l_dcs_found        varchar2(30);

    l_count            number(2) := 0;

Begin

   /*  crec_data  -> actual record that you want to validate(ex, rows in staging table)
       p_cs_rec   -> information in custom stream definition
   */

--    debug_line('In validate_record');
    /* Get Product LEVEL_PK */
    if nvl(p_cs_rec.prd_level_collect_flag, 'N') = 'Y' then
        l_prd_found := get_level_pk(p_instance_id, crec_data.prd_level_id,
                       crec_data.prd_sr_level_value_pk, crec_data.prd_level_value, crec_data.prd_level_value_pk);

        IF ( crec_data.prd_parent_sr_level_value_pk IS NOT NULL or
             crec_data.prd_parent_level_value IS NOT NULL or
             crec_data.prd_parent_level_value_pk IS NOT NULL ) THEN
            /* DWK Get Product Dimension's Parent LEVEL_PK */
            l_prd_parent_found := get_level_pk(p_instance_id, crec_data.prd_parent_level_id,
                                      crec_data.prd_parent_sr_level_value_pk,
                                      crec_data.prd_parent_level_value,
                                      crec_data.prd_parent_level_value_pk);

        ELSE  /* IF there is no parent item then make it null */
            crec_data.prd_parent_level_id := NULL;
        END IF;
    end if;
    /*  Get ORG LEVEL_PK */
    if nvl(p_cs_rec.org_level_collect_flag, 'N') = 'Y' then
        l_org_found := get_level_pk(p_instance_id, crec_data.org_level_id,
                       crec_data.org_sr_level_value_pk, crec_data.org_level_value, crec_data.org_level_value_pk);
    end if;
    /* Get Geo LEVEL_PK */
    if nvl(p_cs_rec.geo_level_collect_flag, 'N') = 'Y' then
        l_geo_found := get_level_pk(p_instance_id, crec_data.geo_level_id,
                       crec_data.geo_sr_level_value_pk, crec_data.geo_level_value, crec_data.geo_level_value_pk);
    end if;

    /* Get CHN LEVEL_PK */
    if nvl(p_cs_rec.chn_level_collect_flag, 'N') = 'Y' then
        l_chn_found := get_level_pk(p_instance_id, crec_data.chn_level_id,
                       crec_data.chn_sr_level_value_pk, crec_data.chn_level_value, crec_data.chn_level_value_pk);
    end if;
    /* Get REP LEVEL_PK */
    if nvl(p_cs_rec.rep_level_collect_flag, 'N') = 'Y' then
        l_rep_found := get_level_pk(p_instance_id, crec_data.rep_level_id,
                       crec_data.rep_sr_level_value_pk, crec_data.rep_level_value, crec_data.rep_level_value_pk);
    end if;
    /* Get UD1 LEVEL_PK */
    if nvl(p_cs_rec.ud1_level_collect_flag, 'N') = 'Y' then
        l_ud1_found := get_level_pk(p_instance_id, crec_data.ud1_level_id,
                       crec_data.ud1_sr_level_value_pk, crec_data.ud1_level_value, crec_data.ud1_level_value_pk);
    end if;
    /* Get UD2 LEVEL_PK */
    if nvl(p_cs_rec.ud2_level_collect_flag, 'N') = 'Y' then
        l_ud2_found := get_level_pk(p_instance_id, crec_data.ud2_level_id,
                       crec_data.ud2_sr_level_value_pk, crec_data.ud2_level_value, crec_data.ud2_level_value_pk);
    end if;

    /* Get Demand Class LEVEL_PK */
    if nvl(p_cs_rec.dcs_level_collect_flag, 'N') = 'Y' then
        l_dcs_found := get_level_pk(p_instance_id, crec_data.dcs_level_id,
                       crec_data.dcs_sr_level_value_pk, crec_data.dcs_level_value, crec_data.dcs_level_value_pk);
    end if;

    select
        decode(l_prd_found, g_level_pk_not_found, 'PRD ', null) ||
        /* DWK Check level pk of parent item for dependent demand data */
        decode(l_prd_parent_found, g_level_pk_not_found, 'PRD_PARENT ', null) ||
        decode(l_org_found, g_level_pk_not_found, 'ORG ', null) ||
        decode(l_geo_found, g_level_pk_not_found, 'GEO ', null) ||
        decode(l_chn_found, g_level_pk_not_found, 'CHN ', null) ||
        decode(l_rep_found, g_level_pk_not_found, 'REP ', null) ||
        decode(l_ud1_found, g_level_pk_not_found, 'UD1 ', null) ||
        decode(l_ud2_found, g_level_pk_not_found, 'UD2 ', null) ||
        decode(l_dcs_found, g_level_pk_not_found, 'DCS ', null)
    into
        l_comments2
    from
        dual;

    /* Level validation */

    if nvl(p_cs_rec.strict_flag, 'N') = 'Y' then
        /* if level_id is not defined at the definition level then the level_id
           of first record fetched will be used for validation
        */
        if l_first_record then

            l_first_record := FALSE;
/* New */
            if p_cs_rec.prd_level_id is null and nvl(p_cs_rec.prd_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.prd_level_id := crec_data.prd_level_id;
            end if;

            if p_cs_rec.org_level_id is null and nvl(p_cs_rec.org_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.org_level_id := crec_data.org_level_id;
            end if;

            if p_cs_rec.geo_level_id is null and nvl(p_cs_rec.geo_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.geo_level_id := crec_data.geo_level_id;
            end if;

            if p_cs_rec.chn_level_id is null  and nvl(p_cs_rec.chn_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.chn_level_id := crec_data.chn_level_id;
            end if;

            if p_cs_rec.rep_level_id is null and nvl(p_cs_rec.rep_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.rep_level_id := crec_data.rep_level_id;
            end if;

            if p_cs_rec.ud1_level_id is null and nvl(p_cs_rec.ud1_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.ud1_level_id := crec_data.ud1_level_id;
            end if;

            if p_cs_rec.ud2_level_id is null and nvl(p_cs_rec.ud2_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.ud2_level_id := crec_data.ud2_level_id;
            end if;

            if p_cs_rec.tim_level_id is null and nvl(p_cs_rec.tim_level_collect_flag, 'N') = 'Y' then
                /* Attribute_34 is tim_level_id */
                p_cs_rec.tim_level_id := crec_data.tim_level_id;
            end if;

            if p_cs_rec.dcs_level_id is null and nvl(p_cs_rec.dcs_level_collect_flag, 'N') = 'Y' then
                p_cs_rec.dcs_level_id := crec_data.dcs_level_id;
            end if;

        end if;

        Select
            decode(crec_data.prd_level_id,
                   null, decode(p_cs_rec.prd_level_collect_flag,
                                'Y', 'PRD ',
                                 null),
                   p_cs_rec.prd_level_id, null,
                   'PRD ')  ||
            /* DWK  IF dependent demand data are collected, its parents level id should be 1 */
            decode(nvl(crec_data.prd_parent_level_id, '1'), '1', null, 'PRD_PARENT ') ||
            decode(crec_data.org_level_id,
                   null, decode(p_cs_rec.org_level_collect_flag,
                                'Y', 'ORG ',
                                 null),
                   p_cs_rec.org_level_id, null,
                   'ORG ')  ||
            decode(crec_data.geo_level_id,
                   null, decode(p_cs_rec.geo_level_collect_flag,
                                'Y', 'GEO ',
                                 null),
                   p_cs_rec.geo_level_id, null,
                   'GEO ')  ||
            decode(crec_data.rep_level_id,
                   null, decode(p_cs_rec.rep_level_collect_flag,
                                'Y', 'REP ',
                                 null),
                   p_cs_rec.rep_level_id, null,
                   'REP ')  ||
            decode(crec_data.chn_level_id,
                   null, decode(p_cs_rec.chn_level_collect_flag,
                                'Y', 'CHN ',
                                 null),
                   p_cs_rec.chn_level_id, null,
                   'CHN ')  ||
            decode(crec_data.ud1_level_id,
                   null, decode(p_cs_rec.ud1_level_collect_flag,
                                'Y', 'UD1 ',
                                 null),
                   p_cs_rec.ud1_level_id, null,
                   'UD1 ')  ||
            decode(crec_data.ud2_level_id,
                   null, decode(p_cs_rec.ud2_level_collect_flag,
                                'Y', 'UD2 ',
                                 null),
                   p_cs_rec.ud2_level_id, null,
                   'UD2 ')  ||
            decode(crec_data.tim_level_id,
                   null, decode(p_cs_rec.tim_level_collect_flag,
                                'Y', 'TIM ',
                                 null),
                   p_cs_rec.tim_level_id, null,
                   'TIM ')  ||
            decode(crec_data.dcs_level_id,
                   null, decode(p_cs_rec.dcs_level_collect_flag,
                                'Y', 'DCS ',
                                 null),
                   p_cs_rec.dcs_level_id, null,
                   'DCS ' )
        into
            l_comments1
        from  dual;
    ELSE  /* p_cs_rec.strict_flag = 'N' */

       /* Check whether that time level id exists in fnd lookup or not */

       IF ( nvl(p_cs_rec.tim_level_collect_flag, 'N') = 'Y') THEN
          select count(*) into l_count
          from fnd_lookup_values
          where lookup_type = 'MSD_PERIOD_TYPE' and
          nvl(crec_data.tim_level_id, '999.99') = lookup_code and
          rownum <= 1;

          IF ( l_count < 1 ) THEN
             select 'TIM' into l_comments1 from dual;
          END IF;
       END IF;

    END IF;



    /* MSD_CS_DATALOAD_INVALID_LVLID - Invalid Level ID for Dimensions    */
    /* MSD_CS_DATALOAD_INVALID_DIM     - Invalid Dimensions */
    select decode(l_comments2, null, null, 'MSD_CS_DATALOAD_INVALID_DIM : ' || l_comments2) ||
           decode(l_comments1, null, null, 'MSD_CS_DATALOAD_INVALID_LVLID : ' || l_comments1)
    into p_err_mesg
    from dual;

    /* Validate Date Format */
    Begin
        select to_date(crec_data.attribute_43, 'YYYY/MM/DD')
            into l_dummy_date
        from dual;
    Exception
    When others then
        p_err_mesg := p_err_mesg || ' MSD_CS_DATALOAD_INVALID_DATE_FORMAT : ATTRIBUTE_43';
    End;

    /* Validate Amount Number Format */
    Begin
      -- Check Amount
      if (p_cs_rec.measurement_type in (1,3,4)) then
	  l_dummy_number := crec_data.attribute_42;
      end if;
    Exception
    When others then
       p_err_mesg := p_err_mesg || ' MSD_CS_DATALOAD_INVALID_NUMBER_FORMAT : ATTRIBUTE_42';
    End;

    /* Validate Quantity Number Format */
    Begin
      -- Check Quantity
      if (p_cs_rec.measurement_type in (2,4,5)) then
	l_dummy_number := crec_data.attribute_41;
      end if;
    Exception
    When others then
       p_err_mesg := p_err_mesg || ' MSD_CS_DATALOAD_INVALID_NUMBER_FORMAT : ATTRIBUTE_41';
    End;

    /* Validate Price Number Format */
    Begin
      -- Check Price
      if (p_cs_rec.measurement_type in (3,5)) then
	l_dummy_number := crec_data.attribute_44;
      end if;
    Exception
    When others then
       p_err_mesg := p_err_mesg || ' MSD_CS_DATALOAD_INVALID_NUMBER_FORMAT : ATTRIBUTE_44';
    End;

    if p_err_mesg is null then
        return TRUE;
    else
        return FALSE;
    end if;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Function get_level_pk (
    p_instance          in varchar2,
    p_level_id          in number,
    p_sr_level_value_pk in OUT NOCOPY varchar2,
    p_level_value       in OUT NOCOPY varchar2,
    p_level_value_pk    in OUT NOCOPY varchar2) return varchar2 is

    Cursor c1 is
    select level_pk, level_value
    from
        msd_level_values
    where
        instance = p_instance and
        level_id = p_level_id and
        sr_level_pk = p_sr_level_value_pk;

    Cursor c2 is
    select level_pk
    from
        msd_level_values
    where
        instance = p_instance and
        level_id = p_level_id and
        level_value = p_level_value;

    Cursor c3 is
    select sr_level_pk, level_value
    from
        msd_level_values
    where
        instance = p_instance and
        level_id = p_level_id and
        level_pk = p_level_value_pk;

    l_level_pk  varchar2(255):=g_level_pk_not_found;
    l_level_val varchar2(2000);
Begin

--    debug_line('In get_level_pk');
    if p_level_id is null then
       return null;
       /* i.e. no data collected for dimension
       */
    end if;

    if p_instance is null or nvl(p_sr_level_value_pk, nvl(p_level_value, p_level_value_pk)) is null then
        /* insufficient parameters */
        /* l_level_pk := g_level_pk_not_found; */
        return null;
    else
        if p_sr_level_value_pk is not null then
            open c1;
            fetch c1 into l_level_pk, p_level_value;
            if c1%notfound then
                l_level_pk := g_level_pk_not_found;
            end if;
            close c1;
        elsif p_level_value is not null then
            open c2;
            fetch c2 into l_level_pk;
            if c2%notfound then
                l_level_pk := g_level_pk_not_found;
            end if;
            close c2;
        else /* p_level_value_pk is not null */
            open c3;
            fetch c3 into p_sr_level_value_pk, p_level_value;
            if c3%notfound then
                l_level_pk := g_level_pk_not_found;
            else
               l_level_pk := p_level_value_pk;
            end if;
            close c3;
        end if;

    end if;

    if l_level_pk <> g_level_pk_not_found then
      p_level_value_pk := l_level_pk;
    else
        debug_line(' p_instance ' || p_instance || ' p_level_id ' || p_level_id ||
               ' p_sr_level_value_pk ' || p_sr_level_value_pk || ' p_level_value ' || p_level_value ||
               ' p_level_value_pk  ' || p_level_value_pk);
    end if;

    return l_level_pk;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Function Build_Where_Clause (
    p_tokenized_where   in  varchar2,
    p_default_where     in  varchar2,
    p_parameter1        in  varchar2,
    p_parameter2        in  varchar2,
    p_parameter3        in  varchar2,
    p_parameter4        in  varchar2,
    p_parameter5        in  varchar2,
    p_parameter6        in  varchar2,
    p_parameter7        in  varchar2,
    p_parameter8        in  varchar2,
    p_parameter9        in  varchar2,
    p_parameter10       in  varchar2,
    p_request_id        in  number) return varchar2 is

    Type param_list_type is varray(10) of varchar2(255);


    l_para_list param_list_type;
    l_where     varchar2(3000);

    Procedure find_and_subst_param ( p_where_cond  in out NOCOPY varchar2,
                                     p_val             in varchar2,
                                     p_request_id      in number,
                                     p_para_num        in number) is

        start_pos number;
        end_pos   number;
        para_type varchar2(10);

        l_default_col            varchar2(300) := NULL;
        l_count                  number := 0;

        l_dblink                 varchar2(100) := NULL;
        l_retcode	         number := 0;
        l_multi_flag             varchar2(30) := 'N';

--   'CHAR:Prompt_Name:ValueSet_Name:Remote_Yes_No:Multi_Yes_NO:Default_Column_Name_For_Multi'

    Begin
        debug_line('In find_and_subst_param');
        start_pos := instr(p_where_cond, '&&', 1);
        para_type := substr(p_where_cond, start_pos + 2, 7);
        end_pos   := instr(p_where_cond, '''', start_pos);

        if substr(upper(para_type), 1, 5) = 'CHAR:' then /* Character type */
           l_multi_flag :=
               nvl(upper(msd_cs_defn_utl2.get_char_property(p_where_cond, start_pos, end_pos, 4)), 'N');

           l_default_col := msd_cs_defn_utl2.get_char_property(p_where_cond, start_pos, end_pos, 5);

           IF l_multi_flag = 'Y' THEN
             /* If multi input parar then check whether user entered
                any values for the multi input parameters */
              select count(1) into l_count from msd_cs_coll_parameters
                                    where conc_request_id = p_request_id and
                                    parameter_number = p_para_num;
              /* If user hasn't entered any multi input parameters then
                 use user specified default column name */
              IF (l_count = 0 AND l_default_col IS NOT NULL) THEN
                 p_where_cond := substr(p_where_cond, 1, start_pos - 2) ||
                                 l_default_col ||
                                 substr(p_where_cond, end_pos + 1);
              ELSE
                 p_where_cond :=  substr(p_where_cond, 1, start_pos - 2) ||
                               ' (SELECT parameter_code FROM msd_cs_coll_parameters ' ||
                               ' WHERE conc_request_id = ' || p_request_id ||
                               ' AND parameter_number = ' || p_para_num || ' ) ' ||
                               substr(p_where_cond, end_pos + 1);
              END IF;
           ELSE
              p_where_cond := substr(p_where_cond, 1, start_pos - 1) ||
                              replace(p_val, '''', '''''') ||
                              substr(p_where_cond, end_pos);
           END IF;
        elsif substr(upper(para_type), 1, 7) = 'NUMBER:' then /* Number type*/
            p_where_cond := substr(p_where_cond, 1, start_pos - 2) || p_val ||
                            substr(p_where_cond, end_pos + 1);
        elsif substr(upper(para_type), 1, 5) = 'DATE:' then /* Date type */
            p_where_cond := substr(p_where_cond, 1, start_pos - 2) || 'to_date(''' || p_val || ''', ''YYYYMMDD'')' ||
                            substr(p_where_cond, end_pos + 1);
        end if;

debug_line(p_where_cond);

    End;


    Procedure substitute_parameter (
        p_where_cond    in out NOCOPY varchar2,
        p_param_list    in     param_list_type,
        p_request_id    in     number) is

        i number := 1;
    Begin
        debug_line('In substitute_parameter');
       /* DP-CRM Code changes by easwaran */
        while (i < 11 )
        loop
            find_and_subst_param( p_where_cond, p_param_list(i), p_request_id, i);
            i := i + 1;
        end loop;

    End;

    Procedure make_para_list(
        p_parameter1    in     varchar2,
        p_parameter2    in     varchar2,
        p_parameter3    in     varchar2,
        p_parameter4    in     varchar2,
        p_parameter5    in     varchar2,
        p_parameter6    in     varchar2,
        p_parameter7    in     varchar2,
        p_parameter8    in     varchar2,
        p_parameter9    in     varchar2,
        p_parameter10   in     varchar2,
        p_para_list     in out NOCOPY param_list_type) is
    Begin
        debug_line('In make_para_list');
        p_para_list := param_list_type (p_parameter1, p_parameter2, p_parameter3, p_parameter4, p_parameter5,
                                        p_parameter6, p_parameter7, p_parameter8, p_parameter9, p_parameter10);

    End;


Begin
    debug_line('In Build_Where_Clause');
    if p_tokenized_where is not null then
       /*
         convert parameters into an array.
       */
        make_para_list( p_parameter1, p_parameter2, p_parameter3, p_parameter4, p_parameter5,
                        p_parameter6, p_parameter7, p_parameter8, p_parameter9, p_parameter10,
                        l_para_list);

        /* Build additional Where */
        l_where := p_tokenized_where;

        substitute_parameter ( l_where, l_para_list, p_request_id);

    end if;
    if l_where is not null then
        if p_default_where is not null then
            l_where := p_default_where || ' and ' || l_where;
        end if;
    else
        l_where := p_default_where;
    end if;

    return l_where;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure Refresh_Target(
                          p_process_type      in varchar2,
                          p_cs_definition_id  in number,
                          p_cs_name           in varchar2,
                          p_comp_refresh      in varchar2,
                          p_instance_id       in number,
                          p_new_refresh_num   in NUMBER) is

    l_sql_stmt  varchar2(2000);

    cursor C_GET_DEL_CRIT is
    select distinct attribute_1 instance, cs_name
    from msd_st_cs_data
    where cs_definition_id = p_cs_definition_id and
          cs_name = nvl(p_cs_name, cs_name);

    /* DWK  create a separe cursor to fetch instance in single stream case */
    cursor c_get_del_crit_single is
    select distinct attribute_1 instance
    from msd_st_cs_data
    where cs_definition_id = p_cs_definition_id;

    cursor c_multi_stream is
    select nvl(multiple_stream_flag,'N')
    from msd_cs_definitions
    where cs_definition_id = p_cs_definition_id;

    l_multi_flag  VARCHAR2(10);

Begin
    debug_line('In refresh_target');
    if p_comp_refresh = 'Y' then

/*        if p_process_type = C_SOURCE_TO_FACT then
            delete from msd_cs_data where cs_definition_id = p_cs_definition_id
                        and cs_name = nvl(p_cs_name, cs_name) and attribute_1 = nvl(p_instance_id, attribute_1);
*/
        IF p_process_type = C_SOURCE_TO_STAGE then
            delete from msd_st_cs_data where cs_definition_id = p_cs_definition_id
                        and cs_name = nvl(p_cs_name, cs_name) and attribute_1 = nvl(p_instance_id, attribute_1);

        elsif p_process_type = C_STAGE_TO_FACT then
            /* DWK  For single stream, ignore the CS_NAME column for refresh */
            open c_multi_stream;
            fetch c_multi_stream into l_multi_flag;
            close c_multi_stream;

            IF (l_multi_flag = 'Y') THEN
               For l_rec IN c_get_del_crit LOOP
                  UPDATE msd_cs_data
                  SET Action_code = 'D',
                      last_refresh_num = p_new_refresh_num
                  WHERE cs_definition_id = p_cs_definition_id and
                        cs_name = l_rec.cs_name and
                        attribute_1 = l_rec.instance and
                        action_code = 'I';
               END LOOP;

            ELSE    /* For single stream, ignore the cs_name in delete stmt */
               For l_rec IN c_get_del_crit_single LOOP
                  UPDATE msd_cs_data
                  SET Action_code = 'D',
                      last_refresh_num = p_new_refresh_num
                  WHERE cs_definition_id = p_cs_definition_id and
                        attribute_1 = l_rec.instance and
                        action_code = 'I';

               END LOOP;
            END IF;

        end if;   /* End of C_STAGE_TO_FACT */
    else /* Not Complete Refresh
          /* Delete data from staging table to avoid double couting when user runs
           collection source to stage without complete refresh checkbox checked
           This will make custom stream collection behaviour same as other
           collection (Bookking/Shipment)
         */
        IF p_process_type = C_SOURCE_TO_STAGE then
            delete from msd_st_cs_data
                where cs_definition_id = p_cs_definition_id and
                      cs_name = nvl(p_cs_name, cs_name) and
                      attribute_1 = nvl(p_instance_id, attribute_1);
        END IF;
    end if;   /* End of p_comp_refresh Y */

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure Process_1_Sub (
        p_cs_rec        in out NOCOPY  msd_cs_definitions_v1%rowtype,
        p_cs_name           in  varchar2,
        p_source_view       in  varchar2,
        p_target_table      in  varchar2,
        p_instance_id       in  number,
        p_sql_stmt          in  varchar2,
        p_new_refresh_num   IN  NUMBER) is

    TYPE cur_type is REF CURSOR;
    l_cur       cur_type;
    l_rec       msd_cs_dfn_utl.G_TYP_SOURCE_STREAM;

    l_valid     boolean;
    l_err_msg   varchar2(1000);

    l_success_rows  number:=0;
    l_error_rows    number:=0;

    /* Bug# 4349618  To commit in Batches */
    l_counter	    number:=0;
    l_commit_flag   number:=0;

/* DWK */
   l_temp_designator         VARCHAR2(40) := NULL;
   l_temp_instance_id        NUMBER := NULL;

Begin
    debug_line('In Process_1_Sub');

    open l_cur for p_sql_stmt;
    LOOP
        fetch l_cur into l_rec;
        exit when l_cur%notfound;

        l_valid := null;
        l_err_msg := null;

        debug_line('Validating ' || l_rec.pk_id);


        l_valid := validate_record (l_rec, p_cs_rec, nvl(l_rec.instance,p_instance_id), l_err_msg);

        IF l_valid THEN
            /* IMP : Instance is p_instance in case of Collect
                     and l_rec.instance in case of PULLL i.e. from the staging
		     table */
            IF  (p_target_table = 'MSD_CS_DATA') THEN
                ins_row_fact(l_rec, p_cs_rec, l_rec.designator,
                             nvl(p_instance_id, l_rec.instance),
                             p_new_refresh_num);

                /* Insert designator into headers talbe when designator get modified. */
		IF ( l_rec.designator <> nvl(l_temp_designator,'-99999999~!@') OR
		   nvl(p_instance_id,l_rec.instance) <> nvl(l_temp_instance_id,-99999999) ) THEN
		   l_temp_designator  := l_rec.designator;
		   l_temp_instance_id := nvl(p_instance_id,l_rec.instance);

		   /* DWK  Populate MSD_CS_DATA_HEADERS table after inserting rows
		      into FACT table */
		   insert_update_Into_Headers (	p_cs_rec.cs_definition_id,
						l_rec.designator,
						nvl(p_instance_id,l_rec.instance), p_new_refresh_num);
		END IF;
	    ELSE
                ins_row_staging(l_rec, p_cs_rec, l_rec.designator, nvl(p_instance_id, l_rec.instance), null, null);
            END IF;

            /* Mark record Processed */
            log_processed(l_rec, p_cs_rec, l_rec.designator, nvl(p_instance_id, l_rec.instance), p_source_view, p_target_table);

            /* Count Success Rows */
            l_success_rows := l_success_rows + 1;

            /* Bug# 4349618  To commit in Batches */
            l_counter	:= l_counter + 1;

        ELSE   /* IF not Valid */

            /*  Log Error */
            log_error(l_rec, p_cs_rec, l_rec.designator,
                      nvl(p_instance_id, l_rec.instance),
                      l_err_msg, p_source_view, p_target_table);
            /* Count Erroneous Rows */
            l_error_rows := l_error_rows + 1;

            /* Bug# 4349618  To commit in Batches */
            l_counter	:= l_counter + 1;

        END IF;

        /* Bug# 4349618  To commit in Batches */
	SELECT mod( l_counter, C_BATCH_SIZE)
		INTO l_commit_flag
		FROM dual;

	IF l_commit_flag = 0 THEN
		debug_line( 'Inside Process_1_Sub: commiting inside the loop.');
		commit;
	END IF;

    END LOOP;

    /* Bug$ 4349618  To commit in Batches*/
    debug_line( 'Inside Process_1_Sub: commiting after the loop ends.');
    commit;


   if l_error_rows > 0 then
        g_retcode := '1';
        g_errbuf := 'There were erroneous records in Collect/Pull.';
    end if;

    if l_success_rows = 0 and l_error_rows = 0then
        g_retcode := '1';
        g_errbuf := 'There were no rows fetched.';
    end if;

    /* Print Results */

    show_line('Valid Records   : ' || l_success_rows);
    show_line('Invalid Records : ' || l_error_rows);

    close l_cur;

Exception
When others then
    show_line(sqlerrm);
    show_line(p_sql_stmt);
    close l_cur;
    raise;
End;

Function Build_Designator_Where_Clause(
    p_cs_rec        in  msd_cs_definitions_v1%rowtype,
    p_process_type  in  varchar2,
    p_cs_name       in  varchar2) return varchar2 is

    Cursor C1 is
     select source_view_column_name
     from msd_cs_defn_column_dtls
     where
        cs_definition_id = p_cs_rec.cs_definition_id and
        table_column = 'CS_NAME';

    l_where_cond    varchar2(500);
    l_col_name      varchar2(60);

Begin
    debug_Line('In Build_Designator_Where_Clause');

    /* Build filter for designator(cs_name) */
    if p_process_type in (C_STAGE_TO_FACT) then

      if p_cs_name is not null then
          l_where_cond := 'cs_name = ' || '''' || replace(p_cs_name, '''', '''''') || '''';
      end if;
    else
        if nvl(p_cs_rec.multiple_stream_flag, 'N') = 'Y' and p_cs_name is not null then
            open c1;
            fetch c1 into l_col_name;
            close c1;

            if l_col_name is null then
                null;
                /*Raise Error*/
            else
                l_where_cond := l_col_name || ' = ' || '''' || replace(p_cs_name, '''', '''''') || '''';
            end if;
        end if;
    end if;

    /* Add Default Where */
    if p_process_type = C_STAGE_TO_FACT then
        if l_where_cond is not null then
            l_where_cond := l_where_cond || ' and cs_definition_id = ' || p_cs_rec.cs_definition_id;
        else
            l_where_cond := ' cs_definition_id = ' || p_cs_rec.cs_definition_id;
        end if;
    end if;

    return l_where_cond;

Exception
When others then
    show_line(sqlerrm);
    raise;

End;

Procedure debug_line(p_sql in    varchar2)is
Begin
    if c_debug = 'Y' then
        show_line(p_sql);
    end if;
End;

/* DWK */
/*************************************************************************************************
PROCEDURE Insert_update_Into_Headers

This procedure will decide whether insert cs_definition_id, cs_name, and instance into
msd_cs_data_headers table or not and insert row if necessary.
**************************************************************************************************/
Procedure insert_update_Into_Headers (	p_cs_definition_id  in  number,
					p_cs_name           in  varchar2,
					p_instance_id       in  number,
                                        p_refresh_num       in number) is


p_count    NUMBER:=0;

BEGIN

   SELECT count(*) INTO p_count FROM msd_cs_data_headers_v1
   WHERE instance = p_instance_id AND
      cs_definition_id = p_cs_definition_id AND
      cs_name = p_cs_name;

   IF ( p_count = 0 ) THEN
      Insert_Data_Into_Headers (p_cs_definition_id,
				p_cs_name,
				p_instance_id,
                                p_refresh_num);
   ELSE

      update msd_cs_data_headers
      set last_refresh_num = p_refresh_num
      where cs_definition_id = p_cs_definition_id
      and instance = p_instance_id
      and cs_name = p_cs_name;

   END IF;


Exception
When others then
    show_line(sqlerrm);
    raise;

END insert_update_Into_Headers;


/*************************************************************************************************
PROCEDURE Insert_Data_Into_Headers

This procedure will insert cs_definition_id, cs_name, and instance into
msd_cs_data_headers table.
**************************************************************************************************/
Procedure Insert_Data_Into_Headers (	p_cs_definition_id  in  number,
					p_cs_name           in  varchar2,
					p_instance_id       in  number,
                                        p_refresh_num       in  number) is


BEGIN

   INSERT INTO msd_cs_data_headers
	(	CS_DATA_HEADER_ID,
		INSTANCE,
		CS_DEFINITION_ID,
		CS_NAME,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
                LAST_REFRESH_NUM
	)
   VALUES (	msd_cs_data_headers_s.nextval,
		p_instance_id,
		p_cs_definition_id,
		p_cs_name,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.login_id,
                p_refresh_num
	);



Exception
  When others then
    show_line('Error in inserting into MSD_CS_DATA_HEADERS');
    show_line(sqlerrm);
    raise;

END Insert_Data_Into_Headers;

End;

/
