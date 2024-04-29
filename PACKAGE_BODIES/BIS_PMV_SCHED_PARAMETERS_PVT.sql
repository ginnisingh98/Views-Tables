--------------------------------------------------------
--  DDL for Package Body BIS_PMV_SCHED_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_SCHED_PARAMETERS_PVT" as
/* $Header: BISVSCPB.pls 115.3 2003/11/21 05:41:19 nkishore noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE


procedure saveParameters
(pRegionCode       in varchar2,
 pFunctionName     in varchar2,
 pPageId           in Varchar2 default null,
 pSessionId        in Varchar2 default null,
 pUserId           in Varchar2 default null,

 pResponsibilityId in Varchar2 default null,
 pOrgParam         in number   default 0,
 pParameter1       in varchar2 default null,
 pParameterValue1  in varchar2 default null,
 pParameter2       in varchar2 default null,
 pParameterValue2  in varchar2 default null,
 pParameter3       in varchar2 default null,
 pParameterValue3  in varchar2 default null,
 pParameter4       in varchar2 default null,
 pParameterValue4  in varchar2 default null,
 pParameter5       in varchar2 default null,
 pParameterValue5  in varchar2 default null,
 pParameter6       in varchar2 default null,
 pParameterValue6  in varchar2 default null,
 pParameter7       in varchar2 default null,
 pParameterValue7  in varchar2 default null,
 pParameter8       in varchar2 default null,
 pParameterValue8  in varchar2 default null,
 pParameter9       in varchar2 default null,
 pParameterValue9  in varchar2 default null,
 pParameter10      in varchar2 default null,
 pParameterValue10 in varchar2 default null,
 pParameter11      in varchar2 default null,
 pParameterValue11 in varchar2 default null,
 pParameter12      in varchar2 default null,
 pParameterValue12 in varchar2 default null,
 pParameter13      in varchar2 default null,
 pParameterValue13 in varchar2 default null,
 pParameter14      in varchar2 default null,
 pParameterValue14 in varchar2 default null,
 pParameter15      in varchar2 default null,
 pParameterValue15 in varchar2 default null,
 pTimeParameter    in varchar2 default null,
 pTimeFromParameter in varchar2 default null,
 pTimeToParameter  in varchar2 default null,
 pViewByValue	   in varchar2 default null,
 pAsOfDateValue        in varchar2 default null,
 pAsOfDateMode         in varchar2 default null,
 pSaveByIds            in varchar2 default 'N',
  pScheduleId       in varchar2 default null,
 x_return_status    out NOCOPY VARCHAR2,
 x_msg_count	    out NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2
)
is
       l_parameter_rec         BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
        l_parameter_Rec_tbl     BIS_PMV_PARAMETERS_PVT.parameter_tbl_type;
        l_user_Session_rec      BIS_PMV_SESSION_PVT.session_rec_type;
        l_time_parameter_rec    BIS_PMV_PARAMETERS_PVT.TIME_PARAMETER_REC_TYPE;
        l_count                 NUMBER;
        l_asof_Date             DATE;
        l_Start_Date            DATE;
        l_End_date              DATE;
        l_time_level_id         VARCHAR2(2000);
        l_time_level_value      VARCHAR2(2000);
        l_time_comparison_type  VARCHAR2(2000) := null;
        l_time_comp_const       VARCHAR2(200) := 'TIME_COMPARISON_TYPE';
        l_canonical_date_format VARCHAR2(30) :='DD/MM/YYYY';
        l_prev_asof_Date        date;
        l_current_report_start_date     date;
        l_prev_report_start_Date       date;
        lAsOfDateValue date;
        cursor c_asof_date is
        select period_date
        from bis_user_attributes
        where schedule_id=pScheduleId and
        attribute_name = 'AS_OF_DATE';
begin
  FND_MSG_PUB.INITIALIZE;
        l_user_session_rec.function_name := pFunctionNAme;
        l_user_session_rec.region_code := pRegionCode;
        l_user_session_rec.page_id := pPageId;
        l_user_session_rec.session_id := pSessionId;
        l_user_Session_rec.user_id := pUserId;
        l_user_Session_rec.schedule_id := pScheduleId;
        l_user_session_rec.responsibility_id := pResponsibilityId;
         l_parameter_rec.parameter_name := pParameter1;
        l_parameter_rec.dimension := substr(pParameter1,1, instr(pParameter1,'+')-1);
        l_parameter_rec.parameter_description := pParameterValue1;
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
         l_parameter_rec_tbl(1) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter2;
        l_parameter_rec.dimension := substr(pParameter2,1, instr(pParameter2,'+')-1);
        l_parameter_rec.parameter_description := pParameterValue2;
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(2) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter3;
        l_parameter_rec.parameter_description := pParameterValue3;
        l_parameter_rec.dimension := substr(pParameter3,1, instr(pParameter3,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
         l_parameter_rec_tbl(3) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter4;
        l_parameter_rec.parameter_description := pParameterValue4;
        l_parameter_rec.dimension := substr(pParameter4,1, instr(pParameter4,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
         l_parameter_rec_tbl(4) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter5;
        l_parameter_rec.parameter_description := pParameterValue5;
        l_parameter_rec.dimension := substr(pParameter5,1, instr(pParameter5,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(5) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter6;
        l_parameter_rec.parameter_description := pParameterValue6;
        l_parameter_rec.dimension := substr(pParameter6,1, instr(pParameter6,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(6) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter7;
        l_parameter_rec.parameter_description := pParameterValue7;
        l_parameter_rec.dimension := substr(pParameter7,1, instr(pParameter7,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(7) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter8;
        l_parameter_rec.parameter_description := pParameterValue8;
        l_parameter_rec.dimension := substr(pParameter8,1, instr(pParameter8,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(8) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter9;
        l_parameter_rec.parameter_description := pParameterValue9;
        l_parameter_rec.dimension := substr(pParameter9,1, instr(pParameter9,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(9) := l_parameter_rec;
         l_parameter_rec.parameter_name := pParameter10;
        l_parameter_rec.parameter_description := pParameterValue10;
         l_parameter_rec.dimension := substr(pParameter10,1, instr(pParameter10,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(10) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter11;
        l_parameter_rec.parameter_description := pParameterValue11;
        l_parameter_rec.dimension := substr(pParameter11,1, instr(pParameter11,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
         l_parameter_rec_tbl(11) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter12;
        l_parameter_rec.parameter_description := pParameterValue12;
        l_parameter_rec.dimension := substr(pParameter12,1, instr(pParameter12,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
         l_parameter_rec_tbl(12) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter13;
        l_parameter_rec.parameter_description := pParameterValue13;
        l_parameter_rec.dimension := substr(pParameter13,1, instr(pParameter13,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(13) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter14;
        l_parameter_rec.parameter_description := pParameterValue14;
        l_parameter_rec.dimension := substr(pParameter14,1, instr(pParameter14,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(14) := l_parameter_rec;
        l_parameter_rec.parameter_name := pParameter15;
        l_parameter_rec.parameter_description := pParameterValue15;
        l_parameter_rec.dimension := substr(pParameter15,1, instr(pParameter15,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
        l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(15) := l_parameter_rec;
        if (pViewByValue is not null) then
	        l_parameter_rec.parameter_name := 'VIEW_BY';
            l_parameter_rec.parameter_description := pViewByValue;
	        l_parameter_rec.hierarchy_flag := 'N';
	        l_count := l_count+1;
            l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if ;
        create_Schedule_parameters(p_user_param_tbl => l_parameter_rec_tbl
                                 ,p_user_session_rec => l_user_session_rec
                                 ,x_return_Status => x_return_Status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_Data  => x_msg_Data);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                ROLLBACK;
    	  	RETURN;
        END IF;


       IF (pTimeFromParameter = 'DBC_TIME') then
           IF (c_asof_date%ISOPEN) then
               CLOSE c_asof_date;
           END IF;
           OPEN c_asof_date;
           FETCH c_asof_date into l_asof_date;
           close c_asof_Date;
           IF l_asof_date is null then
              IF (pAsOfDateValue is null) then
                 lAsOFDateValue := SYSDATE;
              ELSE
                lAsOFDateValue := to_date(pAsOfDateValue, 'DD/MM/YYYY');
              END IF;
              l_parameter_rec.parameter_name := 'AS_OF_DATE';
              IF (pAsOfDateMode = 'NEXT') then
                 l_asof_date := lAsOfDateValue+1;
                 --As of Date Enh 3094234-- Change to Canonical dates
                 --l_parameter_rec.parameter_description := to_char(l_asof_date,'DD-MON-YYYY');
                 --l_parameter_rec.parameter_value := to_char(l_asof_date,'DD-MON-YYYY');
                 l_parameter_rec.parameter_description := to_char(l_asof_date,l_canonical_date_format);
                 l_parameter_rec.parameter_value := to_char(l_asof_date,l_canonical_date_format);
               ELSIF (pAsOFDateMode = 'PREVIOUS') then
                  l_asof_date := lAsOfDateValue-1;
                  --l_parameter_rec.parameter_description := to_char(l_asof_Date,'DD-MON-YYYY');
                  --l_parameter_rec.parameter_value := to_char(l_asof_date,'DD-MON-YYYY');
                  l_parameter_rec.parameter_description := to_char(l_asof_Date,l_canonical_date_format);
                  l_parameter_rec.parameter_value := to_char(l_asof_date,l_canonical_date_format);
               ELSIF (pAsOfDateMode = 'CURRENT'  or pAsOfDateMode is null) then
                   l_asof_Date := lAsOfDateValue;
                   --l_parameter_Rec.parameter_description := to_char(l_asof_date,'DD-MON-YYYY');
                   --l_parameter_rec.parameter_value := to_char(l_asof_date,'DD-MON-YYYY');
                   l_parameter_Rec.parameter_description := to_char(l_asof_date,l_canonical_date_format);
                   l_parameter_rec.parameter_value := to_char(l_asof_date,l_canonical_date_format);
              END IF;
              l_parameter_Rec.default_flag := 'N';
              l_parameter_rec.hierarchy_flag := 'N';
              BIS_PMV_SCHED_PARAMETERS_PVT.CREATE_PARAMETER
                      (p_user_session_rec => l_user_session_rec
                      ,p_parameter_rec => l_parameter_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
               IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                   ROLLBACK;
    	           RETURN;
               END IF;
            END IF;
         END IF;
	IF (pTimePArameter IS NOT NULL) THEN
           IF (pTimeFromParameter = 'DBC_TIME') then
              --get the information for the current period
              BIS_PMV_TIME_LEVELS_PVT.GET_TIME_LEVEL_INFO(p_dimensionlevel => pTimeParameter,
                      p_region_code    => pregioncode,
                      p_Responsibility_id => presponsibilityid,
                      p_Asof_date      => l_asof_date,
                      p_mode           => 'GET_CURRENT',
                      x_time_level_id  => l_time_level_id,
                      x_time_level_value => l_time_level_Value,
                      x_Start_date       => l_start_date,
                      x_end_date         => l_end_date,
                      x_return_Status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data
                     );
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                          ROLLBACK;
  	  	          RETURN;
                END IF;
                l_parameter_rec.dimension := substr(pTimeParameter,1, instr(pTimeParameter,'+')-1);
                l_parameter_rec.default_flag := 'N';
                l_parameter_rec.parameter_name := ptimeparameter || '_FROM';
                l_parameter_rec.parameter_description := l_time_level_Value;
                l_parameter_rec.period_date := l_start_Date;
                l_parameter_Rec.parameter_Value := l_time_level_id;
                --create the "from" record
                BIS_PMV_SCHED_PARAMETERS_PVT.CREATE_PARAMETER (
                                 p_user_session_rec => l_user_session_rec
                                 ,p_parameter_rec => l_parameter_rec
                                 ,x_return_status => x_return_status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_data => x_msg_data);
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                       ROLLBACK;
            	  	RETURN;
                END IF;
                l_parameter_rec.default_flag := 'N';
                l_parameter_rec.parameter_name := ptimeparameter || '_TO';
                l_parameter_rec.parameter_description := l_time_level_Value;
                l_parameter_rec.period_date := l_end_Date;
                l_parameter_Rec.parameter_Value := l_time_level_id;

                --create the "to" record
                BIS_PMV_SCHED_PARAMETERS_PVT.CREATE_PARAMETER
                                 (p_user_session_rec => l_user_session_rec
                                 ,p_parameter_rec => l_parameter_rec
                                 ,x_return_status => x_return_status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_data => x_msg_data);
                --Store the Previous As Of Date as well
                 BIS_PMV_TIME_LEVELS_PVT.GET_PREVIOUS_ASOF_DATE
                 ( p_DimensionLevel        =>   pTimePArameter
                ,p_time_comparison_type  =>   l_time_comparison_Type
                ,p_asof_date             =>   l_Asof_date
                ,x_prev_asof_Date        =>   l_prev_asof_Date
                ,x_Return_status         =>   x_return_Status
                ,x_msg_count             =>   x_msg_count
                ,x_msg_data              =>   x_msg_data
                 );
                l_parameter_rec.dimension := null;
                l_parameter_rec.default_flag := 'N';
                l_parameter_Rec.parameter_name := 'BIS_P_ASOF_DATE';
                --l_parameter_rec.parameter_description := to_char(l_prev_asof_date,'DD-MON-YYYY');
                --l_parameter_rec.parameter_value := to_char(l_prev_asof_date,'DD-MON-YYYY');
                l_parameter_rec.parameter_description := to_char(l_prev_asof_date,l_canonical_date_format);
                l_parameter_rec.parameter_value := to_char(l_prev_asof_date,l_canonical_date_format);

                BIS_PMV_SCHED_PARAMETERS_PVT.CREATE_PARAMETER (
                                  p_user_session_rec => l_user_session_rec
                                  ,p_parameter_rec => l_parameter_rec
                                  ,x_return_status => x_return_status
                                  ,x_msg_count => x_msg_count
                                  ,x_msg_data => x_msg_data);
                --Get the values for the previous report start date and current report start date and store them
                 BIS_PMV_TIME_LEVELS_PVT.GET_REPORT_START_DATE
                (p_time_comparison_type => l_time_comparison_type
                ,p_asof_date            => l_asof_date
                ,p_time_level           => pTimeParameter
                ,x_report_start_date    => l_current_report_start_date
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                );
                l_parameter_rec.dimension := null;
                l_parameter_rec.default_flag := 'N';
                l_parameter_Rec.parameter_name := 'BIS_CUR_REPORT_START_DATE';
                --l_parameter_rec.parameter_description := to_char(l_current_report_start_date,'DD-MON-YYYY');
                --l_parameter_rec.parameter_value := to_char(l_current_report_start_date,'DD-MON-YYYY');
                l_parameter_rec.parameter_description := to_char(l_current_report_start_date,l_canonical_date_format);
                l_parameter_rec.parameter_value := to_char(l_current_report_start_date,l_canonical_date_format);

                BIS_PMV_SCHED_PARAMETERS_PVT.CREATE_PARAMETER (
                  p_user_session_rec => l_user_session_rec
                                  ,p_parameter_rec => l_parameter_rec
                                  ,x_return_status => x_return_status
                                  ,x_msg_count => x_msg_count
                                  ,x_msg_data => x_msg_data);
                 BIS_PMV_TIME_LEVELS_PVT.GET_REPORT_START_DATE
                (p_time_comparison_type => l_time_comparison_type
                ,p_asof_date            => l_prev_asof_date
                ,p_time_level           => pTimeParameter
                ,x_report_start_date    => l_prev_report_start_date
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                );
                l_parameter_rec.dimension := null;
                l_parameter_rec.default_flag := 'N';
                l_parameter_Rec.parameter_name := 'BIS_PREV_REPORT_START_DATE';
                --l_parameter_rec.parameter_description := to_char(l_prev_report_start_date,'DD-MON-YYYY');
                --l_parameter_rec.parameter_value := to_char(l_prev_report_start_date,'DD-MON-YYYY');
                l_parameter_rec.parameter_description := to_char(l_prev_report_start_date,l_canonical_date_format);
                l_parameter_rec.parameter_value := to_char(l_prev_report_start_date,l_canonical_date_format);

                BIS_PMV_SCHED_PARAMETERS_PVT.CREATE_PARAMETER (
                                  p_user_session_rec => l_user_session_rec
                                  ,p_parameter_rec => l_parameter_rec
                                  ,x_return_status => x_return_status
                                  ,x_msg_count => x_msg_count
                                  ,x_msg_data => x_msg_data);


                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                        ROLLBACK;
            	  	RETURN;
                END IF;
           end if;
         end if;
         COMMIT;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

end;
PROCEDURE CREATE_SCHEDULE_PARAMETERS
(p_user_param_tbl       IN      BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status        OUT     NOCOPY VARCHAR2
,x_msg_count            OUT     NOCOPY NUMBER
,x_msg_data             OUT     NOCOPY VARCHAR2
)
IS
    l_user_param_tbl        BIS_PMV_PARAMETERS_PVT.parameter_tbl_type;
BEGIN
 IF p_user_param_tbl.COUNT > 0 THEN
  l_useR_param_Tbl := p_user_param_Tbl;
      FOR i in 1..p_user_param_tbl.COUNT LOOP
        IF (l_user_param_tbl(i).parameter_name IS NOT NULL ) THEN
             BIS_PMV_SCHED_PARAMETERS_PVT.VALIDATE_AND_SAVE
                          (p_user_session_rec => p_user_session_rec
                          ,p_parameter_rec => l_user_param_tbl(i)
                          ,x_return_status => x_return_status
                          ,x_msg_count => x_msg_count
                          ,x_msg_Data => x_msg_data);
        END IF;
      END LOOP;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END;
PROCEDURE VALIDATE_AND_SAVE
(p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec        IN      OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status        OUT     NOCOPY VARCHAR2
,x_msg_count            OUT     NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_valid varchar2(2);
 BEGIN
   if (substr(p_parameter_rec.parameter_name,1,length('TIME_COMPARISON_TYPE')) = 'TIME_COMPARISON_TYPE') then
     p_parameter_rec.parameter_name := p_parameter_rec.parameter_description;
     p_parameter_rec.parameter_value := p_parameter_Rec.parameter_description;
     l_valid := 'Y';
  elsif instr(p_parameter_rec.parameter_description, '^~]*') > 0 then
     l_valid := 'Y';
  --BugFix#2577374 -ansingh
  elsif (p_parameter_rec.parameter_value='-1') then
        p_parameter_rec.parameter_description := FND_MESSAGE.get_string('BIS','BIS_UNASSIGNED'
);
        l_valid := 'Y';
  elsif (upper(p_parameter_rec.parameter_description) = upper(FND_MESSAGE.get_string('BIS','BIS_UNASSIGNED')))
  then
        p_parameter_rec.parameter_value := '-1';
        l_valid := 'Y';

  else
     BIS_PMV_PARAMETERS_PVT.VALIDATE_NONTIME_PARAMETER (p_user_session_rec => p_user_session_rec
                             ,p_parameter_rec => p_parameter_rec
                             ,x_valid => l_valid
                             ,x_return_status => x_return_status
                             ,x_msg_count => x_msg_count
                             ,x_msg_data => x_msg_data);
  end if;
  IF l_valid = 'Y' THEN
      BIS_PMV_SCHED_PARAMETERS_PVT.CREATE_PARAMETER (p_user_session_rec => p_user_session_rec
                      ,p_parameter_rec => p_parameter_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END;
PROCEDURE CREATE_PARAMETER
(p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec        IN      BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_Data         OUT NOCOPY VARCHAR2
)
IS
  l_parameter_name VARCHAR2(32000) := p_parameter_rec.parameter_name;
  l_parameter_value VARCHAR2(32000) := p_parameter_rec.parameter_value;
  l_parameter_description VARCHAR2(32000) := p_parameter_rec.parameter_description;
  l_index number := 0;
  l_dimension VARCHAR2(80) := p_parameter_rec.dimension;
BEGIN
 if l_dimension is null then
     l_index := instr(l_parameter_name,'+');
     IF l_index > 0 THEN
        l_dimension := substr(l_parameter_name,1,l_index-1);
     END IF;
  end if;
 INSERT INTO BIS_USER_ATTRIBUTES (user_id, schedule_id, attribute_name, function_name,
                                      session_id, session_value, session_description,
                                      period_date, dimension, operator,
                                      creation_date, created_by,
                                      last_update_Date, last_updated_by)
                              VALUES (p_user_session_rec.user_id, p_user_session_rec.schedule_id,
                                      l_parameter_name,
                                      p_user_session_rec.function_name, p_user_session_rec.session_id,
                                      l_parameter_value, l_parameter_description,
                                      p_parameter_rec.period_date, l_dimension,
                                      p_parameter_rec.operator,
                                      sysdate, -1, sysdate, -1);
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END;
end;

/
