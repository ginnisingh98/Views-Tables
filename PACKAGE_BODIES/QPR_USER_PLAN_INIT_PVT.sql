--------------------------------------------------------
--  DDL for Package Body QPR_USER_PLAN_INIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_USER_PLAN_INIT_PVT" AS
/* $Header: QPRPUSRB.pls 120.0 2007/10/11 13:12:14 agbennet noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='QPR_USER_PLAN_INIT_PVT';

PROCEDURE Initialize
( 	p_api_version           IN	     NUMBER  ,
  	p_init_msg_list		IN	     VARCHAR2,
	p_commit	    	IN  	     VARCHAR2,
        p_validation_level	IN  	     NUMBER	,
        p_user_id               IN           NUMBER  ,
        p_plan_id               IN           NUMBER  ,
        p_event_id              IN           NUMBER  ,
	x_return_status		OUT  NOCOPY  VARCHAR2,
	x_msg_count		OUT  NOCOPY  NUMBER  ,
	x_msg_data		OUT  NOCOPY  VARCHAR2
) IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'Initialize';
l_api_version           	CONSTANT NUMBER 	:= 1.0;
l_valid_inputs                  VARCHAR2(10);
l_return_status                 VARCHAR2(10);
BEGIN
            -- Standard Start of API savepoint
            SAVEPOINT	QPR_USER_PLAN_INITIALIZE;
            -- Standard call to check for call compatibility.
            IF NOT FND_API.Compatible_API_Call (l_api_version ,
        	    	    	    	 	p_api_version ,
   	       	    	 			l_api_name    ,
		    	    	    	    	G_PKG_NAME )
            THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Initialize message list if p_init_msg_list is set to TRUE.
            IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
            END IF;
            --  Initialize API return status to success

            x_return_status := FND_API.G_RET_STS_SUCCESS;

            /* do cursory validation */
            Validate_params (p_event_id         => p_event_id,
                             p_user_id          => p_user_id ,
                             p_plan_id          => p_plan_id ,
                             x_return_status    => l_valid_inputs);
            if (l_valid_inputs <> FND_API.G_RET_STS_SUCCESS) then
                x_return_status := FND_API.G_RET_STS_ERROR;
                raise exc_severe_error;
            end if;

            if (p_event_id = G_INITIALIZE_REPORTS) then
                Initialize_reports (p_user_id, p_plan_id, l_return_status);
                qpr_dashboard_util.create_dashboard_default(p_user_id,p_plan_id,l_return_status);
            elsif (p_event_id = G_MAINTAIN_DATAMART) THEN
                /*if p_event_id = QPR_USER_PLAN_INIT.DATAMART_RELOAD*/
                Reset_report_flags (p_user_id, p_plan_id, l_return_status);
            end if;


          -- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO QPR_USER_PLAN_INITIALIZE;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO QPR_USER_PLAN_INITIALIZE;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO QPR_USER_PLAN_INITIALIZE;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END Initialize;

Procedure Validate_params
(
        p_event_id              IN           NUMBER,
        p_user_id               IN           NUMBER,
        p_plan_id               IN           NUMBER,
        x_return_status         OUT  NOCOPY  VARCHAR2
) IS
Cursor c_valid_user (c_p_user_id number) is
        select user_id
        from fnd_user
        where user_id=c_p_user_id;

Cursor c_valid_plan (c_p_plan_id number) is
        select price_plan_id
        from qpr_price_plans_b
        where price_plan_id = c_p_plan_id;

l_user_id       NUMBER;
l_plan_id       NUMBER;
l_check_user_id BOOLEAN;
l_check_plan_id BOOLEAN;
BEGIN
        open c_valid_user (p_user_id);
        fetch c_valid_user into l_user_id;
        if (c_valid_user%NOTFOUND) then
                l_user_id := NULL;
        end if;
        close c_valid_user;

        open c_valid_plan (p_plan_id);
        fetch c_valid_plan into l_plan_id;
        if (c_valid_plan%NOTFOUND) then
                l_plan_id := NULL;
        end if;
        close c_valid_plan;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        if (p_event_id = G_INITIALIZE_REPORTS) then--{
        /*user_id and plan_id should be not null and valid*/
               l_check_user_id := TRUE;
               l_check_plan_id := TRUE;--}
        elsif (p_event_id = G_MAINTAIN_DATAMART) then--{
        /* plan_id should be not null and valid*/
               l_check_user_id := FALSE;
               l_check_plan_id := TRUE;--}
        else--{
               x_return_status := FND_API.G_RET_STS_ERROR ;
               FND_MESSAGE.Set_Name ('QPR','QPR_API_INVALID_INPUT');
               FND_MESSAGE.Set_Token ('ERROR_TEXT','p_event_id Invalid');
               FND_MSG_PUB.Add;
               raise FND_API.G_EXC_ERROR;--}
        end if;


        if (l_check_user_id) then --{
                if (p_user_id is null) then --{
                        x_return_status := FND_API.G_RET_STS_ERROR ;
                        FND_MESSAGE.Set_Name ('QPR','QPR_API_INVALID_INPUT');
                        FND_MESSAGE.Set_Token ('ERROR_TEXT','p_user_id is NULL');
                        FND_MSG_PUB.Add;
                        raise FND_API.G_EXC_ERROR;--}
                elsif
                (l_user_id is null) then --{
                        x_return_status := FND_API.G_RET_STS_ERROR ;
                        FND_MESSAGE.Set_Name ('QPR','QPR_API_INVALID_INPUT');
                        FND_MESSAGE.Set_Token ('ERROR_TEXT','p_user_id Invalid');
                        FND_MSG_PUB.Add;
                        raise FND_API.G_EXC_ERROR;--}
                end if;--}
        end if;

        if (l_check_plan_id) then--{
                if (p_plan_id is null) then--{
                        x_return_status := FND_API.G_RET_STS_ERROR ;
                        FND_MESSAGE.Set_Name ('QPR','QPR_API_INVALID_INPUT');
                        FND_MESSAGE.Set_Token ('ERROR_TEXT','p_plan_id is NULL');
                        FND_MSG_PUB.Add;
                        raise FND_API.G_EXC_ERROR;--}
                elsif
                (l_plan_id is null) then--{
                        x_return_status := FND_API.G_RET_STS_ERROR ;
                        FND_MESSAGE.Set_Name ('QPR','QPR_API_INVALID_INPUT');
                        FND_MESSAGE.Set_Token ('ERROR_TEXT','p_plan_id Invalid');
                        FND_MSG_PUB.Add;
                        raise FND_API.G_EXC_ERROR;--}
                end if;--}
         end if;
END Validate_params;

Procedure Initialize_reports
(
        p_user_id               IN           NUMBER,
        p_plan_id               IN           NUMBER,
        x_return_status         OUT  NOCOPY  VARCHAR2
) is
BEGIN
        /*
         * fetch all data from QPR_REPORT_TYPE_HDRS_B
         * for user_id=null and plan_id=null
         */
         /*
         * Check for a report entity for that user_id and plan_id and
         * report_header_id in QPR_REPORT_HDRS_B
         *Case 1: If one/more record is found,
         * then update that record's valid_flag='R'
         *
         *Case 2: If no record is found, then create a new report header
         * record with seeded_report_flag='Y' and report_valid_flag='R'
         * and insert into QPR_REPORT_HDRS_B/TL tables
         */


         insert into QPR_REPORT_HDRS_B
         (
           REPORT_HEADER_ID
          ,REPORT_TYPE_HEADER_ID
          ,USER_ID
          ,PLAN_ID
          ,SEEDED_REPORT_FLAG
          ,REPORT_VALID_FLAG
          ,ENABLED_OPTIONS
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_LOGIN
          ,PROGRAM_ID
          ,PROGRAM_LOGIN_ID
          ,PROGRAM_APPLICATION_ID
          ,REQUEST_ID
         )
         select
         qpr_report_hdrs_s.nextval
         ,report_type_header_id
         ,p_user_id
         ,p_plan_id
         ,G_YES
         ,G_REPORT_REFRESH_FLAG
         ,null
         ,sysdate
         ,FND_GLOBAL.user_id
         ,sysdate
         ,FND_GLOBAL.user_id
         ,null
         ,null
         ,null
         ,null
         ,null
         from QPR_REPORT_TYPE_HDRS_B rth
         where
                rth.user_id is null
            and rth.plan_id is null
            and not exists
                ( select 1
                  from QPR_REPORT_HDRS_B rh
                  where rh.user_id = p_user_id
                    and rh.plan_id = p_plan_id
                    and rh.report_type_header_id = rth.report_type_header_id );

         insert into qpr_report_hdrs_tl
         (
           REPORT_HEADER_ID
          ,REPORT_NAME
          ,REPORT_TITLE
          ,LANGUAGE
          ,SOURCE_LANG
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_LOGIN
          ,PROGRAM_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_LOGIN_ID
          ,REQUEST_ID
         )
         select
                 RHB.report_header_id
                ,QL.meaning
                ,RTH.report_type_name||'-'||QL.meaning
                ,L.LANGUAGE_CODE
                ,userenv('LANG')
                ,sysdate
                ,FND_GLOBAL.user_id
                ,sysdate
                ,FND_GLOBAL.user_id
                ,null
                ,null
                ,null
                ,null
                ,null
           from QPR_REPORT_HDRS_B RHB,
                qpr_report_type_hdrs_tl RTH,
                FND_LANGUAGES L,
                QPR_LOOKUPS QL
          where L.INSTALLED_FLAG in ('I', 'B')
            and QL.Lookup_type = 'QPR_REPORT_TITLE_SUFFIX'
            and QL.Lookup_code = 'DEFVW'
            and RTH.language = l.language_code
            and RHB.report_type_header_id = RTH.report_type_header_id
            and not exists
	       (select null
                  from qpr_report_hdrs_tl RHT
                where RHT.report_header_id = RHB.report_header_id
                  and RHT.LANGUAGE = L.LANGUAGE_CODE);


       insert into qpr_report_lines
       (
        REPORT_LINE_ID
       ,REPORT_HEADER_ID
       ,REPORT_TYPE_LINE_ID
       ,REPORT_LINE_NAME
       ,FOLDER
       ,REPORT_LINE_VALID_FLAG
       ,DISPLAY_SEQUENCE
       ,REPORT_SVG
       ,ENABLED_OPTIONS
       ,CREATION_DATE
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
       ,PROGRAM_ID
       ,PROGRAM_LOGIN_ID
       ,PROGRAM_APPLICATION_ID
       ,REQUEST_ID
       )
       select
                qpr_report_lines_s.nextval report_line_id
               ,rhb.report_header_id
               ,rtl.report_type_line_id
               ,rtl.report_type_line_name
               ,qpr_user_plan_init_pvt.g_folder_name
               ,G_REPORT_REFRESH_FLAG
               ,rta.report_display_sequence
               ,null
               ,null
               ,sysdate
               ,FND_GLOBAL.user_id
               ,sysdate
               ,FND_GLOBAL.user_id
               ,null
               ,null
               ,null
               ,null
               ,null
       from
        QPR_REPORT_HDRS_B rhb,
        QPR_REPORT_TYPE_ASGN rta,
        qpr_report_type_lines rtl
       where
            rta.report_type_header_id = rhb.report_type_header_id
        and rtl.report_type_line_id = rta.report_type_line_id
        and rhb.report_header_id not in
                (select report_header_id
                  from  qpr_report_lines rl1
                 );

END Initialize_reports;

Procedure Reset_report_flags
(
        p_user_id               IN            NUMBER,
        p_plan_id               IN            NUMBER,
        x_return_status         OUT  NOCOPY   VARCHAR2
) IS
BEGIN
        /*
         * for the given plan_id, update all report entities
         * with valid_flag='R'
         */
         if (p_user_id is not null) then --{
         update QPR_REPORT_HDRS_B rh
            set report_valid_flag = G_REPORT_REFRESH_FLAG
          where rh.user_id = p_user_id
            and rh.plan_id = p_plan_id;

          update qpr_report_lines rl
            set report_line_valid_flag = G_REPORT_REFRESH_FLAG
          where rl.report_header_id in
                        (select report_header_id
                          from  QPR_REPORT_TYPE_HDRS_B rth
                          where rth.user_id = p_user_id
                          and rth.plan_id = p_plan_id
                         );--}
         else--{
         update QPR_REPORT_HDRS_B rh
            set report_valid_flag = G_REPORT_REFRESH_FLAG
          where rh.plan_id = p_plan_id;

          update qpr_report_lines rl
            set report_line_valid_flag = G_REPORT_REFRESH_FLAG
          where rl.report_header_id in
                        (select report_header_id
                           from QPR_REPORT_HDRS_B rh
                            where rh.plan_id = p_plan_id
                        );--}
         end if;
END Reset_report_flags;

END QPR_USER_PLAN_INIT_PVT;


/
