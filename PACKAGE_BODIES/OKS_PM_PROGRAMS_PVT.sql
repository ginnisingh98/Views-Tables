--------------------------------------------------------
--  DDL for Package Body OKS_PM_PROGRAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_PM_PROGRAMS_PVT" AS
/* $Header: OKSRPMPB.pls 120.13 2007/12/24 10:21:51 rriyer ship $ */

PROCEDURE  GENERATE_SCHEDULE(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_periods               IN NUMBER,
    p_start_date            IN DATE,
    p_end_date              IN DATE,
    p_duration              IN NUMBER,
    p_period                IN VARCHAR2,
    p_first_sch_date        IN DATE,
    x_periods               OUT NOCOPY NUMBER,
    x_last_date             OUT NOCOPY DATE,
    x_pms_tbl               OUT NOCOPY pms_tbl_type) IS

  l_api_version		               CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	               CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	               VARCHAR2(1);
  l_msg_count		               NUMBER;
  l_msg_data		               VARCHAR2(2000):=null;
  l_msg_index_out                  Number;
  l_api_name                       CONSTANT VARCHAR2(30) := 'generate schedule';
  l_schedule_date                   DATE;
  i                                 NUMBER;
  l_period_ctr                      NUMBER := p_periods;
-----------------------------------------
BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


     i:=1;
--     l_schedule_date            := nvl(p_first_sch_date,okc_time_util_pub.get_enddate(p_start_date,p_period,p_duration));
     l_schedule_date            := p_first_sch_date;


     if trunc(l_schedule_date) >= trunc(p_end_date) then
        l_schedule_date := p_end_date;
     end if;


     x_pms_tbl(i).schedule_date := l_schedule_date;
     x_last_date                := l_schedule_date;
     x_periods                  := 1;
     if l_period_ctr is not null then
        l_period_ctr               := l_period_ctr - 1;
     end if;

     IF trunc(l_schedule_date) <> trunc(p_end_date) THEN

      LOOP

        l_schedule_date := okc_time_util_pub.get_enddate(l_schedule_date+1,p_period,p_duration);

        if trunc(l_schedule_date) > trunc(p_end_date) OR
        (l_period_ctr is not null AND l_period_ctr = 0 ) then
            exit;
        else
            x_periods    := x_periods + 1;
            if l_period_ctr is not null then
                l_period_ctr               := l_period_ctr - 1;
            end if;
            i:=i+1;
            x_pms_tbl(i).schedule_date :=l_schedule_date;
            x_last_date := l_schedule_date;
        end if;

      END LOOP;

     END IF;

     IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;

      x_return_status         := l_return_status;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status ;


 WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;
 END generate_schedule;




/*--for upgrade from Phase I
PROCEDURE update_pmp_rule_id(p_api_version                   IN NUMBER,
                                   p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                 OUT NOCOPY VARCHAR2,
                                   x_msg_count                     OUT NOCOPY NUMBER,
                                   x_msg_data                      OUT NOCOPY VARCHAR2)
IS
  CURSOR  cu_pm_schedule IS
  select
        pms.id,
        to_number(pml.object1_id1) pmp_rule_id
  from
        okc_rules_b pml,
        oks_pm_schedules pms
  where
        rule_information_category ='PML'
        and pml.id =pms.rule_id;
  l_pms_tbl_in  oks_pms_pvt.oks_pm_schedules_v_tbl_type;
  l_pms_tbl_out oks_pms_pvt.oks_pm_schedules_v_tbl_type;
  l_api_version                  CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_POPULATE_ACTIVITIES';

  l_return_status	    VARCHAR2(1);
  l_msg_count		    NUMBER;
  l_msg_data		    VARCHAR2(2000);
  l_init_msg_list	               CONSTANT	VARCHAR2(1):= 'F';

   ctr NUMBER;
BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    ctr :=1;
    FOR cr_pm_schedule IN cu_pm_schedule LOOP
        l_pms_tbl_in(ctr).id            := cr_pm_schedule.id;
        l_pms_tbl_in(ctr).pmp_rule_id   := cr_pm_schedule.pmp_rule_id;
        ctr := ctr+1;
    END LOOP;
      OKS_PMS_PVT.update_row(
      p_api_version	=> l_api_version,
      p_init_msg_list	=> l_init_msg_list,
      x_return_status 	=> l_return_status ,
      x_msg_count		=> l_msg_count ,
      x_msg_data		=> l_msg_data  ,
      p_oks_pm_schedules_v_tbl => l_pms_tbl_in,
      x_oks_pm_schedules_v_tbl =>l_pms_tbl_out);
 x_return_status:= OKC_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
    ROLLBACK ;
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK ;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      ROLLBACK ;
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END update_pmp_rule_id;
*/

 PROCEDURE  CREATE_PM_PROGRAM_SCHEDULE
       (p_api_version     IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_template_cle_id       IN NUMBER,
        p_cle_id                IN NUMBER,
        p_cov_start_date        IN DATE,
        p_cov_end_date          IN DATE) --instantiated line id)
 IS
  --CK RUL


  CURSOR cu_line IS
  SELECT
       id,object_version_number,dnz_chr_id
       from oks_k_lines_b
       where cle_id=p_cle_id;
  cr_line cu_line%ROWTYPE;
  CURSOR cu_activities IS
    SELECT
        ID,
        ACTIVITY_ID,
        SELECT_YN,
        CONF_REQ_YN,
        SCH_EXISTS_YN,
--02/13        PROGRAM_ID,
        CLE_ID
        DNZ_CHR_ID
    FROM
        OKS_PM_ACTIVITIES_V
    WHERE cle_id= p_template_cle_id;
    cr_activities cu_activities%ROWTYPE;

  CURSOR cu_prog_stream_levels IS
    SELECT
         SEQUENCE_NUMBER ,
        NUMBER_OF_OCCURENCES   ,
        START_DATE     ,
        END_DATE       ,
        FREQUENCY ,
        FREQUENCY_UOM      ,
        OFFSET_DURATION ,
        OFFSET_UOM,
        AUTOSCHEDULE_YN,
--02/13        PROGRAM_ID ,
        ACTIVITY_LINE_ID,
        CLE_ID
        DNZ_CHR_ID
    FROM
        oks_pm_stream_levels_v
    WHERE cle_id = p_template_cle_id
    AND ACTIVITY_LINE_ID is null
    ORDER by SEQUENCE_NUMBER;
    cr_prog_stream_levels cu_prog_stream_levels%ROWTYPE;

    CURSOR cu_act_stream_levels(cp_activity_line_id IN NUMBER) IS
    SELECT
         SEQUENCE_NUMBER ,
        NUMBER_OF_OCCURENCES   ,
        START_DATE     ,
        END_DATE       ,
        FREQUENCY ,
        FREQUENCY_UOM      ,
        OFFSET_DURATION ,
        OFFSET_UOM,
        AUTOSCHEDULE_YN,
--02/13        PROGRAM_ID ,
        ACTIVITY_LINE_ID,
        CLE_ID
        DNZ_CHR_ID
    FROM
        oks_pm_stream_levels_v
    WHERE cle_id = p_template_cle_id
    AND ACTIVITY_LINE_ID = cp_ACTIVITY_LINE_ID
        ORDER by SEQUENCE_NUMBER;
    cr_act_stream_levels cu_act_stream_levels%ROWTYPE;
-- Added part of 12.0 to validate the PM program exist before generating schedule
CURSOR CU_CHECK_PM_PROGRAM_EXIST IS
   SELECT pm_program_id
   FROM OKS_K_LINES_B
   WHERE CLE_ID = p_template_cle_id;
    CR_CHECK_PM_PROGRAM_EXIST CU_CHECK_PM_PROGRAM_EXIST%ROWTYPE;

-- Added by jvorugan for Bug:5080930
 cursor get_max_seq_no is
 select max(to_number(SEQUENCE_NUMBER))
 from  oks_pm_stream_levels_V
 where cle_id =p_template_cle_id
 and ACTIVITY_LINE_ID is null;

 cursor get_max_act_seq_no(cp_activity_line_id IN NUMBER) is
 select max(to_number(SEQUENCE_NUMBER))
 from oks_pm_stream_levels_V
 where cle_id = p_template_cle_id
 and ACTIVITY_LINE_ID = cp_ACTIVITY_LINE_ID;

 cursor check_renew(p_target_chr_id NUMBER)is
  SELECT 'Y'
  FROM okc_operation_instances op,
       okc_class_operations cls,
       okc_subclasses_b sl,
       okc_operation_lines ol
  WHERE ol.subject_chr_id = p_target_chr_id
  And   op.id = ol.oie_id
  AND   op.cop_id = cls.id
  And   cls.cls_code = sl.cls_code
  And   sl.code = 'SERVICE'
  And   cls.opn_code in ('RENEWAL')
  AND ROWNUM=1;

 --End by Jvorugan for bug:5080930
--------------------------------------------------------
  l_pms_tbl               pms_tbl_type;
  l_row_cnt                 NUMBER;
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	VARCHAR2(1) := 'S';
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000):=null;
  l_duration        number;
  l_timeunit        varchar2(30);
  --
  l_pmlrulvrec_Out 	oks_pml_pvt.pmlv_rec_type;
  l_pmarulv_tbl_out  oks_pma_pvt.pmav_tbl_type;
  l_pmschvtbl_In    OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschvtbl_Out   OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  --
  l_pmarulvrec_Out 	oks_pma_pvt.pmav_rec_type;
  l_pmarulvrec_In 	oks_pma_pvt.pmav_rec_type;
  l_pmarulv_tbl 	oks_pma_pvt.pmav_tbl_type;


  l_Rule_Id	NUMBER;
  l_pmlrulv_tbl   oks_pml_pvt.pmlv_tbl_type;
  l_pmlrulv_tbl_out   oks_pml_pvt.pmlv_tbl_type;
  l_klnv_tbl_in      oks_kln_pvt.klnv_tbl_type;
  l_klnv_tbl_out     oks_kln_pvt.klnv_tbl_type;
  l_sort_ret_status	VARCHAR2(1) := 'S';
  x_sch_ret_status	VARCHAR2(1) := 'S';
  x_periods         NUMBER;
  x_pms_tbl         pms_tbl_type;
  l_start_date          DATE;
  x_last_date       DATE;
  l_first_sch_date  DATE;
  l_sch_end_date    DATE;
  l_pmarule_id              number := null;
  l_pml_lastpmarule_id      number := null;
  l_tmppmarule_id           number := null;
  pma_ctr   NUMBER ;
  pml_ctr   NUMBER;
  l_chr_id NUMBER;
  l_line_id NUMBER;
  l_obj_version_number NUMBER;
  l_seq_max_length      NUMBER;
  l_seq_act_max_length  NUMBER;
  l_check_renew         varchar2(1):='N';
  l_periods             NUMBER;
BEGIN
IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.Set_Indentation('Create_PM_Program_Schedule');
		okc_debug.log('Entered Create_PM_Program_Schedule', 3);
END IF;

OPEN CU_CHECK_PM_PROGRAM_EXIST;
FETCH CU_CHECK_PM_PROGRAM_EXIST INTO CR_CHECK_PM_PROGRAM_EXIST;
IF CU_CHECK_PM_PROGRAM_EXIST%NOTFOUND then
 raise G_EXCEPTION_HALT_VALIDATION;
end if;

OPEN CU_LINE;
LOOP
FETCH CU_LINE INTO CR_LINE;
EXIT WHEN CU_LINE%NOTFOUND;
l_line_id      :=  cr_line.id;
l_chr_id    :=  cr_line.dnz_chr_id;
l_obj_version_number := cr_line.object_version_number;
END LOOP;
CLOSE CU_LINE;

-- Added by Jvorugan for Bug:5080930
   open check_renew(l_chr_id);
   fetch check_renew into l_check_renew;
   Close check_renew;

   IF l_check_renew = 'Y' THEN
        open get_max_seq_no;
        fetch get_max_seq_no into l_seq_max_length;
        close get_max_seq_no;
   END IF;
-- End of changes by Jvorugan for Bug:5080930

l_start_date := p_cov_start_date;
--CK RUL Create     program stream levels and schedules
    pml_ctr :=1;
    FOR cr_prog_stream_levels IN cu_prog_stream_levels LOOP
        l_pmlrulv_tbl(pml_ctr).SEQUENCE_NUMBER      :=  cr_prog_stream_levels.SEQUENCE_NUMBER;
        l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES :=  cr_prog_stream_levels.NUMBER_OF_OCCURENCES;
        l_pmlrulv_tbl(pml_ctr).START_DATE           :=  cr_prog_stream_levels.START_DATE;
        l_pmlrulv_tbl(pml_ctr).END_DATE             :=  cr_prog_stream_levels.END_DATE;
        l_pmlrulv_tbl(pml_ctr).FREQUENCY            :=  cr_prog_stream_levels.FREQUENCY;
        l_pmlrulv_tbl(pml_ctr).FREQUENCY_UOM        :=  cr_prog_stream_levels.FREQUENCY_UOM;
        l_pmlrulv_tbl(pml_ctr).OFFSET_DURATION      :=  cr_prog_stream_levels.OFFSET_DURATION;
        l_pmlrulv_tbl(pml_ctr).OFFSET_UOM           :=  cr_prog_stream_levels.OFFSET_UOM;
        l_pmlrulv_tbl(pml_ctr).AUTOSCHEDULE_YN      :=  cr_prog_stream_levels.AUTOSCHEDULE_YN;
--02/13        l_pmlrulv_tbl(pml_ctr).PROGRAM_ID           :=  cr_prog_stream_levels.PROGRAM_ID;
        l_pmlrulv_tbl(pml_ctr).CLE_ID               :=  p_cle_id;
        l_pmlrulv_tbl(pml_ctr).DNZ_CHR_ID               :=  l_chr_id;
--CK 08/15        pml_ctr :=pml_ctr+1;
-- CK RUL
--CK RUL     l_start_date := p_cov_start_date;
        l_pmlrulv_tbl(pml_ctr).START_DATE           :=  l_start_date;



         l_first_sch_date := nvl(okc_time_util_pub.get_enddate(l_start_date,
                                                     l_pmlrulv_tbl(pml_ctr).offset_uom,
                                                     l_pmlrulv_tbl(pml_ctr).offset_duration) + 1, l_start_date);
         l_duration     := NULL;
         l_timeunit     := NULL;

--The following if handles the case where the template offset may give a first schedule date beyond coverage end date
--In such case, the new offset and duration is calculated and first schedule date is coverage end date

         IF ((l_pmlrulv_tbl(pml_ctr).offset_uom IS NOT NULL) and
            (l_pmlrulv_tbl(pml_ctr).offset_duration IS NOT NULL) and
            (trunc(l_first_sch_date) >= trunc(p_cov_end_date)))  THEN

             l_first_sch_date := trunc(p_cov_end_date);

             okc_time_util_pub.get_duration(
                            p_start_date    => l_start_date,
                            p_end_date      => l_first_sch_date - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

            IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

         END IF;
/* This handles the following scenario -In the else, if the number of occurences (period) for
     the last stream level in template may be null*/
         IF to_number(l_pmlrulv_tbl(pml_ctr).number_of_occurences) IS NOT NULL THEN

           l_sch_end_date   :=  okc_time_util_pub.get_enddate(l_first_sch_date,
                                                     l_pmlrulv_tbl(pml_ctr).frequency_uom,
                                                     to_number(l_pmlrulv_tbl(pml_ctr).frequency)*
                                                     to_number(l_pmlrulv_tbl(pml_ctr).number_of_occurences));

           IF  trunc(l_sch_end_date) >= trunc(p_cov_end_date) then
              l_sch_end_date := trunc(p_cov_end_date);
           end if;

         ELSE
               l_sch_end_date := trunc(p_cov_end_date);
         END IF;
                 l_pmlrulv_tbl(pml_ctr).END_DATE             :=  l_sch_end_date;

        -- Added by Jvorugan for Bug:5080930
	l_periods :=  to_number(l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES);
        IF l_check_renew ='Y'
        THEN
          IF to_number(l_pmlrulv_tbl(pml_ctr).SEQUENCE_NUMBER) = nvl(l_seq_max_length,0) THEN
             l_periods :=NULL;
          END IF;
        END IF;
	-- End of changes by Jvorugan
         x_pms_tbl.DELETE;
          GENERATE_SCHEDULE(
                p_api_version           =>  l_api_version,
                p_init_msg_list         =>  l_init_msg_list,
                x_return_status         =>  x_sch_ret_status,
                x_msg_count             =>  l_msg_count,
                x_msg_data              =>  l_msg_data,
                p_periods               =>  l_periods,   --Nodified by Jvorugan for Bug:5080930 to_number(l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES),
                p_start_date            =>  p_cov_start_date,
                p_end_date              =>  p_cov_end_date,
                p_duration              =>  to_number(l_pmlrulv_tbl(pml_ctr).FREQUENCY),
                p_period                =>  l_pmlrulv_tbl(pml_ctr).FREQUENCY_UOM,
                p_first_sch_date        =>  l_first_sch_date,
                x_periods               =>  x_periods,
                x_last_date             =>  x_last_date,
                x_pms_tbl               =>  x_pms_tbl);

        IF NOT x_sch_ret_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES := x_periods;
        -- Added by Jvorugan for Bug:5191017
	IF l_check_renew ='Y'
        THEN
           IF to_number(l_pmlrulv_tbl(pml_ctr).number_of_occurences) IS NOT NULL THEN

              l_sch_end_date   :=  okc_time_util_pub.get_enddate(l_first_sch_date,
                                                     l_pmlrulv_tbl(pml_ctr).frequency_uom,
                                                     to_number(l_pmlrulv_tbl(pml_ctr).frequency)*
                                                     to_number(l_pmlrulv_tbl(pml_ctr).number_of_occurences));

              if  trunc(l_sch_end_date) >= trunc(p_cov_end_date) then
                  l_sch_end_date := trunc(p_cov_end_date);
              end if;

           ELSE
               l_sch_end_date := trunc(p_cov_end_date);
           END IF;
                 l_pmlrulv_tbl(pml_ctr).END_DATE             :=  l_sch_end_date;
        END IF;
	-- End of changes by Jvorugan


    --Insert program stream levels
     oks_pml_pvt.insert_row(
        p_api_version       => l_api_version,
        p_init_msg_list     => l_init_msg_list,
        x_return_status     =>l_return_status,
        x_msg_count         =>l_msg_count,
        x_msg_data          =>l_msg_data,
        p_pmlv_rec          =>l_pmlrulv_tbl(pml_ctr),
        x_pmlv_rec           =>l_pmlrulvrec_Out);
        IF (G_DEBUG_ENABLED = 'Y') THEN
            okc_debug.log('After oks_pml_pvt insert_row', 3);
        END IF;

       IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
         THEN
             OKC_API.set_message
             (G_APP_NAME,
              G_REQUIRED_VALUE,
              G_COL_NAME_TOKEN,
              'create program stream levels');
          Raise G_EXCEPTION_HALT_VALIDATION;
       END IF;
        l_pmschvtbl_In.delete;
        l_pmschvtbl_Out.delete; --CK 09/02
       --Populate program schedules table of record
       FOR j in x_pms_tbl.FIRST..x_pms_tbl.LAST LOOP
             l_pmschvtbl_In(j).id                             := okc_p_util.raw_to_number(sys_guid()) ;
--02/13             l_pmschvtbl_In(j).program_id                   := l_pmlrulvrec_Out.program_id;
             l_pmschvtbl_In(j).object_version_number          := l_pmlrulvrec_out.object_version_number;
             l_pmschvtbl_In(j).dnz_chr_id                     := l_pmlrulvrec_out.dnz_chr_id;
             l_pmschvtbl_In(j).cle_id                         := p_cle_id;
             l_pmschvtbl_In(j).sch_sequence                   := j;
             l_pmschvtbl_In(j).schedule_date                  := x_pms_tbl(j).schedule_date;
             l_pmschvtbl_In(j).schedule_date_from             := NULL;
             l_pmschvtbl_In(j).schedule_date_to               := NULL;
             l_pmschvtbl_In(j).stream_line_id                       := l_pmlrulvrec_Out.id;
          END LOOP;
       -- Insert program schedules
               OKS_PMS_PVT.insert_row
               (p_api_version                  => l_api_version,
              	p_init_msg_list			       => l_init_msg_list,
                x_return_status			       => l_return_status,
                x_msg_count				       => l_msg_count,
                x_msg_data				       => l_msg_data,
                p_oks_pm_schedules_v_tbl       => l_pmschvtbl_In,
                x_oks_pm_schedules_v_tbl       => l_pmschvtbl_Out);
              IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After OKS_PMS_PVT insert_row', 3);
              END IF;
              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
               THEN
                OKC_API.set_message
                (G_APP_NAME,
                 G_REQUIRED_VALUE,
                 G_COL_NAME_TOKEN,
                 'create program schedules ');

               Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;
        --Update schedule exists as'Y'
              IF  l_return_status = OKC_API.G_RET_STS_SUCCESS AND
                  pml_ctr = l_pmlrulv_tbl.FIRST THEN
                    init_oks_k_line(l_klnv_tbl_in);
                    l_klnv_tbl_in(1).id                       := l_line_id;
                    l_klnv_tbl_in(1).object_version_number    := l_obj_version_number;
                    l_klnv_tbl_in(1).PM_SCH_EXISTS_YN            :=  'Y';

                    OKS_CONTRACT_LINE_PUB.UPDATE_LINE(p_api_version   => l_api_version,
                                           	 p_init_msg_list => l_init_msg_list,
                                             x_return_status => l_return_status,
                                             x_msg_count	 => l_msg_count,
                                             x_msg_data		 => l_msg_data,
                                             p_klnv_tbl      => l_klnv_tbl_in,
                                             x_klnv_tbl      => l_klnv_tbl_out,
                                             p_validate_yn   => 'N');
                      IF (G_DEBUG_ENABLED = 'Y') THEN
                        okc_debug.log('After OKS_CONTRACT_LINE_PUB UPDATE_LINE', 3);
                      END IF;

                        IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS   THEN
                        OKC_API.set_message
                        (G_APP_NAME,
                         G_REQUIRED_VALUE,
                         G_COL_NAME_TOKEN,
                        'update Oks_k_lines_b ');

                       Raise G_EXCEPTION_HALT_VALIDATION;
                      END IF;

                END IF;

            pml_ctr :=pml_ctr+1;
            l_start_date :=l_sch_end_date +1;
            --CK 09/02
            IF  trunc(l_sch_end_date) >= trunc(p_cov_end_date) then
                  exit;
            END IF;
    END LOOP;
/*CK RUL       -- Insert program schedules
               OKS_PMS_PVT.insert_row
               (p_api_version                  => l_api_version,
              	p_init_msg_list			       => l_init_msg_list,
                x_return_status			       => l_return_status,
                x_msg_count				       => l_msg_count,
                x_msg_data				       => l_msg_data,
                p_oks_pm_schedules_v_tbl       => l_pmschvtbl_In,
                x_oks_pm_schedules_v_tbl       => l_pmschvtbl_Out);


              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
               THEN
                OKC_API.set_message
                (G_APP_NAME,
                 G_REQUIRED_VALUE,
                 G_COL_NAME_TOKEN,
                 'create program schedules ');

               Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;
*/

    --CK RUL Create activities
    pma_ctr :=1;
    pml_ctr :=1;
--    l_pmarulv_tbl.delete;
    FOR cr_activities IN cu_activities LOOP
        l_pmarulv_tbl(pma_ctr).ACTIVITY_ID      := cr_activities.ACTIVITY_ID;
        l_pmarulv_tbl(pma_ctr).SELECT_YN        := cr_activities.SELECT_YN;
        l_pmarulv_tbl(pma_ctr).CONF_REQ_YN      := cr_activities.CONF_REQ_YN;
        l_pmarulv_tbl(pma_ctr).SCH_EXISTS_YN    := cr_activities.SCH_EXISTS_YN;
--02/13        l_pmarulv_tbl(pma_ctr).PROGRAM_ID       := cr_activities.PROGRAM_ID;
        l_pmarulv_tbl(pma_ctr).CLE_ID           := p_cle_id;
        l_pmarulv_tbl(pma_ctr).DNZ_CHR_ID       := l_chr_id;
        --

/*CK 09/27        oks_pma_pvt.insert_row(
        p_api_version       => l_api_version,
        p_init_msg_list     => l_init_msg_list,
        x_return_status     =>l_return_status,
        x_msg_count         =>l_msg_count,
        x_msg_data          =>l_msg_data,
        p_pmav_rec          =>l_pmarulv_tbl(pma_ctr),
        x_pmav_rec           =>l_pmarulvrec_Out);
        IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
          THEN
             OKC_API.set_message
             (G_APP_NAME,
              G_REQUIRED_VALUE,
              G_COL_NAME_TOKEN,
              'create pm activities');

          Raise G_EXCEPTION_HALT_VALIDATION;
        END IF;*/
--CK 08/18
        pml_ctr :=1;
        l_start_date := p_cov_start_date;
        OPEN cu_act_stream_levels(cr_activities.id);
        LOOP
        FETCH cu_act_stream_levels INTO      cr_act_stream_levels;
         IF cu_act_stream_levels%FOUND THEN
        --update pm activities with schedule exists
             l_pmarulv_tbl(pma_ctr).SCH_EXISTS_YN    := 'Y';
             EXIT;
        END IF;

        EXIT WHEN cu_act_stream_levels%NOTFOUND;
        END LOOP;
        CLOSE cu_act_stream_levels;
             oks_pma_pvt.insert_row(
            p_api_version       => l_api_version,
            p_init_msg_list     => l_init_msg_list,
            x_return_status     =>l_return_status,
            x_msg_count         =>l_msg_count,
            x_msg_data          =>l_msg_data,
            p_pmav_rec          =>l_pmarulv_tbl(pma_ctr),
            x_pmav_rec           =>l_pmarulvrec_Out);
            IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pma_pvt insert_row', 3);
            END IF;
            IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
              THEN
                 OKC_API.set_message
                 (G_APP_NAME,
                  G_REQUIRED_VALUE,
                  G_COL_NAME_TOKEN,
                  'create pm activities');

              Raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
-- Added by Jvorugan for Bug:5080930
	IF l_check_renew = 'Y' THEN
        open get_max_act_seq_no(cr_activities.id);
        fetch get_max_act_seq_no into l_seq_act_max_length;
        close get_max_act_seq_no;
	END IF;
-- End of changes by Jvorguan

        FOR cr_act_stream_levels IN cu_act_stream_levels(cr_activities.id) LOOP

            l_pmlrulv_tbl(pml_ctr).SEQUENCE_NUMBER      :=  cr_act_stream_levels.SEQUENCE_NUMBER;
            l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES :=  cr_act_stream_levels.NUMBER_OF_OCCURENCES;
            l_pmlrulv_tbl(pml_ctr).START_DATE           :=  cr_act_stream_levels.START_DATE;
            l_pmlrulv_tbl(pml_ctr).END_DATE             :=  cr_act_stream_levels.END_DATE;
            l_pmlrulv_tbl(pml_ctr).FREQUENCY            :=  cr_act_stream_levels.FREQUENCY;
            l_pmlrulv_tbl(pml_ctr).FREQUENCY_UOM        :=  cr_act_stream_levels.FREQUENCY_UOM;
            l_pmlrulv_tbl(pml_ctr).OFFSET_DURATION      :=  cr_act_stream_levels.OFFSET_DURATION;
            l_pmlrulv_tbl(pml_ctr).OFFSET_UOM           :=  cr_act_stream_levels.OFFSET_UOM;
            l_pmlrulv_tbl(pml_ctr).AUTOSCHEDULE_YN      :=  cr_act_stream_levels.AUTOSCHEDULE_YN;
            l_pmlrulv_tbl(pml_ctr).ACTIVITY_LINE_ID     :=  l_pmarulvrec_Out.Id;
--02/12            l_pmlrulv_tbl(pml_ctr).PROGRAM_ID           :=  cr_act_stream_levels.PROGRAM_ID;
            l_pmlrulv_tbl(pml_ctr).CLE_ID               :=  p_cle_id;

            l_pmlrulv_tbl(pml_ctr).DNZ_CHR_ID           :=  l_chr_id;
--CK RUL             l_start_date := p_cov_start_date;
           l_pmlrulv_tbl(pml_ctr).START_DATE           :=  l_start_date;



         l_first_sch_date := nvl(okc_time_util_pub.get_enddate(l_start_date,
                                                     l_pmlrulv_tbl(pml_ctr).offset_uom,
                                                     l_pmlrulv_tbl(pml_ctr).offset_duration) + 1, l_start_date);
         l_duration     := NULL;
         l_timeunit     := NULL;

         IF ((l_pmlrulv_tbl(pml_ctr).offset_uom IS NOT NULL) and
            (l_pmlrulv_tbl(pml_ctr).offset_duration IS NOT NULL) and
            (trunc(l_first_sch_date) >= trunc(p_cov_end_date)))  THEN

             l_first_sch_date := trunc(p_cov_end_date);

             okc_time_util_pub.get_duration(
                            p_start_date    => l_start_date,
                            p_end_date      => l_first_sch_date - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

            IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

         END IF;

         IF to_number(l_pmlrulv_tbl(pml_ctr).number_of_occurences) IS NOT NULL THEN

           l_sch_end_date   :=  okc_time_util_pub.get_enddate(l_first_sch_date,
                                                     l_pmlrulv_tbl(pml_ctr).frequency_uom,
                                                     to_number(l_pmlrulv_tbl(pml_ctr).frequency)*
                                                     to_number(l_pmlrulv_tbl(pml_ctr).number_of_occurences));

           IF  trunc(l_sch_end_date) >= trunc(p_cov_end_date) then
              l_sch_end_date := trunc(p_cov_end_date);
           end if;

         ELSE
               l_sch_end_date := trunc(p_cov_end_date);
         END IF;
                 l_pmlrulv_tbl(pml_ctr).END_DATE             :=  l_sch_end_date;

--Added by Jvorugan for bug:5080930
	l_periods :=  to_number(l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES);
        IF l_check_renew ='Y'
        THEN
          IF to_number(l_pmlrulv_tbl(pml_ctr).SEQUENCE_NUMBER) = nvl(l_seq_act_max_length,0) THEN
             l_periods :=NULL;
          END IF;
        END IF;
-- End of changes by Jvorugan

                 x_pms_tbl.DELETE; --CK 09/02

         GENERATE_SCHEDULE(
                p_api_version           =>  l_api_version,
                p_init_msg_list         =>  l_init_msg_list,
                x_return_status         =>  x_sch_ret_status,
                x_msg_count             =>  l_msg_count,
                x_msg_data              =>  l_msg_data,
                p_periods               =>  l_periods, -- Modified by Jvorugan for Bug:5080930 to_number(l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES),
                p_start_date            =>  p_cov_start_date,
                p_end_date              =>  p_cov_end_date,
                p_duration              =>  to_number(l_pmlrulv_tbl(pml_ctr).FREQUENCY),
                p_period                =>  l_pmlrulv_tbl(pml_ctr).FREQUENCY_UOM,
                p_first_sch_date        =>  l_first_sch_date,
                x_periods               =>  x_periods,
                x_last_date             =>  x_last_date,
                x_pms_tbl               =>  x_pms_tbl);
              IF NOT x_sch_ret_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES := x_periods;
        -- Added by Jvorugan for Bug:5511803
	IF l_check_renew ='Y'
        THEN
           IF to_number(l_pmlrulv_tbl(pml_ctr).NUMBER_OF_OCCURENCES) IS NOT NULL THEN

              l_sch_end_date   :=  okc_time_util_pub.get_enddate(l_first_sch_date,
                                                     l_pmlrulv_tbl(pml_ctr).frequency_uom,
                                                     to_number(l_pmlrulv_tbl(pml_ctr).frequency)*
                                                     to_number(l_pmlrulv_tbl(pml_ctr).number_of_occurences));

              if  trunc(l_sch_end_date) >= trunc(p_cov_end_date) then
                  l_sch_end_date := trunc(p_cov_end_date);
              end if;

           ELSE
               l_sch_end_date := trunc(p_cov_end_date);
           END IF;
                 l_pmlrulv_tbl(pml_ctr).END_DATE             :=  l_sch_end_date;
        END IF;
	-- End of changes by Jvorugan


        oks_pml_pvt.insert_row(
        p_api_version       => l_api_version,
        p_init_msg_list     => l_init_msg_list,
        x_return_status     =>l_return_status,
        x_msg_count         =>l_msg_count,
        x_msg_data          =>l_msg_data,
        p_pmlv_rec          =>l_pmlrulv_tbl(pml_ctr),
        x_pmlv_rec           =>l_pmlrulvrec_Out);
        IF (G_DEBUG_ENABLED = 'Y') THEN
              okc_debug.log('After act oks_pml_pvt insert_row', 3);
        END IF;
       IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
         THEN
             OKC_API.set_message
             (G_APP_NAME,
              G_REQUIRED_VALUE,
              G_COL_NAME_TOKEN,
              'create activity stream levels');
          Raise G_EXCEPTION_HALT_VALIDATION;
       END IF;
       l_pmschvtbl_In.delete;
       l_pmschvtbl_Out.delete; --

       FOR j in x_pms_tbl.FIRST..x_pms_tbl.LAST LOOP
             l_pmschvtbl_In(j).id                             := okc_p_util.raw_to_number(sys_guid()) ;
       --02/12      l_pmschvtbl_In(j).program_id                     := l_pmlrulvrec_Out.program_id;
             l_pmschvtbl_In(j).object_version_number          := l_pmlrulvrec_out.object_version_number;
             l_pmschvtbl_In(j).dnz_chr_id                     := l_pmlrulvrec_out.dnz_chr_id;
             l_pmschvtbl_In(j).cle_id                         := p_cle_id;
             l_pmschvtbl_In(j).sch_sequence                   := j;
             l_pmschvtbl_In(j).schedule_date                  := x_pms_tbl(j).schedule_date;
             l_pmschvtbl_In(j).schedule_date_from             := NULL;
             l_pmschvtbl_In(j).schedule_date_to               := NULL;
             l_pmschvtbl_In(j).stream_line_id                       := l_pmlrulvrec_Out.id;
             l_pmschvtbl_In(j).activity_line_id                       := l_pmarulvrec_Out.id;
          END LOOP;
               OKS_PMS_PVT.insert_row
               (p_api_version                  => l_api_version,
              	p_init_msg_list			       => l_init_msg_list,
                x_return_status			       => l_return_status,
                x_msg_count				       => l_msg_count,
                x_msg_data				       => l_msg_data,
                p_oks_pm_schedules_v_tbl       => l_pmschvtbl_In,
                x_oks_pm_schedules_v_tbl       => l_pmschvtbl_Out);

            IF (G_DEBUG_ENABLED = 'Y') THEN
                  okc_debug.log('After act OKS_PMS_PVT insert_row', 3);
            END IF;
              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
               THEN
                OKC_API.set_message
                (G_APP_NAME,
                 G_REQUIRED_VALUE,
                 G_COL_NAME_TOKEN,
                 'create activity schedules ');

               Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;

/*ck 09/27
                oks_pma_pvt.update_row(
                p_api_version       => l_api_version,
                p_init_msg_list     => l_init_msg_list,
                x_return_status     =>l_return_status,
                x_msg_count         =>l_msg_count,
                x_msg_data          =>l_msg_data,
                p_pmav_rec          =>l_pmarulv_tbl(pma_ctr),
                x_pmav_rec           =>l_pmarulvrec_Out);
                IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
                THEN
                OKC_API.set_message
                (G_APP_NAME,
                 G_REQUIRED_VALUE,
                G_COL_NAME_TOKEN,
                'UPDATE pm activities');

            Raise G_EXCEPTION_HALT_VALIDATION;
            END IF;
*/
              pml_ctr :=pml_ctr+1;
              l_start_date :=l_sch_end_date +1;
              IF  trunc(l_sch_end_date) >= trunc(p_cov_end_date) then
                  exit;
              END IF;

        END LOOP;

        pma_ctr :=pma_ctr+1;
    END LOOP;
/*       -- Insert act schedules
               OKS_PMS_PVT.insert_row
               (p_api_version                  => l_api_version,
              	p_init_msg_list			       => l_init_msg_list,
                x_return_status			       => l_return_status,
                x_msg_count				       => l_msg_count,
                x_msg_data				       => l_msg_data,
                p_oks_pm_schedules_v_tbl       => l_pmschvtbl_In,
                x_oks_pm_schedules_v_tbl       => l_pmschvtbl_Out);


              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
               THEN
                OKC_API.set_message
                (G_APP_NAME,
                 G_REQUIRED_VALUE,
                 G_COL_NAME_TOKEN,
                 'create activity schedules ');

               Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;

*/

  IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Create_PM_Program_Schedule', 3);
		okc_debug.Reset_Indentation;
  END IF;
  x_return_status       := l_return_status;
  x_msg_count           := l_msg_count;
  x_msg_data            := l_msg_data;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status ;
      IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Create_PM_Program_Schedule'||l_return_Status, 3);
		okc_debug.Reset_Indentation;
      END IF;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;
        IF (G_DEBUG_ENABLED = 'Y') THEN
		    okc_debug.log('Exiting Create_PM_Program_Schedule'||sqlerrm, 3);
    		okc_debug.Reset_Indentation;
        END IF;
END CREATE_PM_PROGRAM_SCHEDULE;



PROCEDURE REFRESH_PM_PROGRAM_SCHEDULE
       (p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_cov_tbl               IN okc_contract_pub.clev_tbl_type,
        p_pmlrulv_tbl           IN oks_pml_pvt.pmlv_tbl_type,
        x_pmlrulv_tbl           OUT NOCOPY oks_pml_pvt.pmlv_tbl_type,
        x_pmschv_tbl            OUT NOCOPY pmsch_refresh_tbl_type)-- OKS_PMS_PVT.oks_pm_schedules_v_tbl_type)
 IS

  l_pms_tbl                             pms_tbl_type;
  l_api_version		                    CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	                    CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	                    VARCHAR2(1);
  l_msg_count		                    NUMBER;
  l_msg_data		                    VARCHAR2(4000):='msg_data: ';
  l_pmschvtbl_In                        pmsch_refresh_tbl_type; --OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;

  l_Rule_Id	                            NUMBER;

  l_pmlrulv_tbl                         oks_pml_pvt.pmlv_tbl_type;
  l_pmlrulv_tbl_out                     oks_pml_pvt.pmlv_tbl_type;
  l_pmlrulv_tbl_02                      oks_pml_pvt.pmlv_tbl_type;
  l_sort_ret_status	                    VARCHAR2(1) := 'S';
  x_sch_ret_status	                    VARCHAR2(1) := 'S';
  x_periods                             NUMBER;
  x_pms_tbl                             pms_tbl_type;
  l_start_date                          DATE;
  x_last_date                           DATE;
  l_first_sch_date                      DATE;
  l_sch_end_date                        DATE;
  g_pml_end_date                        DATE;
  i                                     NUMBER := 0;
  j                                     NUMBER := 0;
  k                                     NUMBER := 0;
  pmlout_ctr                            NUMBER := 0;
  l_duration                            number;
  l_timeunit                            varchar2(30);


  PROCEDURE Sort_PML_seq
    (P_Input_Tab          IN  oks_pml_pvt.pmlv_tbl_type
    ,X_Output_Tab         OUT NOCOPY oks_pml_pvt.pmlv_tbl_type
    ,X_Return_Status   	  OUT NOCOPY VARCHAR2)  IS

    Lx_Sort_Tab          oks_pml_pvt.pmlv_tbl_type:= P_Input_Tab;
    Lx_Return_Status      VARCHAR2(1) := 'S';

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_Seq           oks_pml_pvt.pmlv_rec_type;

    Lv_Composit_Val1      NUMBER;
    Lv_Composit_Val2      NUMBER;

  BEGIN

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Composit_Val1  := to_number(Lx_Sort_Tab(Li_TableIdx_Out).SEQUENCE_NUMBER);
        Lv_Composit_Val2  := to_number(Lx_Sort_Tab(Li_TableIdx_In).SEQUENCE_NUMBER);

        IF Lv_Composit_Val1 > Lv_Composit_Val2 THEN

          Lx_Temp_Seq                   := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_Seq;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN OTHERS THEN

      X_Return_Status    := 'U';

  END Sort_PML_seq;

BEGIN

-- UI already checks if Stream level(PML rule) effectivities are not overlapping.
-- Sorting to Check  for gaps in Stream level(PML rule) effectivities
     --  l_msg_data := l_msg_data||'p_pmlrulv_tbl.COUNT'||'; ';
    IF p_pmlrulv_tbl.COUNT > 1 then

       Sort_PML_seq
       (P_Input_Tab          => p_pmlrulv_tbl
       ,X_Output_Tab         => l_pmlrulv_tbl
       ,X_Return_Status   	 => l_sort_ret_status);


       IF NOT l_sort_ret_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
--       l_msg_data := l_msg_data||'Sort_PML_StDt : '||l_sort_ret_status||'; ';

     ELSIF p_pmlrulv_tbl.COUNT = 1 then
         l_pmlrulv_tbl := p_pmlrulv_tbl;
     END IF;

--     Checking  for gaps in Stream level(PML rule) effectivities

/* Commented for Bug # 6152133 (FP Bug for 6114565) */
  /*   FOR i in  l_pmlrulv_tbl.FIRST..l_pmlrulv_tbl.FIRST LOOP

         IF i = 1 THEN
            g_pml_end_date := to_date(l_pmlrulv_tbl(i).END_DATE,'YYYY/MM/DD');
         ELSE
            IF  (to_date(l_pmlrulv_tbl(i).START_DATE,'YYYY/MM/DD') - g_pml_end_date) > 1 THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION; -- return with error
            ELSE
                    g_pml_end_date := to_date(l_pmlrulv_tbl(i).END_DATE,'YYYY/MM/DD');
            END IF;
         END IF;

     END LOOP;
  */
/* Comment Ends */
     l_start_date := p_cov_tbl(1).start_date;


     FOR i in l_pmlrulv_tbl.FIRST..l_pmlrulv_tbl.LAST LOOP


         l_first_sch_date := nvl(okc_time_util_pub.get_enddate(l_start_date,
                                                     l_pmlrulv_tbl(i).OFFSET_UOM,
                                                     l_pmlrulv_tbl(i).OFFSET_DURATION) + 1,l_start_date);

         l_duration     := NULL;
         l_timeunit     := NULL;

         IF ((l_pmlrulv_tbl(i).OFFSET_UOM IS NOT NULL) and
            (l_pmlrulv_tbl(i).OFFSET_DURATION IS NOT NULL) and
            (trunc(l_first_sch_date) >= trunc(p_cov_tbl(1).end_date)))  THEN

             l_first_sch_date := trunc(p_cov_tbl(1).end_date);

             okc_time_util_pub.get_duration(
                            p_start_date    => l_start_date,
                            p_end_date      => l_first_sch_date - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

            IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

         END IF;



         l_sch_end_date   :=  okc_time_util_pub.get_enddate(l_first_sch_date,
                                                     l_pmlrulv_tbl(i).FREQUENCY_UOM,
                                                     to_number(l_pmlrulv_tbl(i).FREQUENCY)*
                                                     to_number(l_pmlrulv_tbl(i).NUMBER_OF_OCCURENCES));
         IF  trunc(l_sch_end_date) >= trunc(p_cov_tbl(1).end_date) then
            l_sch_end_date := trunc(p_cov_tbl(1).end_date);
         end if;

         x_pms_tbl.DELETE;

         GENERATE_SCHEDULE(
                p_api_version           =>  l_api_version,
                p_init_msg_list         =>  l_init_msg_list,
                x_return_status         =>  x_sch_ret_status,
                x_msg_count             =>  l_msg_count,
                x_msg_data              =>  l_msg_data,
                p_periods               =>  to_number(l_pmlrulv_tbl(i).NUMBER_OF_OCCURENCES),
                p_start_date            =>  l_start_date,
                p_end_date              =>  p_cov_tbl(1).end_date,
                p_duration              =>  to_number(l_pmlrulv_tbl(i).FREQUENCY),
                p_period                =>  l_pmlrulv_tbl(i).FREQUENCY_UOM,
                p_first_sch_date        =>  l_first_sch_date,
                x_periods               =>  x_periods,
                x_last_date             =>  x_last_date,
                x_pms_tbl               =>  x_pms_tbl);

        IF NOT x_sch_ret_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

--        l_msg_data := l_msg_data||'l_pmlrulv_tbl_out(i).id : '||l_pmlrulv_tbl_out(i).id||'; ';

        l_pmlrulv_tbl_out(i)                        := l_pmlrulv_tbl(i);
        l_pmlrulv_tbl_out(i).id                     := l_pmlrulv_tbl(i).id;
        l_pmlrulv_tbl_out(i).object_version_number  := l_pmlrulv_tbl(i).object_version_number;
        l_pmlrulv_tbl_out(i).dnz_chr_id             := l_pmlrulv_tbl(i).dnz_chr_id;
--02/12        l_pmlrulv_tbl_out(i).PROGRAM_ID      := l_pmlrulv_tbl(i).PROGRAM_ID;
        l_pmlrulv_tbl_out(i).SEQUENCE_NUMBER      := l_pmlrulv_tbl(i).SEQUENCE_NUMBER;

        l_pmlrulv_tbl_out(i).NUMBER_OF_OCCURENCES      := x_periods;
        l_pmlrulv_tbl_out(i).start_date      := l_start_date;
        l_pmlrulv_tbl_out(i).end_date      := l_sch_end_date;
        l_pmlrulv_tbl_out(i).FREQUENCY      := l_pmlrulv_tbl(i).FREQUENCY;
        l_pmlrulv_tbl_out(i).FREQUENCY_UOM      := l_pmlrulv_tbl(i).FREQUENCY_UOM;

        IF l_duration IS NOT NULL and l_timeunit IS NOT NULL THEN
            l_pmlrulv_tbl_out(i).OFFSET_DURATION  := to_char(l_duration);
            l_pmlrulv_tbl_out(i).OFFSET_UOM  := l_timeunit;
        ELSE
            l_pmlrulv_tbl_out(i).OFFSET_DURATION  := l_pmlrulv_tbl(i).OFFSET_DURATION;
            l_pmlrulv_tbl_out(i).OFFSET_UOM  := l_pmlrulv_tbl(i).OFFSET_UOM;
        END IF;

        l_pmlrulv_tbl_out(i).AUTOSCHEDULE_YN     := 'Y';

          FOR j in x_pms_tbl.FIRST..x_pms_tbl.LAST LOOP


             l_pmschvtbl_In(j+k).seq_no                         := to_number(l_pmlrulv_tbl(i).SEQUENCE_NUMBER);
             l_pmschvtbl_In(j+k).stream_line_id                 := l_pmlrulv_tbl(i).id;
             l_pmschvtbl_In(j+k).object_version_number          := l_pmlrulv_tbl(i).object_version_number;
             l_pmschvtbl_In(j+k).dnz_chr_id                     := l_pmlrulv_tbl(i).dnz_chr_id;
--02/12             l_pmschvtbl_In(j+k).program_id                     := l_pmlrulv_tbl(i).program_id;
             l_pmschvtbl_In(j+k).cle_id                         := p_cov_tbl(1).id;
             l_pmschvtbl_In(j+k).sch_sequence                   := j;
             l_pmschvtbl_In(j+k).schedule_date                  := x_pms_tbl(j).schedule_date;
             l_pmschvtbl_In(j+k).schedule_date_from             := NULL;
             l_pmschvtbl_In(j+k).schedule_date_to               := NULL;

             if l_pmlrulv_tbl(i).activity_line_id is not null then
                 l_pmschvtbl_In(j+k).activity_line_id                  := to_number(l_pmlrulv_tbl(i).activity_line_id);--CK change
             end if;
          END LOOP;
          k := k + x_pms_tbl.LAST;


          IF  trunc(l_sch_end_date) >= trunc(p_cov_tbl(1).end_date) then
  --          l_msg_data := l_msg_data||'in exit '||'; ';
            exit;
          else
            l_start_date := l_sch_end_date + 1;
          end if;

        END LOOP;

  l_pmlrulv_tbl.DELETE;
  x_pmlrulv_tbl         := l_pmlrulv_tbl_out;
  x_pmschv_tbl          := l_pmschvtbl_In;
  x_return_status       := l_return_status;
  x_msg_count           := l_msg_count;
  x_msg_data            := l_msg_data;

 EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status       := l_return_status ;

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	      => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status             := OKC_API.G_RET_STS_UNEXP_ERROR;

END REFRESH_PM_PROGRAM_SCHEDULE;

PROCEDURE RENEW_PM_PROGRAM_SCHEDULE
       (p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_contract_line_id      IN NUMBER)
 IS
--CK RUL
   l_cov_start_date         DATE;
   l_cov_end_date           DATE;
   l_orig_cov_id            NUMBER;
CURSOR CU_ORIG_COV_ID IS
    SELECT
        orig_system_id1 id
    FROM
       okc_k_lines_b
    WHERE
       id=p_contract_line_id;
       -- AND lse_id  IN (2,15,20);  commented by jvorugan as pm is associated with contract line
   cr_orig_cov_id cu_orig_cov_id%ROWTYPE;

  CURSOR Cur_NewCovDet IS
  SELECT ID,
         START_DATE , --COV.START_DATE START_DATE,
         END_DATE  --COV.END_DATE END_DATE,
  FROM   OKC_K_LINES_B
  WHERE  id=p_contract_line_id;
  -- AND lse_id  IN (2,15,20);  commented by jvorugan as pm is associated with contract line

   NewCovDet_Rec		            Cur_NewCovDet%ROWTYPE;
  l_old_cle_id NUMBER;

  l_row_cnt                     NUMBER;
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	            VARCHAR2(1):='S'; --ck
  l_msg_count		            NUMBER;
  l_msg_data		            VARCHAR2(2000):=null;
  l_cov_rec                     okc_contract_pub.clev_rec_type;

BEGIN
IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.Set_Indentation('Renew_PM_Program_Schedule');
		okc_debug.log('Entered Renew_PM_Program_Schedule', 3);
END IF;
--CK RUL
  FOR NewCovDet_Rec IN Cur_NewCovDet
   LOOP
    l_cov_rec.id  	       	      	            :=NewCovDet_Rec.Id;
    l_cov_rec.Start_Date      	      	        :=NewCovDet_Rec.Start_Date;
    l_cov_rec.End_Date     		                :=NewCovDet_Rec.End_Date;
   END LOOP;
    OPEN cu_orig_cov_id;
    LOOP
    FETCH cu_orig_cov_id INTO cr_orig_cov_id;
    EXIT WHEN cu_orig_cov_id%NOTFOUND;
        l_orig_cov_id :=cr_orig_cov_id.id;
    END LOOP;
    CLOSE cu_orig_cov_id;
    CREATE_PM_PROGRAM_SCHEDULE
       (p_api_version       =>   l_api_version,
        p_init_msg_list     =>   l_init_msg_list,
        x_return_status     =>   l_return_status,
        x_msg_count         =>   l_msg_count,
        x_msg_data          =>   l_msg_data,
        p_template_cle_id   =>l_orig_cov_id, --pass coverage line id of original contract
        p_cle_id            =>l_cov_rec.id  ,--p_contract_line_id, --pass coverage line id of new contract
        p_cov_start_date    =>  l_cov_rec.Start_Date,
        p_cov_end_date      =>  l_cov_rec.End_Date);
        IF (G_DEBUG_ENABLED = 'Y') THEN
            okc_debug.log('After CREATE_PM_PROGRAM_SCHEDULE', 3);
        END IF;

    IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
       THEN
           OKC_API.set_message
             (G_APP_NAME,
              G_REQUIRED_VALUE,
              G_COL_NAME_TOKEN,
              'create activities streamlevels and schedules');

            Raise G_EXCEPTION_HALT_VALIDATION;
     END IF;

  IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Renew_PM_Program_Schedule', 3);
		okc_debug.Reset_Indentation;
  END IF;

  x_return_status       := l_return_status;
  x_msg_count           := l_msg_count;
  x_msg_data            := l_msg_data;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status ;
      IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Renew_PM_Program_Schedule'||l_return_Status, 3);
		okc_debug.Reset_Indentation;
      END IF;

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;
        IF (G_DEBUG_ENABLED = 'Y') THEN
		    okc_debug.log('Exiting Renew_PM_Program_Schedule'||l_return_Status, 3);
    		okc_debug.Reset_Indentation;
        END IF;

END RENEW_PM_PROGRAM_SCHEDULE;


--CK CODE FOR RULES CHANGES
PROCEDURE POPULATE_SCHEDULE
       (p_api_version     IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_pmlrulv_tbl           IN  oks_pml_pvt.pmlv_tbl_type,
        p_sch_tbl               IN  OKS_PMS_PVT.oks_pm_schedules_v_tbl_type,
        p_pma_tbl               IN  pma_tbl_type,
        p_is_template           IN VARCHAR2)
IS
  l_pmlrulv_tbl             oks_pml_pvt.pmlv_tbl_type;
  l_pmlrulv_tbl_out         oks_pml_pvt.pmlv_tbl_type;
  l_pmarulv_rec             oks_pma_pvt.pmav_rec_type;
  l_pmarulv_rec_out         oks_pma_pvt.pmav_rec_type;
  l_api_version		        CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	        CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	        VARCHAR2(1);
  l_msg_count		        NUMBER;
  l_msg_data		        VARCHAR2(2000):=null;
  l_msg_index_out           Number;
  l_api_name                CONSTANT VARCHAR2(30) := 'populate schedule';
  l_pmlrulvrec_Out 	        oks_pml_pvt.pmlv_rec_type;
  l_sch_tbl                 OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_sch_tbl_out             OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pml_index               NUMBER;
  l_pml_indexin             NUMBER;
  l_pma_index               NUMBER;
  l_sch_index               NUMBER;
  l_sch_indexin             NUMBER;
  CURSOR cu_obj_version(cp_activity_line_id NUMBER)
  IS
  SELECT
        object_version_number
  FROM
  OKS_PM_ACTIVITIES
  WHERE id=cp_activity_line_id;
--  cr_obj_version cu_obj_version%ROWTYPE;
  l_object_version_number  NUMBER;
BEGIN
         l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


  l_pml_index:=1;
  l_pma_index:=1;
  WHILe l_pma_index <=p_pma_tbl.COUNT LOOP
  l_pml_indexin:=1;
      WHILE l_pml_indexin <= p_pmlrulv_tbl.COUNT LOOP
        l_pmlrulv_tbl(l_pml_index).SEQUENCE_NUMBER      :=  p_pmlrulv_tbl(l_pml_indexin).SEQUENCE_NUMBER;
        l_pmlrulv_tbl(l_pml_index).NUMBER_OF_OCCURENCES :=  p_pmlrulv_tbl(l_pml_indexin).NUMBER_OF_OCCURENCES;
        l_pmlrulv_tbl(l_pml_index).START_DATE           :=  p_pmlrulv_tbl(l_pml_indexin).START_DATE;
        l_pmlrulv_tbl(l_pml_index).END_DATE             :=  p_pmlrulv_tbl(l_pml_indexin).END_DATE;
        l_pmlrulv_tbl(l_pml_index).FREQUENCY            :=  p_pmlrulv_tbl(l_pml_indexin).FREQUENCY;
        l_pmlrulv_tbl(l_pml_index).FREQUENCY_UOM        :=  p_pmlrulv_tbl(l_pml_indexin).FREQUENCY_UOM;
        l_pmlrulv_tbl(l_pml_index).OFFSET_DURATION      :=  p_pmlrulv_tbl(l_pml_indexin).OFFSET_DURATION;
        l_pmlrulv_tbl(l_pml_index).OFFSET_UOM           :=  p_pmlrulv_tbl(l_pml_indexin).OFFSET_UOM;
        l_pmlrulv_tbl(l_pml_index).AUTOSCHEDULE_YN      :=  p_pmlrulv_tbl(l_pml_indexin).AUTOSCHEDULE_YN;
--02/12        l_pmlrulv_tbl(l_pml_index).PROGRAM_ID           :=  p_pmlrulv_tbl(l_pml_indexin).PROGRAM_ID;
        l_pmlrulv_tbl(l_pml_index).CLE_ID               :=  p_pmlrulv_tbl(l_pml_indexin).CLE_ID;
        l_pmlrulv_tbl(l_pml_index).dnz_chr_id           :=  p_pmlrulv_tbl(l_pml_indexin).dnz_chr_id ;
        l_pmlrulv_tbl(l_pml_index).ACTIVITY_LINE_ID     :=  p_pma_tbl(l_pma_index).activity_line_id;


     oks_pml_pvt.insert_row(
        p_api_version       => l_api_version,
        p_init_msg_list     => l_init_msg_list,
        x_return_status     =>l_return_status,
        x_msg_count         =>l_msg_count,
        x_msg_data          =>l_msg_data,
        p_pmlv_rec          =>l_pmlrulv_tbl(l_pml_index),
        x_pmlv_rec           =>l_pmlrulvrec_Out);
       IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
         THEN
             OKC_API.set_message
             (G_APP_NAME,
              G_REQUIRED_VALUE,
              G_COL_NAME_TOKEN,
              'create program stream levels');
          Raise G_EXCEPTION_HALT_VALIDATION;
       END IF;


 --Create schedules
l_sch_indexin :=1;
--reset table as dupl values are created
l_sch_tbl.delete;
 IF p_is_template='N' THEN
          l_sch_index :=1;
           WHILE l_sch_indexin <=p_sch_tbl.COUNT LOOP

                IF (p_pmlrulv_tbl(l_pml_indexin).id  =       p_sch_tbl(l_sch_indexin).stream_line_id)THEN
                      l_sch_tbl(l_sch_index).schedule_date        :=  p_sch_tbl(l_sch_indexin).schedule_date;
                      l_sch_tbl(l_sch_index).schedule_date_from   :=  p_sch_tbl(l_sch_indexin).schedule_date_from;
                      l_sch_tbl(l_sch_index).schedule_date_to     :=  p_sch_tbl(l_sch_indexin).schedule_date_to;
                      l_sch_tbl(l_sch_index).dnz_chr_id           :=  p_sch_tbl(l_sch_indexin).dnz_chr_id ;
                      l_sch_tbl(l_sch_index).cle_id               :=  p_sch_tbl(l_sch_indexin).cle_id ;
                      l_sch_tbl(l_sch_index).sch_sequence         :=  p_sch_tbl(l_sch_indexin).sch_sequence;
                      l_sch_tbl(l_sch_index).activity_line_id     :=  p_pma_tbl(l_pma_index).activity_line_id;
                      l_sch_tbl(l_sch_index).stream_line_id       :=  l_pmlrulvrec_Out.id;
--02/12                      l_sch_tbl(l_sch_index).program_id           :=  p_sch_tbl(l_sch_indexin).program_id;
                     l_sch_index :=l_sch_index+1;
              END IF;
              l_sch_indexin := l_sch_indexin +1;

            END LOOP;
            OKS_PMS_PVT.insert_row(
            p_api_version	=> l_api_version,
            p_init_msg_list	=> l_init_msg_list,
            x_return_status => l_return_status ,
            x_msg_count		=> l_msg_count ,
            x_msg_data		=> l_msg_data  ,
            p_oks_pm_schedules_v_tbl => l_sch_tbl,
            x_oks_pm_schedules_v_tbl =>l_sch_tbl_out);
          IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
         THEN
             OKC_API.set_message
             (G_APP_NAME,
              G_REQUIRED_VALUE,
              G_COL_NAME_TOKEN,
              'create activity schedules');
          Raise G_EXCEPTION_HALT_VALIDATION;
       END IF;
       --03/11 added to update activity schedule exists to 'Y'
          OPEN cu_obj_version(p_pma_tbl(l_pma_index).activity_line_id);
          FETCH cu_obj_version INTO l_object_version_number;
          CLOSE cu_obj_version;
          l_pmarulv_rec.id :=p_pma_tbl(l_pma_index).activity_line_id;
          l_pmarulv_rec.SCH_EXISTS_YN    := 'Y';
          l_pmarulv_rec.OBJECT_VERSION_NUMBER:=l_object_version_number;
            oks_pma_pvt.update_row(
            p_api_version       => l_api_version,
            p_init_msg_list     => l_init_msg_list,
            x_return_status     =>l_return_status,
            x_msg_count         =>l_msg_count,
            x_msg_data          =>l_msg_data,
            p_pmav_rec          =>l_pmarulv_rec,
            x_pmav_rec           =>l_pmarulv_rec_Out);
          IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS
         THEN
             OKC_API.set_message
             (G_APP_NAME,
              G_REQUIRED_VALUE,
              G_COL_NAME_TOKEN,
              'update schedule exists');
          Raise G_EXCEPTION_HALT_VALIDATION;
       END IF;

     END IF; --end of schedules
            l_pml_indexin:=l_pml_indexin+1;
        END LOOP;
        l_pma_index:=l_pma_index+1;
        l_pml_index:=l_pml_index+1;
  END LOOP;
      x_return_status         := l_return_status;
EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status ;

 WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
       -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;

END POPULATE_SCHEDULE;


/* Logic for adjust - rules rearchitecture
*** Populate a table of records with id for oks_k_lines or oks_pm_activities and type
*** Loop through the table of records
***Logic for adjusting schedule dates remains the same
*/
    /*

      Possible input parameters combinations:
      1. p_new_start_date NOT NULL and p_new_end_date NOT NULL
      2. p_new_start_date NOT NULL and p_new_end_date NULL
      3. p_new_start_date NULL     and p_new_end_date NOT NULL

      Possible scenarios For input combination 1 :

      1. p_new_start_date and p_new_end_date are such that they fall
         in between two consecutive schedules without touching ,after the last schedule or,
         before the first schedule.


      2. p_new_start_date and p_new_end_date are such that they fall
         in between two schedules or, is within a schedule and p_new_start_date is less than
         the schedule_date_from of the leading schedule and  p_new_end_date is less than
         the schedule_date_to of the trailing schedule or, of the leading schedule itself.

      solution:

         new leading schedule means the schedule for which p_new_start_date <= schedule_date_to/schedule_date
         new trailing schedule means the schedule for which p_new_end_date >= schedule_date_from/schedule_date

         delete all schedules and rules  if new effectivity does not touch any of the existing schedules
           thereafter create a rule and a schedules based on the old rule nearest to the new effectivity
           and exit.

         delete all schedules till new leading schedule and after new trailing schedule

         delete all rules till rule of new leading schedule and rule after rule of new trailing schedule

         update the new leading rule start date and the new trailing rule end date

         update the new leading rule offset for all rules
               if p_new_start_date < new leading schedule
               (except when new leading schedule is first schedule of the first rule and the rule is autoscheduled)

         create schedules and the rule offset by calculating backdates based on the first rule info and the p_new_start_date
               if p_new_start_date < new leading schedule and
                new leading schedule is first schedule of the first rule and the rule is autoscheduled

               thereafter change the schedule sequences and the rule periods based on new number of
               schedules for the rule

         create schedules  by calculating forward dates based on the last rule info and the p_new_end_date
                if p_new_end_date > new trailing schedule and
                new trailing schedule is last schedule of the last rule and the rule is autoscheduled

               thereafter change  rule periods based on new number of schedules for the rule

         update  new leading schedule schedule_date_from
                if p_new_start_date >= new leading schedule schedule_date_from

                therafter if not first schedule of the rule
                    update schedule sequence for all the schedules of the rule for the leading schedule
                    update periods for the rule of the new leading schedule

         update  new trailing schedule schedule_date_to
                if p_new_end_date <= new trailing schedule schedule_date_to

                therafter if not last schedule of the rule
                    update periods for the rule of the new trailing schedule

    */
PROCEDURE ADJUST_PM_PROGRAM_SCHEDULE
       (p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        p_contract_line_id      IN NUMBER,
        p_new_start_date        IN DATE,
        p_new_end_date          IN DATE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2)
 IS

CURSOR CU_CLE_ID is
  select id
  from okc_k_lines_b
  where id=p_contract_line_id;
    -- and lse_id in (2,15,20); commented by jvorugan as pm is associated with contract line
CR_CLE_ID CU_CLE_ID%ROWTYPE;
--not used
/*CURSOR CU_STREAM_LEVELS IS
  SELECT SEQUENCE_NUMBER ,
        NUMBER_OF_OCCURENCES   ,
        START_DATE     ,
        END_DATE       ,
        FREQUENCY ,
        FREQUENCY_UOM      ,
        OFFSET_DURATION ,
        OFFSET_UOM,
        AUTOSCHEDULE_YN,
        PROGRAM_ID ,
        ACTIVITY_LINE_ID,
        CLE_ID
        DNZ_CHR_ID
  FROM  OKS_PM_STREAM_LEVELS_V PML
  WHERE  CLE_ID=(select id from okc_k_lines_b where cle_id=p_contract_line_id
  and lse_id in (2,15,20));

  CR_STREAM_LEVELS CU_STREAM_LEVELS%ROWTYPE;*/

     CURSOR CU_NewCovDet IS
  SELECT ID,
         START_DATE, --COV.START_DATE START_DATE,
         END_DATE --COV.END_DATE END_DATE,
  FROM   OKC_K_LINES_B
  WHERE  ID    = p_contract_line_id;
 -- and lse_id in (2,15,20); commented by jvorugan as pm is associated with contract line

  CR_NewCovDet		            Cu_NewCovDet%ROWTYPE;

  CURSOR Cu_NewPMSch(cp_stream_line_id IN NUMBER) IS
   SELECT  ID,
           RULE_ID,
           PMA_RULE_ID,
           PMP_RULE_ID,
           OBJECT_VERSION_NUMBER,
           DNZ_CHR_ID,
           CLE_ID,
           SCH_SEQUENCE,
           SCHEDULE_DATE,
           SCHEDULE_DATE_FROM,
           SCHEDULE_DATE_TO,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTIVITY_LINE_ID ,
           STREAM_LINE_ID ,
           SECURITY_GROUP_ID ,
           PROGRAM_APPLICATION_ID   ,
           PROGRAM_ID  ,
           PROGRAM_UPDATE_DATE,
           REQUEST_ID
   FROM    OKS_PM_SCHEDULES
    WHERE  STREAM_LINE_ID=cp_stream_line_id;

CR_NewPMSch                 Cu_NewPMSch%ROWTYPE;
--not used
/*  CURSOR Cu_PMSch IS
   SELECT  ID,
           RULE_ID,
           PMA_RULE_ID,
           PMP_RULE_ID,
           OBJECT_VERSION_NUMBER,
           DNZ_CHR_ID,
           CLE_ID,
           SCH_SEQUENCE,
           SCHEDULE_DATE,
           SCHEDULE_DATE_FROM,
           SCHEDULE_DATE_TO,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTIVITY_LINE_ID ,
           STREAM_LINE_ID ,
           SECURITY_GROUP_ID ,
           PROGRAM_APPLICATION_ID   ,
           PROGRAM_ID  ,
           PROGRAM_UPDATE_DATE,
           REQUEST_ID
   FROM    OKS_PM_SCHEDULES
    WHERE  CLE_ID     =(select id from okc_k_lines_b where cle_id=p_contract_line_id
      and lse_id in (2,15,20))
    order by nvl(schedule_date,schedule_date_from);*/

  CURSOR Cu_PMSch_PMPPML IS
   SELECT  ID,
           RULE_ID,
           PMA_RULE_ID,
           PMP_RULE_ID,
           OBJECT_VERSION_NUMBER,
           DNZ_CHR_ID,
           CLE_ID,
           SCH_SEQUENCE,
           SCHEDULE_DATE,
           SCHEDULE_DATE_FROM,
           SCHEDULE_DATE_TO,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTIVITY_LINE_ID ,
           STREAM_LINE_ID ,
           SECURITY_GROUP_ID ,
           PROGRAM_APPLICATION_ID   ,
           PROGRAM_ID  ,
           PROGRAM_UPDATE_DATE,
           REQUEST_ID
   FROM    OKS_PM_SCHEDULES
    WHERE  CLE_ID= p_contract_line_id --(select id from okc_k_lines_b where cle_id=p_contract_line_id
      --and lse_id in (2,15,20))  commented by jvorugan as pm is associated with contract line
    and    ACTIVITY_LINE_ID is null
    order by nvl(schedule_date,schedule_date_from);

  CURSOR Cu_PMSch_PMAPML(P_ACTIVITY_LINE_ID IN NUMBER) IS
   SELECT  ID,
           RULE_ID,
           PMA_RULE_ID,
           PMP_RULE_ID,
           OBJECT_VERSION_NUMBER,
           DNZ_CHR_ID,
           CLE_ID,
           SCH_SEQUENCE,
           SCHEDULE_DATE,
           SCHEDULE_DATE_FROM,
           SCHEDULE_DATE_TO,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTIVITY_LINE_ID ,
           STREAM_LINE_ID ,
           SECURITY_GROUP_ID ,
           PROGRAM_APPLICATION_ID   ,
           PROGRAM_ID  ,
           PROGRAM_UPDATE_DATE,
           REQUEST_ID
   FROM    OKS_PM_SCHEDULES
    WHERE  ACTIVITY_LINE_ID   = P_ACTIVITY_LINE_ID
    order by nvl(schedule_date,schedule_date_from);
--CK RUL REVISIT THIS
  CURSOR CU_PROGRAM IS
  SELECT  id,'PMP' TYPE
  FROM OKS_K_LINES_B
  WHERE CLE_ID= p_contract_line_id;--(select id from okc_k_lines_b where cle_id=p_contract_line_id
    -- and lse_id in (2,15,20));  commented by jvorugan as pm is associated with contract line

  CR_PROGRAM CU_PROGRAM%ROWTYPE;

  CURSOR CU_ACTIVITIES IS
  SELECT  id,'PMA' TYPE
  FROM OKS_PM_ACTIVITIES
  WHERE CLE_ID= p_contract_line_id;
   -- and lse_id in (2,15,20)); commented by jvorugan as pm is associated with contract line

  CR_ACTIVITIES CU_ACTIVITIES%ROWTYPE;


  CURSOR CU_PM_STREAM_LEVELS IS
    SELECT
        ID,
        SEQUENCE_NUMBER ,
        NUMBER_OF_OCCURENCES   ,
        START_DATE     ,
        END_DATE       ,
        FREQUENCY ,
        FREQUENCY_UOM      ,
        OFFSET_DURATION ,
        OFFSET_UOM,
        AUTOSCHEDULE_YN,
--02/12        PROGRAM_ID ,
        ACTIVITY_LINE_ID,
        CLE_ID,
        DNZ_CHR_ID,
        OBJECT_VERSION_NUMBER
  FROM  OKS_PM_STREAM_LEVELS_V PML
  WHERE  CLE_ID=p_contract_line_id
      -- and lse_id in (2,15,20)) commented by jvorugan as pm is associated with contract line
  AND ACTIVITY_LINE_ID IS NULL
  ORDER BY ACTIVITY_LINE_ID,SEQUENCE_NUMBER;

  CURSOR CU_PMA_STREAM_LEVELS(cp_activity_line_id IN NUMBER) IS
    SELECT
        ID,
        SEQUENCE_NUMBER ,
        NUMBER_OF_OCCURENCES   ,
        START_DATE     ,
        END_DATE       ,
        FREQUENCY ,
        FREQUENCY_UOM      ,
        OFFSET_DURATION ,
        OFFSET_UOM,
        AUTOSCHEDULE_YN,
--02/12        PROGRAM_ID ,
        ACTIVITY_LINE_ID,
        CLE_ID,
        DNZ_CHR_ID,
        OBJECT_VERSION_NUMBER
  FROM  OKS_PM_STREAM_LEVELS_V PML
  WHERE  CLE_ID=p_contract_line_id
      -- and lse_id in (2,15,20)) commented by jvorugan as pm is associated with contract line
  AND ACTIVITY_LINE_ID = cp_activity_line_id
  ORDER BY ACTIVITY_LINE_ID,SEQUENCE_NUMBER;


  l_pm_tbl                      pm_tbl_type;
  l_pmlrulv_tbl                 OKS_PML_PVT.pmlv_tbl_type;
  l_rulv_tbl_in                 OKS_PML_PVT.pmlv_tbl_type;
  l_rulv_Tbl_Out                OKS_PML_PVT.pmlv_tbl_type;
  l_pmlrulv_tbl_del             OKS_PML_PVT.pmlv_tbl_type;

--  l_pmlrulv_tbl_in              OKC_RULE_PUB.rulv_tbl_type;
--  l_pmlrulv_tbl_out             OKC_RULE_PUB.rulv_tbl_type;
  l_pmlrulv_tbl_ins             OKS_PML_PVT.pmlv_tbl_type;
  l_pmlrulv_tbl_ins_out         OKS_PML_PVT.pmlv_tbl_type;
  l_pmlrulv_tbl_upd            OKS_PML_PVT.pmlv_tbl_type;
  l_pmlrulv_tbl_upd_out         OKS_PML_PVT.pmlv_tbl_type;
  l_pmlrulv_tbl_rfr            OKS_PML_PVT.pmlv_tbl_type;
  l_pmlrulv_tbl_start           OKS_PML_PVT.pmlv_tbl_type;
  l_pmlrulv_tbl_end            OKS_PML_PVT.pmlv_tbl_type;



  l_rule_act_tbl                OKS_PM_PROGRAMS_PVT.rule_act_tbl;

  pml_ctr                       NUMBER :=0;
  pml_del_ctr                   NUMBER :=0;
  pml_upd_ctr                   NUMBER :=0;
  pms_del_ctr                   NUMBER :=0;
  pms_upd_ctr                   NUMBER :=0;
  pms_ins_ctr                   NUMBER :=0;
  pml_rfr_ctr                   NUMBER :=0;
  pml_ins_ctr                   NUMBER :=0;
  pml_deleted                   varchar2(1);
  pms_delrec_exists             varchar2(1);
  l_msg_index                   NUMBER;
  l_start_rule_seq              NUMBER ;
  l_end_rule_seq                NUMBER ;
  l_first_rule_id               NUMBER :=0;
  l_last_rule_id                NUMBER :=0;
  l_pmschv_end_lst_seq          NUMBER :=0;
  l_duration                    number;
  l_timeunit                    varchar2(30);
  l_next_sch_seq                number;


  l_pms_tbl                     pms_tbl_type;
  l_row_cnt                     NUMBER;
  l_api_version		CONSTANT	NUMBER     := 1.0;
  l_init_msg_list	CONSTANT	VARCHAR2(1):= 'F';
  l_return_status	            VARCHAR2(1):= 'S';
  l_msg_count		            NUMBER;
  l_msg_data		            VARCHAR2(2000):=null;
--  l_pmprulvrec_Out 	            OKC_RULE_PUB.rulv_rec_type;
--  l_pmlrulvrec_Out 	            OKC_RULE_PUB.rulv_rec_type;
  l_pmschvtbl_In                OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschvtbl_Out               OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_cov_rec                     okc_contract_pub.clev_rec_type;
  l_pmschvtbl_Del               OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschvtbl_Upd               OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschvtbl_Upd_out           OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschvrec_prv               OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschv_start                OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschv_end                  OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschvtbl_Ins               OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschvtbl_Ins_out           OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;
  l_pmschv_tbl                  OKS_PMS_PVT.oks_pm_schedules_v_tbl_type;



  l_Rule_Id	                    NUMBER;
  k                             NUMBER := 0;
  l_frst_sch_date               DATE;
  l_last_sch_date               DATE;
  l_prev_sch_date               DATE;
  l_next_sch_date               DATE;

  l_sort_ret_status	            VARCHAR2(1) := 'S';
  x_sch_ret_status	            VARCHAR2(1) := 'S';
  x_periods                     NUMBER;
  x_pms_tbl                     pms_tbl_type;
  l_start_date                  DATE;
  x_last_date                   DATE;
  l_first_sch_date              DATE;
  l_sch_end_date                DATE;
  c_rgp_id                      NUMBER;
  c_chr_id                      NUMBER;

--CK RUL Add init procedure here for stream level record
  l_pm_ctr                      NUMBER;
  l_cle_id                      NUMBER;
BEGIN
IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.Set_Indentation('Adjust_PM_Program_Schedule');
		okc_debug.log('Entered Adjust_PM_Program_Schedule', 3);
END IF;
--CK RUL
OPEN CU_CLE_ID;
LOOP
FETCH CU_CLE_ID INTO CR_CLE_ID;
EXIT WHEN CU_CLE_ID%NOTFOUND;
l_cle_id    :=  cr_cle_id.id;
END LOOP;
CLOSE CU_CLE_ID;
 FOR CR_NewCovDet IN CU_NewCovDet
   LOOP

    l_cov_rec.id  	       	      	            :=CR_NewCovDet.Id;
    l_cov_rec.Start_Date      	      	        :=CR_NewCovDet.Start_Date;
    l_cov_rec.End_Date     		                :=CR_NewCovDet.End_Date;
l_pm_ctr:=1;
FOR CR_PROGRAM IN CU_PROGRAM LOOP
     l_pm_tbl(l_pm_ctr) :=cr_program;
     l_pm_ctr :=l_pm_ctr+1;
END LOOP;
FOR CR_ACTIVITIES IN CU_ACTIVITIES LOOP
     l_pm_tbl(l_pm_ctr) :=cr_activities;
     l_pm_ctr :=l_pm_ctr+1;
END LOOP;
--pml_ctr :=1;
  l_pmschv_start.DELETE;
  l_pmschv_end.DELETE;
  k := 0;
FOR i in 1..l_pm_tbl.count LOOP
--CK 09/18

  pml_ctr          :=0;
  pml_del_ctr      :=0;
  pml_upd_ctr      :=0;
  pms_del_ctr      :=0;
  pms_upd_ctr      :=0;
  pms_ins_ctr      :=0;
  pml_rfr_ctr      :=0;
  pml_ins_ctr      :=0;

l_rulv_tbl_in.delete;
  l_pmlrulv_tbl.delete;
--  l_pmlrulv_tbl_in.delete;
--  l_pmlrulv_tbl_out.delete;
  l_pmlrulv_tbl_del.delete;
  l_pmlrulv_tbl_ins.delete;
  l_pmlrulv_tbl_ins_out.delete;
  l_pmlrulv_tbl_upd.delete;
  l_pmlrulv_tbl_upd_out.delete;
  l_pmlrulv_tbl_rfr.delete;
  l_pmlrulv_tbl_start.delete;
  l_pmlrulv_tbl_end.delete;

  l_start_rule_seq              :=0;
  l_end_rule_seq                :=0;
  l_first_rule_id               :=0;
  l_last_rule_id                :=0;
  l_pmschv_end_lst_seq          :=0;
  l_duration                    :=null;
  l_timeunit                    :=null;
  l_next_sch_seq                :=0;

  l_pms_tbl.delete;
  l_row_cnt                     :=0;

  l_rulv_Tbl_In.delete;
  l_rulv_Tbl_Out.delete;
  l_pmschvtbl_In.delete;
  l_pmschvtbl_Out.delete;
--  l_cov_rec.delete;
  l_pmschvtbl_Del.delete;
  l_pmschvtbl_Upd.delete;
  l_pmschvtbl_Upd_out.delete;
  l_pmschv_start.delete;
  l_pmschv_end.delete;
  l_pmschvtbl_Ins.delete;
  l_pmschvtbl_Ins_out.delete;
  l_pmschv_tbl.delete;

  k                            := 0;
  l_prev_sch_date              := null;
  l_next_sch_date              := null;

  l_first_sch_date             := null;




--ck 09/18
   if  l_pm_tbl(i).type = 'PMP' then


   FOR CR_PM_STREAM_LEVELS IN CU_PM_STREAM_LEVELS
    LOOP
--    Init_Rulv(l_rulv_tbl_in);
        pml_ctr :=pml_ctr+1;
        l_rulv_tbl_in(pml_ctr).ID                   :=  cr_pm_stream_levels.ID;
        l_rulv_tbl_in(pml_ctr).SEQUENCE_NUMBER      :=  cr_pm_stream_levels.SEQUENCE_NUMBER;
        l_rulv_tbl_in(pml_ctr).NUMBER_OF_OCCURENCES :=  cr_pm_stream_levels.NUMBER_OF_OCCURENCES;
        l_rulv_tbl_in(pml_ctr).START_DATE           :=  cr_pm_stream_levels.START_DATE;
        l_rulv_tbl_in(pml_ctr).END_DATE             :=  cr_pm_stream_levels.END_DATE;
        l_rulv_tbl_in(pml_ctr).FREQUENCY            :=  cr_pm_stream_levels.FREQUENCY;
        l_rulv_tbl_in(pml_ctr).FREQUENCY_UOM        :=  cr_pm_stream_levels.FREQUENCY_UOM;
        l_rulv_tbl_in(pml_ctr).OFFSET_DURATION      :=  cr_pm_stream_levels.OFFSET_DURATION;
        l_rulv_tbl_in(pml_ctr).OFFSET_UOM           :=  cr_pm_stream_levels.OFFSET_UOM;
        l_rulv_tbl_in(pml_ctr).AUTOSCHEDULE_YN      :=  cr_pm_stream_levels.AUTOSCHEDULE_YN;
--02/12        l_rulv_tbl_in(pml_ctr).PROGRAM_ID           :=  cr_pm_stream_levels.PROGRAM_ID;
        l_rulv_tbl_in(pml_ctr).CLE_ID               :=  l_cle_id;
        l_rulv_tbl_in(pml_ctr).DNZ_CHR_ID           :=  cr_pm_stream_levels.DNZ_CHR_ID;
        l_rulv_tbl_in(pml_ctr).OBJECT_VERSION_NUMBER:=  cr_pm_stream_levels.OBJECT_VERSION_NUMBER;
   END LOOP;
   elsif l_pm_tbl(i).type = 'PMA' then

   FOR CR_PMA_STREAM_LEVELS IN CU_PMA_STREAM_LEVELS(l_pm_tbl(i).id)
    LOOP
        pml_ctr :=pml_ctr+1;
        l_rulv_tbl_in(pml_ctr).ID                   :=  cr_pma_stream_levels.ID;
        l_rulv_tbl_in(pml_ctr).SEQUENCE_NUMBER      :=  cr_pma_stream_levels.SEQUENCE_NUMBER;
        l_rulv_tbl_in(pml_ctr).NUMBER_OF_OCCURENCES :=  cr_pma_stream_levels.NUMBER_OF_OCCURENCES;
        l_rulv_tbl_in(pml_ctr).START_DATE           :=  cr_pma_stream_levels.START_DATE;
        l_rulv_tbl_in(pml_ctr).END_DATE             :=  cr_pma_stream_levels.END_DATE;
        l_rulv_tbl_in(pml_ctr).FREQUENCY            :=  cr_pma_stream_levels.FREQUENCY;
        l_rulv_tbl_in(pml_ctr).FREQUENCY_UOM        :=  cr_pma_stream_levels.FREQUENCY_UOM;
        l_rulv_tbl_in(pml_ctr).OFFSET_DURATION      :=  cr_pma_stream_levels.OFFSET_DURATION;
        l_rulv_tbl_in(pml_ctr).OFFSET_UOM           :=  cr_pma_stream_levels.OFFSET_UOM;
        l_rulv_tbl_in(pml_ctr).AUTOSCHEDULE_YN      :=  cr_pma_stream_levels.AUTOSCHEDULE_YN;
--02/12        l_rulv_tbl_in(pml_ctr).PROGRAM_ID           :=  cr_pma_stream_levels.PROGRAM_ID;
        l_rulv_tbl_in(pml_ctr).ACTIVITY_LINE_ID     :=  cr_pma_stream_levels.ACTIVITY_LINE_ID;
        l_rulv_tbl_in(pml_ctr).CLE_ID               :=  l_cle_id;
        l_rulv_tbl_in(pml_ctr).DNZ_CHR_ID           :=  cr_pma_stream_levels.DNZ_CHR_ID;
        l_rulv_tbl_in(pml_ctr).OBJECT_VERSION_NUMBER:=  cr_pma_stream_levels.OBJECT_VERSION_NUMBER;



    END LOOP;

end if; --ck 09/15


 l_pmschv_start.DELETE;
  l_pmschv_end.DELETE;

  k := 0;

  if  l_pm_tbl(i).type= 'PMP' then


  FOR CR_PMSch_PMPPML IN Cu_PMSch_PMPPML LOOP

--To get first schedule in the range of schedules to be updated
    IF trunc(p_new_start_Date) IS NOT NULL AND
       trunc(p_new_start_Date) <= nvl(CR_PMSch_PMPPML.schedule_date,CR_PMSch_PMPPML.schedule_date_to) THEN
        IF l_pmschv_start.COUNT = 0 THEN
            l_pmschv_start(1)   := CR_PMSch_PMPPML;
        END IF;
    END IF;

--To get last schedule in the range of schedules to be updated
    IF trunc(p_new_end_Date) IS NOT NULL AND
       trunc(p_new_end_Date) >= nvl(CR_PMSch_PMPPML.schedule_date,CR_PMSch_PMPPML.schedule_date_from) THEN
        l_pmschv_end.DELETE;
        l_pmschv_end(1)   := CR_PMSch_PMPPML;
    END IF;

    k   := k + 1;
    l_pmschv_tbl(k) := CR_PMSch_PMPPML;

  END LOOP;
  elsif l_pm_tbl(i).type= 'PMA' then


  FOR Cr_PMSch_PMAPML in Cu_PMSch_PMAPML(l_pm_tbl(i).Id) LOOP


--To get first schedule in the range of schedules to be updated
    IF trunc(p_new_start_Date) IS NOT NULL AND
       trunc(p_new_start_Date) <= nvl(Cr_PMSch_PMAPML.schedule_date,Cr_PMSch_PMAPML.schedule_date_to) THEN
        IF l_pmschv_start.COUNT = 0 THEN
            l_pmschv_start(1)   := Cr_PMSch_PMAPML;
        END IF;
    END IF;

--To get last schedule in the range of schedules to be updated
    IF trunc(p_new_end_Date) IS NOT NULL AND
       trunc(p_new_end_Date) >= nvl(Cr_PMSch_PMAPML.schedule_date,Cr_PMSch_PMAPML.schedule_date_from) THEN
        l_pmschv_end.DELETE;
        l_pmschv_end(1)   := Cr_PMSch_PMAPML;
    END IF;

    k   := k + 1;
    l_pmschv_tbl(k) := Cr_PMSch_PMAPML;

  END LOOP;

  end if;
  -- added new dtd feb 13 2003 ends

  k := 0;

  l_pmschv_end_lst_seq      := -99;
  IF l_pmschv_end.COUNT > 0 THEN
    FOR Cr_NewPMSch in Cu_NewPMSch(l_pmschv_end(1).stream_line_id) LOOP

        l_pmschv_end_lst_seq := Cr_NewPMSch.sch_sequence;
    END LOOP;
  END IF;

  l_start_rule_seq  := NULL;
  l_end_rule_seq    := NULL;
  l_pmlrulv_tbl_start.DELETE;
  l_pmlrulv_tbl_end.DELETE;


  IF l_rulv_tbl_in.COUNT > 0 THEN
   FOR i in l_rulv_tbl_in.FIRST..l_rulv_tbl_in.LAST LOOP

    IF trunc(p_new_start_date) IS NOT NULL AND l_pmschv_start.COUNT =1 AND l_pmschv_start(1).STREAM_LINE_id = l_rulv_tbl_in(i).id THEN
        l_start_rule_seq        := l_rulv_tbl_in(i).SEQUENCE_NUMBER;
        l_pmlrulv_tbl_start(1)  := l_rulv_tbl_in(i);
    END IF;

    IF trunc(p_new_end_date) IS NOT NULL AND l_pmschv_end.COUNT =1 AND l_pmschv_end(1).STREAM_LINE_id = l_rulv_tbl_in(i).id THEN
        l_end_rule_seq          := l_rulv_tbl_in(i).SEQUENCE_NUMBER;
        l_pmlrulv_tbl_end(1)    := l_rulv_tbl_in(i);
    END IF;

    IF i = l_rulv_tbl_in.FIRST THEN
        l_first_rule_id := l_rulv_tbl_in(i).id;
    END IF;
    IF  i = l_rulv_tbl_in.LAST THEN
        l_last_rule_id  := l_rulv_tbl_in(i).id;
    END IF;

   END LOOP;
  END IF;


 IF  l_rulv_tbl_in.COUNT > 0 THEN
  IF trunc(p_new_start_date) IS NOT NULL AND trunc(p_new_end_date) IS NOT NULL THEN
      IF (l_start_rule_seq IS NOT NULL AND
          l_end_rule_seq   IS NOT NULL AND
          l_start_rule_seq = l_end_rule_seq AND
          l_pmschv_start(1).sch_sequence > l_pmschv_end(1).sch_sequence) --Range of relevent schedules contain no schedule
                              OR
          (l_start_rule_seq IS NOT NULL AND
          l_end_rule_seq    IS NOT NULL AND
          l_start_rule_seq <> l_end_rule_seq AND
          l_start_rule_seq > l_end_rule_seq) -- Case when start date and end date falls between 2 schedules (spanning rules)
                    OR
         (l_start_rule_seq IS NOT NULL AND -- Case when start date and end date falls before all existing schedules
          l_end_rule_seq   IS  NULL)
                    OR
         (l_start_rule_seq IS NULL AND --Case when start date and end date falls in future to all existing schedules
          l_end_rule_seq   IS NOT NULL) THEN

            pml_del_ctr := 0;
            pms_del_ctr := 0;


            FOR i in l_rulv_tbl_in.FIRST..l_rulv_tbl_in.LAST LOOP
                pml_del_ctr                     := pml_del_ctr + 1;
                l_pmlrulv_tbl_del(pml_del_ctr)  := l_rulv_tbl_in(i);
                FOR NewPMSch_Rec in Cu_NewPMSch(l_rulv_tbl_in(i).id) LOOP
                    pms_del_ctr                     := pms_del_ctr + 1;
                    l_pmschvtbl_Del(pms_del_ctr)    := NewPMSch_Rec;
                END LOOP;
            END LOOP;
            pml_rfr_ctr     := 0;
            pml_rfr_ctr                     := pml_rfr_ctr + 1;

            IF l_start_rule_seq IS NOT NULL THEN
                l_pmlrulv_tbl_rfr(pml_rfr_ctr)  := l_pmlrulv_tbl_start(1);
            ELSIF l_end_rule_seq   IS NOT NULL THEN
                l_pmlrulv_tbl_rfr(pml_rfr_ctr)  := l_pmlrulv_tbl_end(1);
            END IF;

            pms_ins_ctr         := 1;
            pml_ins_ctr         := 1;
            l_first_sch_date    := NULL;
            l_next_sch_date     := NULL;

            l_first_sch_date    := nvl(okc_time_util_pub.get_enddate(trunc(p_new_start_date),
                                                     l_pmlrulv_tbl_rfr(pml_rfr_ctr).offset_uom,
                                                     l_pmlrulv_tbl_rfr(pml_rfr_ctr).offset_duration) + 1,
                                                      trunc(p_new_start_date));

            IF  l_pmschv_start.COUNT > 0 THEN
                l_pmschvtbl_ins(pms_ins_ctr)                := l_pmschv_start(1);
            ELSE
                l_pmschvtbl_ins(pms_ins_ctr)                :=  l_pmschv_end(1);
            END IF;
            IF l_first_sch_date > trunc(p_new_end_date) THEN

                l_pmschvtbl_ins(pms_ins_ctr).schedule_date  := trunc(p_new_end_date);

            ELSE
                l_pmschvtbl_ins(pms_ins_ctr).schedule_date  := l_first_sch_date;


                l_pmschvtbl_ins(pms_ins_ctr).sch_sequence  := 1;
                l_next_sch_date := okc_time_util_pub.get_enddate(trunc(l_first_sch_date)+1,
                                                     l_pmlrulv_tbl_rfr(pml_rfr_ctr).frequency_uom,
                                                     l_pmlrulv_tbl_rfr(pml_rfr_ctr).frequency);

                WHILE 1 = 1 LOOP

                    IF l_next_sch_date <= trunc(p_new_end_date) THEN
                        pms_ins_ctr                                 := pms_ins_ctr + 1;
                        IF  l_pmschv_start.COUNT > 0 THEN
                            l_pmschvtbl_ins(pms_ins_ctr)                := l_pmschv_start(1);
                        ELSE
                            l_pmschvtbl_ins(pms_ins_ctr)                := l_pmschv_end(1);
                        END IF;
                        l_pmschvtbl_ins(pms_ins_ctr).schedule_date  := l_next_sch_date;
                            l_pmschvtbl_ins(pms_ins_ctr).sch_sequence   := pms_ins_ctr;
                    ELSE
                        l_pmlrulv_tbl_ins(1)                        := l_pmlrulv_tbl_rfr(pml_rfr_ctr);
                        l_pmlrulv_tbl_ins(1).id                     := NULL;
                        l_pmlrulv_tbl_ins(1).number_of_occurences   := pms_ins_ctr;
                        l_pmlrulv_tbl_ins(1).start_date             := p_new_start_date;
                        l_pmlrulv_tbl_ins(1).end_date               := p_new_end_date;
                        l_pmlrulv_tbl_ins(1).autoschedule_yn        := 'Y';

                        EXIT;

                    END IF;
                    l_next_sch_date := okc_time_util_pub.get_enddate(trunc(l_next_sch_date)+1,
                                                     l_pmlrulv_tbl_rfr(pml_rfr_ctr).FREQUENCY_UOM,
                                                     l_pmlrulv_tbl_rfr(pml_rfr_ctr).FREQUENCY);

                END LOOP;

            END IF;

            OKS_PMS_PVT.delete_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_Del);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt delete_row', 3);
             END IF;

              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pm schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            oks_pml_pvt.delete_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_del);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt delete_row', 3);
             END IF;

             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;


             OKS_PMS_PVT.insert_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins_out);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt insert_row', 3);
             END IF;

             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'insert pm schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            oks_pml_pvt.insert_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_ins,
            x_pmlv_tbl                      => l_pmlrulv_tbl_ins_out);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt insert_row', 3);
             END IF;
             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'insert pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;


            l_next_sch_date     := NULL;
            l_first_sch_date    := NULL;
            pms_ins_ctr         := 0;
            pml_ins_ctr         := 0;
            pms_del_ctr         := 0;
            pml_del_ctr         := 0;

      ELSE -- both start date and end date passed end

        pms_del_ctr := 0;
        pml_del_ctr := 0;
        FOR i in l_rulv_tbl_in.FIRST..l_rulv_tbl_in.LAST LOOP
                IF to_number(l_rulv_tbl_in(i).SEQUENCE_NUMBER) < l_start_rule_seq OR
                   to_number(l_rulv_tbl_in(i).SEQUENCE_NUMBER) > l_end_rule_seq THEN
                    pml_del_ctr                     := pml_del_ctr + 1;
                    l_pmlrulv_tbl_del(pml_del_ctr)  := l_rulv_tbl_in(i);
                END IF;
                FOR CR_NewPMSch in Cu_NewPMSch(l_rulv_tbl_in(i).id) LOOP
                    IF trunc(p_new_start_date) > nvl(CR_NewPMSch.schedule_date,CR_NewPMSch.schedule_date_to) OR
                       trunc(p_new_end_date) < nvl(CR_NewPMSch.schedule_date,CR_NewPMSch.schedule_date_from) THEN
                    pms_del_ctr                     := pms_del_ctr + 1;
                    l_pmschvtbl_Del(pms_del_ctr)    := CR_NewPMSch;
                    END IF;
                END LOOP;
        END LOOP;

        IF l_pmschvtbl_Del.COUNT > 0 THEN

              OKS_PMS_PVT.delete_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_Del);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt delete_row', 3);
             END IF;
              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pm schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

          END IF;

          IF l_pmlrulv_tbl_del.COUNT > 0 THEN
            oks_pml_pvt.delete_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_del);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt delete_row', 3);
             END IF;

             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            END IF;
        pms_del_ctr := 0;
        pml_del_ctr := 0;


        IF trunc(p_new_start_date) <= nvl(l_pmschv_start(1).schedule_date,l_pmschv_start(1).schedule_date_from) AND
           trunc(p_new_end_date) <= nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to) THEN


            IF  NOT  (l_pmschv_start(1).sch_sequence = 1 AND
                      l_pmlrulv_tbl_start(1).id = l_first_rule_id AND
                      l_pmlrulv_tbl_start(1).AUTOSCHEDULE_YN = 'Y') THEN
              IF trunc(p_new_start_date) <> trunc(nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from)) THEN
                okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from) - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

               ELSE

                    l_duration      := NULL;
                    l_timeunit      := NULL;

               END IF;

                l_pmlrulv_tbl_start(1).OFFSET_DURATION              :=  l_duration;
                l_pmlrulv_tbl_start(1).OFFSET_UOM              :=  l_timeunit;

                IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN

                    l_pmlrulv_tbl_end(1).OFFSET_DURATION            :=  l_duration;
                    l_pmlrulv_tbl_end(1).OFFSET_UOM            :=  l_timeunit;

                END IF;

            ELSIF    (l_pmschv_start(1).sch_sequence = 1 AND
                      l_pmlrulv_tbl_start(1).id = l_first_rule_id AND
                      l_pmlrulv_tbl_start(1).AUTOSCHEDULE_YN = 'Y') THEN

               l_pmschvtbl_Ins.DELETE;
               pms_ins_ctr                  := 0;
               pms_upd_ctr                  := 0;

               l_prev_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_pmschv_start(1).schedule_date - 1,
                                                        l_pmlrulv_tbl_start(1).frequency_uom,
                                                       -1*(to_number(l_pmlrulv_tbl_start(1).frequency))));

               WHILE 1 = 1 LOOP

                IF l_prev_sch_date >= trunc(p_new_start_date) THEN

                    pms_ins_ctr                                         := pms_ins_ctr + 1;
                    l_pmschvtbl_Ins(pms_ins_ctr)                        := l_pmschv_start(1);
                    l_pmschvtbl_Ins(pms_ins_ctr).id                     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date          := l_prev_sch_date;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_from     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_to       := NULL;

                ELSE


                    IF l_pmschvtbl_Ins.COUNT > 0 THEN

                        IF trunc(p_new_start_date) <> trunc(l_pmschvtbl_Ins(pms_ins_ctr).schedule_date) THEN

                         okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => l_pmschvtbl_Ins(pms_ins_ctr).schedule_date - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                        ELSE

                            l_duration      := NULL;
                            l_timeunit      := NULL;

                        END IF;


                    ELSE

                        IF trunc(p_new_start_date) <> trunc(nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from)) THEN

                         okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from) - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                        ELSE

                            l_duration      := NULL;
                            l_timeunit      := NULL;

                        END IF;

                    END IF;

                    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    l_pmlrulv_tbl_start(1).OFFSET_DURATION              :=  l_duration;
                    l_pmlrulv_tbl_start(1).OFFSET_UOM              :=  l_timeunit;


                    IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN

                        l_pmlrulv_tbl_end(1).OFFSET_DURATION            :=  l_duration;
                        l_pmlrulv_tbl_end(1).OFFSET_UOM            :=  l_timeunit;

                    END IF;

                    EXIT;

                END IF;

                l_prev_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_prev_sch_date - 1,
                                                        l_pmlrulv_tbl_start(1).frequency_uom,
                                                       -1*(to_number(l_pmlrulv_tbl_start(1).frequency))));

               END LOOP;

            END IF;


            IF l_pmschvtbl_ins.COUNT > 0 THEN

            OKS_PMS_PVT.insert_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins_out);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt insert_row', 3);
             END IF;

              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'inserting PM schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            END IF;
             pms_ins_ctr     := 0;
             pms_upd_ctr     := 0;
             l_next_sch_seq  := 0;
             l_pmschvtbl_Upd.DELETE;

             FOR CR_NewPMSch in Cu_NewPMSch(l_pmlrulv_tbl_start(1).id) LOOP
                 IF (l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id)
                     OR
                    (l_pmschv_start(1).stream_line_id = l_pmschv_end(1).stream_line_id AND
                     nvl(CR_NewPMSch.schedule_date,CR_NewPMSch.schedule_date_to) <=
                     nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to)) THEN

                        pms_upd_ctr                                 := pms_upd_ctr + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr)                := CR_NewPMSch;
                        l_next_sch_seq                              := l_next_sch_seq + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr).sch_sequence   := l_next_sch_seq;

                  ELSE
                      EXIT;
                  END IF;

             END LOOP;

             IF l_pmschv_end(1).schedule_date_to IS NOT NULL THEN
                IF l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id THEN
                    pms_upd_ctr                                   := pms_upd_ctr + 1;
                    l_pmschvtbl_Upd(pms_upd_ctr)                  := l_pmschv_end(1);
                 END IF;
                 l_pmschvtbl_Upd(pms_upd_ctr).schedule_date_to := trunc(p_new_end_date);
              END IF;

             IF l_pmschvtbl_Upd.COUNT > 0 THEN
                OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);

                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt update_row', 3);
                 END IF;

                 IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       OKC_API.set_message
                         (G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'updating PM schedules');

                        Raise G_EXCEPTION_HALT_VALIDATION;
                 END IF;
                 pms_upd_ctr    := 0;
              END IF;

             IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN
                 l_pmlrulv_tbl_end(1).start_date              :=  p_new_start_date;
                 l_pmlrulv_tbl_start(1).end_date            :=  p_new_end_date;
             END IF;
             l_pmlrulv_tbl_start(1).start_date             :=  p_new_start_date;
             l_pmlrulv_tbl_end(1).end_date               :=  p_new_end_date;

             l_pmlrulv_tbl_start(1).number_of_occurences := l_pmschvtbl_upd.COUNT;

             IF    l_pmschv_start(1).stream_line_id = l_pmschv_end(1).stream_line_id THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschvtbl_upd.COUNT;
             ELSIF l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschv_end(1).sch_sequence;
             END IF;


        ELSIF trunc(p_new_start_date) <= nvl(l_pmschv_start(1).schedule_date,l_pmschv_start(1).schedule_date_from) AND
              trunc(p_new_end_date) >= nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to) THEN

            IF  NOT  (l_pmschv_start(1).sch_sequence = 1 AND
                      l_pmlrulv_tbl_start(1).id = l_first_rule_id AND
                      l_pmlrulv_tbl_start(1).AUTOSCHEDULE_YN = 'Y') THEN

               IF trunc(p_new_start_date) <> trunc(nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from)) THEN
                okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from) - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

               ELSE

                    l_duration      := NULL;
                    l_timeunit      := NULL;

               END IF;


                l_pmlrulv_tbl_start(1).OFFSET_DURATION              :=  l_duration;
                l_pmlrulv_tbl_start(1).OFFSET_UOM              :=  l_timeunit;

                IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN

                    l_pmlrulv_tbl_end(1).OFFSET_DURATION            :=  l_duration;
                    l_pmlrulv_tbl_end(1).OFFSET_UOM            :=  l_timeunit;

                END IF;

            ELSIF    (l_pmschv_start(1).sch_sequence = 1 AND
                      l_pmlrulv_tbl_start(1).id = l_first_rule_id AND
                      l_pmlrulv_tbl_start(1).AUTOSCHEDULE_YN = 'Y') THEN


               l_pmschvtbl_Ins.DELETE;
               pms_ins_ctr                  := 0;
               pms_upd_ctr                  := 0;

               l_prev_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_pmschv_start(1).schedule_date - 1,
                                                        l_pmlrulv_tbl_start(1).frequency_uom,
                                                       -1*(to_number(l_pmlrulv_tbl_start(1).frequency))));

               WHILE 1 = 1 LOOP

                IF l_prev_sch_date >= trunc(p_new_start_date) THEN

                    pms_ins_ctr                                         := pms_ins_ctr + 1;
                    l_pmschvtbl_Ins(pms_ins_ctr)                        := l_pmschv_start(1);
                    l_pmschvtbl_Ins(pms_ins_ctr).id                     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date          := l_prev_sch_date;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_from     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_to       := NULL;
                ELSE


                   IF l_pmschvtbl_Ins.COUNT > 0 THEN

                        IF trunc(p_new_start_date) <> trunc(l_pmschvtbl_Ins(pms_ins_ctr).schedule_date) THEN

                         okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => l_pmschvtbl_Ins(pms_ins_ctr).schedule_date - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                        ELSE

                            l_duration      := NULL;
                            l_timeunit      := NULL;

                        END IF;


                    ELSE

                        IF trunc(p_new_start_date) <> trunc(nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from)) THEN

                         okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from) - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                        ELSE

                            l_duration      := NULL;
                            l_timeunit      := NULL;

                        END IF;

                    END IF;

                    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    l_pmlrulv_tbl_start(1).OFFSET_DURATION              :=  l_duration;
                    l_pmlrulv_tbl_start(1).OFFSET_UOM              :=  l_timeunit;


                    IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN

                        l_pmlrulv_tbl_end(1).OFFSET_DURATION            :=  l_duration;
                        l_pmlrulv_tbl_end(1).OFFSET_UOM            :=  l_timeunit;

                    END IF;

                    EXIT;

                END IF;

                l_prev_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_prev_sch_date - 1,
                                                        l_pmlrulv_tbl_start(1).frequency_uom,
                                                       -1*(to_number(l_pmlrulv_tbl_start(1).frequency))));

               END LOOP;

            END IF;


            IF l_pmschvtbl_ins.COUNT > 0 THEN

            OKS_PMS_PVT.insert_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins_out);
                IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt insert_row', 3);
                END IF;
              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'inserting PM schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            END IF;

            l_pmschvtbl_ins.DELETE;


            IF    (l_pmschv_end(1).sch_sequence = l_pmschv_end_lst_seq AND
                      l_pmlrulv_tbl_end(1).id = l_last_rule_id AND
                      l_pmlrulv_tbl_end(1).AUTOSCHEDULE_YN = 'Y') THEN


               l_pmschvtbl_Ins.DELETE;
               pms_ins_ctr      := 0;

               l_next_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_pmschv_end(1).schedule_date + 1,
                                                        l_pmlrulv_tbl_end(1).frequency_uom,
                                                       to_number(l_pmlrulv_tbl_end(1).frequency)));



               WHILE 1 = 1 LOOP



                IF l_next_sch_date <= trunc(p_new_end_date) THEN

                    pms_ins_ctr                                         := pms_ins_ctr + 1;
                    l_pmschvtbl_Ins(pms_ins_ctr)                        := l_pmschv_end(1);
                    l_pmschvtbl_Ins(pms_ins_ctr).id                     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date          := l_next_sch_date;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_from     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_to       := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).sch_sequence           := l_pmschv_end(1).sch_sequence + pms_ins_ctr;

                ELSE

                    l_pmlrulv_tbl_end(1).number_of_occurences   :=   l_pmschv_end(1).sch_sequence + pms_ins_ctr;

                    EXIT;

                END IF;

                l_next_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_next_sch_date + 1,
                                                        l_pmlrulv_tbl_end(1).frequency_uom,
                                                       to_number(l_pmlrulv_tbl_end(1).frequency)));



               END LOOP;

            END IF;


            IF l_pmschvtbl_Ins.COUNT > 0 THEN

              OKS_PMS_PVT.insert_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins_out);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt insert_row', 3);
             END IF;

              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'inserting PM schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;

             END IF;


             pms_ins_ctr     := 0;
             pms_upd_ctr     := 0;
             l_next_sch_seq  := 0;
             l_pmschvtbl_Upd.DELETE;

             FOR CR_NewPMSch in Cu_NewPMSch(l_pmlrulv_tbl_start(1).id) LOOP

                        pms_upd_ctr                                 := pms_upd_ctr + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr)                := CR_NewPMSch;
                        l_next_sch_seq                              := l_next_sch_seq + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr).sch_sequence   := l_next_sch_seq;

--                  ELSE

--                      EXIT;

--                  END IF;

             END LOOP;

             IF l_pmschvtbl_Upd.COUNT > 0 THEN
                OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);

                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt update_row', 3);
                 END IF;

                 IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       OKC_API.set_message
                         (G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'updating PM schedules');

                        Raise G_EXCEPTION_HALT_VALIDATION;
                 END IF;
                 pms_upd_ctr    := 0;
              END IF;

             IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN
                 l_pmlrulv_tbl_end(1).start_date              :=  p_new_start_date;
                 l_pmlrulv_tbl_start(1).end_date            :=  p_new_end_date;
             END IF;
             l_pmlrulv_tbl_start(1).start_date             :=  p_new_start_date;
             l_pmlrulv_tbl_end(1).end_date               :=  p_new_end_date;

             l_pmlrulv_tbl_start(1).number_of_occurences := l_pmschvtbl_upd.COUNT;

             IF    l_pmschv_start(1).stream_line_id = l_pmschv_end(1).stream_line_id THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschvtbl_upd.COUNT;
             ELSIF l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id AND
                   NOT (l_pmschv_end(1).sch_sequence = l_pmschv_end_lst_seq AND
                      l_pmlrulv_tbl_end(1).id = l_last_rule_id AND
                      l_pmlrulv_tbl_end(1).AUTOSCHEDULE_YN = 'Y') THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschv_end(1).sch_sequence;
             END IF;

             pms_ins_ctr    := 0;
             pms_upd_ctr    := 0;


        ELSIF trunc(p_new_start_date) >= nvl(l_pmschv_start(1).schedule_date,l_pmschv_start(1).schedule_date_from) AND
              trunc(p_new_end_date) >= nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to) THEN

--dbms_output.put_line('117');


            l_pmschvtbl_ins.DELETE;

            IF    (l_pmschv_end(1).sch_sequence = l_pmschv_end_lst_seq AND
                      l_pmlrulv_tbl_end(1).id = l_last_rule_id AND
                      l_pmlrulv_tbl_end(1).AUTOSCHEDULE_YN = 'Y') THEN


               l_pmschvtbl_Ins.DELETE;
               pms_ins_ctr      := 0;

               l_next_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_pmschv_end(1).schedule_date + 1,
                                                        l_pmlrulv_tbl_end(1).frequency_uom,
                                                       to_number(l_pmlrulv_tbl_end(1).frequency)));

               WHILE 1 = 1 LOOP



                IF l_next_sch_date <= trunc(p_new_end_date) THEN

                    pms_ins_ctr                                         := pms_ins_ctr + 1;
                    l_pmschvtbl_Ins(pms_ins_ctr)                        := l_pmschv_end(1);
                    l_pmschvtbl_Ins(pms_ins_ctr).id                     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date          := l_next_sch_date;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_from     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_to       := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).sch_sequence           := l_pmschv_end(1).sch_sequence + pms_ins_ctr;

                ELSE

                    l_pmlrulv_tbl_end(1).number_of_occurences   :=   l_pmschv_end(1).sch_sequence + pms_ins_ctr;

                    EXIT;

                END IF;

                l_next_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_next_sch_date + 1,
                                                        l_pmlrulv_tbl_end(1).frequency_uom,
                                                       to_number(l_pmlrulv_tbl_end(1).frequency)));

               END LOOP;

            END IF;


            IF l_pmschvtbl_Ins.COUNT > 0 THEN

              OKS_PMS_PVT.insert_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins_out);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt insert_row', 3);
             END IF;

              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'inserting PM schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;

             END IF;

             l_pmschvtbl_Ins.DELETE;
             pms_ins_ctr     := 0;

             pms_upd_ctr     := 0;
             l_next_sch_seq  := 0;
             l_pmschvtbl_Upd.DELETE;

             FOR CR_NewPMSch in Cu_NewPMSch(l_pmlrulv_tbl_start(1).id) LOOP
                 IF (l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id)
                     OR
                    (l_pmschv_start(1).stream_line_id = l_pmschv_end(1).stream_line_id AND
                     nvl(CR_NewPMSch.schedule_date,CR_NewPMSch.schedule_date_to) <=
                     nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to)) THEN

                        pms_upd_ctr                                 := pms_upd_ctr + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr)                := CR_NewPMSch;
                        l_next_sch_seq                              := l_next_sch_seq + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr).sch_sequence   := l_next_sch_seq;

                  ELSE
                      EXIT;
                  END IF;

             END LOOP;

             IF l_pmschv_start(1).schedule_date_from IS NOT NULL THEN
                l_pmschvtbl_Upd(1).schedule_date_from   := trunc(p_new_start_date);
             END IF;


             IF l_pmschvtbl_Upd.COUNT > 0 THEN
                OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);

                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt update_row', 3);
                 END IF;
                 IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       OKC_API.set_message
                         (G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'updating PM schedules');

                        Raise G_EXCEPTION_HALT_VALIDATION;
                 END IF;
                 pms_upd_ctr    := 0;
              END IF;

             pms_upd_ctr     := 0;
             l_next_sch_seq  := 0;


             IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN
                 l_pmlrulv_tbl_end(1).start_date              :=  p_new_start_date;
                 l_pmlrulv_tbl_start(1).end_date            :=  p_new_end_date;
             END IF;
             l_pmlrulv_tbl_start(1).start_date             :=  p_new_start_date;
             l_pmlrulv_tbl_end(1).end_date               :=  p_new_end_date;

             l_pmlrulv_tbl_start(1).number_of_occurences := l_pmschvtbl_upd.COUNT;

             IF    l_pmschv_start(1).stream_line_id = l_pmschv_end(1).stream_line_id THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschvtbl_upd.COUNT;
             ELSIF l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id AND
                   NOT (l_pmschv_end(1).sch_sequence = l_pmschv_end_lst_seq AND
                      l_pmlrulv_tbl_end(1).id = l_last_rule_id AND
                      l_pmlrulv_tbl_end(1).AUTOSCHEDULE_YN = 'Y') THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschv_end(1).sch_sequence;
             END IF;

             l_pmschvtbl_Upd.DELETE;


        ELSIF trunc(p_new_start_date) >= nvl(l_pmschv_start(1).schedule_date,l_pmschv_start(1).schedule_date_from) AND
              trunc(p_new_end_date) <= nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to) THEN

--dbms_output.put_line('118');

             pms_upd_ctr     := 0;
             l_next_sch_seq  := 0;
             l_pmschvtbl_Upd.DELETE;

             FOR CR_NewPMSch in Cu_NewPMSch(l_pmlrulv_tbl_start(1).id) LOOP
                 IF (l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id)
                     OR
                    (l_pmschv_start(1).stream_line_id = l_pmschv_end(1).stream_line_id AND
                     nvl(CR_NewPMSch.schedule_date,CR_NewPMSch.schedule_date_to) <=
                     nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to)) THEN

                        pms_upd_ctr                                 := pms_upd_ctr + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr)                := CR_NewPMSch;
                        l_next_sch_seq                              := l_next_sch_seq + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr).sch_sequence   := l_next_sch_seq;

                  ELSE
                      EXIT;
                  END IF;

             END LOOP;

             IF l_pmschv_end(1).schedule_date_to IS NOT NULL THEN
                IF l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id THEN
                    pms_upd_ctr                                   := pms_upd_ctr + 1;
                    l_pmschvtbl_Upd(pms_upd_ctr)                  := l_pmschv_end(1);
                END IF;
                l_pmschvtbl_Upd(pms_upd_ctr).schedule_date_to := trunc(p_new_end_date);
             END IF;


             IF l_pmschv_start(1).schedule_date_from IS NOT NULL THEN
                l_pmschvtbl_Upd(1).schedule_date_from   := trunc(p_new_start_date);
             END IF;


             IF l_pmschvtbl_Upd.COUNT > 0 THEN
                OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);
                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt update_row', 3);
                 END IF;
                 IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                       OKC_API.set_message
                         (G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'updating PM schedules');

                        Raise G_EXCEPTION_HALT_VALIDATION;
                 END IF;
                 pms_upd_ctr    := 0;
              END IF;

             pms_upd_ctr     := 0;
             l_next_sch_seq  := 0;


             IF    l_pmlrulv_tbl_start(1).id = l_pmlrulv_tbl_end(1).id THEN
                 l_pmlrulv_tbl_end(1).start_date              :=  p_new_start_date;
                 l_pmlrulv_tbl_start(1).end_date            :=  p_new_end_date;
             END IF;
             l_pmlrulv_tbl_start(1).start_date             :=  p_new_start_date;
             l_pmlrulv_tbl_end(1).end_date               :=  p_new_end_date;

             IF l_pmschv_end(1).schedule_date_to IS NOT NULL THEN
                IF l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id THEN
                    l_pmlrulv_tbl_start(1).number_of_occurences      := l_pmschvtbl_upd.COUNT -1 ;
                ELSE
                    l_pmlrulv_tbl_start(1).number_of_occurences      := l_pmschvtbl_upd.COUNT;
                END IF;
             END IF;


             IF    l_pmschv_start(1).stream_line_id = l_pmschv_end(1).stream_line_id THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschvtbl_upd.COUNT;
             ELSIF l_pmschv_start(1).stream_line_id <> l_pmschv_end(1).stream_line_id THEN
                l_pmlrulv_tbl_end(1).number_of_occurences   := l_pmschv_end(1).sch_sequence;
             END IF;

             l_pmschvtbl_Upd.DELETE;


        END IF;

------dbms_output.put_line('19');

            pml_upd_ctr     := 0;

            pml_upd_ctr                                         := pml_upd_ctr + 1;
            l_pmlrulv_tbl_upd(pml_upd_ctr)                      := l_pmlrulv_tbl_start(1);
            l_pmlrulv_tbl_upd(pml_upd_ctr).object_version_number :=l_pmlrulv_tbl_start(1).object_version_number;
            --CK 09/18
            IF l_pmlrulv_tbl_start(1).id <> l_pmlrulv_tbl_end(1).id THEN
             pml_upd_ctr                                         := pml_upd_ctr + 1;
             l_pmlrulv_tbl_upd(pml_upd_ctr)                      := l_pmlrulv_tbl_end(1);
             l_pmlrulv_tbl_upd(pml_upd_ctr).object_version_number :=l_pmlrulv_tbl_end(1).object_version_number;
            END IF;

            oks_pml_pvt.update_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_upd,
            x_pmlv_tbl                      => l_pmlrulv_tbl_upd_out);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt update_row', 3);
             END IF;
             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'updating pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

             pml_upd_ctr     := 0;


      END IF;


  ELSIF trunc(p_new_start_date) IS NOT NULL AND trunc(p_new_end_date) IS NULL THEN


            pms_del_ctr := 0;
            pml_del_ctr := 0;

            FOR i in l_rulv_tbl_in.FIRST..l_rulv_tbl_in.LAST LOOP
                IF to_number(l_rulv_tbl_in(i).SEQUENCE_NUMBER) < l_start_rule_seq THEN
                    pml_del_ctr                     := pml_del_ctr + 1;
                    l_pmlrulv_tbl_del(pml_del_ctr)  := l_rulv_tbl_in(i);
                END IF;
                FOR Cr_NewPMSch in Cu_NewPMSch(l_rulv_tbl_in(i).id) LOOP
                    IF trunc(p_new_start_date) > nvl(Cr_NewPMSch.schedule_date,Cr_NewPMSch.schedule_date_to) THEN
                    pms_del_ctr                     := pms_del_ctr + 1;
                    l_pmschvtbl_Del(pms_del_ctr)    := Cr_NewPMSch;
                    END IF;
                END LOOP;
            END LOOP;

            IF l_pmschvtbl_Del.COUNT > 0 THEN
              OKS_PMS_PVT.delete_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_Del);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt delete_row', 3);
             END IF;
              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pm schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            END IF;

            IF l_pmlrulv_tbl_del.COUNT > 0 THEN
           oks_pml_pvt.delete_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_del);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt delete_row', 3);
             END IF;

             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            END IF;
        pms_del_ctr := 0;
        pml_del_ctr := 0;

      IF l_start_rule_seq IS NULL THEN -- not possible
         null;
      ELSE

          IF trunc(p_new_start_date) <= nvl(l_pmschv_start(1).schedule_date,l_pmschv_start(1).schedule_date_from)  THEN
            IF      (l_pmlrulv_tbl_start(1).id <> l_first_rule_id) OR
                    (l_pmschv_start(1).sch_sequence <> 1 AND
                     l_pmlrulv_tbl_start(1).id = l_first_rule_id ) THEN
                   l_pmlrulv_tbl_start(1).start_date             :=  p_new_start_date;

            END IF;

            pms_upd_ctr     := 0;

            IF l_pmschv_start(1).sch_sequence <> 1 THEN
                    l_next_sch_seq   := 1;

                    FOR Cr_NewPMSch in Cu_NewPMSch(l_pmschv_start(1).stream_line_id) LOOP

                        IF Cr_NewPMSch.sch_sequence >= l_pmschv_start(1).sch_sequence   THEN

                        pms_upd_ctr                                 := pms_upd_ctr + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr)                := Cr_NewPMSch;
                        l_pmschvtbl_Upd(pms_upd_ctr).sch_sequence   := l_next_sch_seq;
                        l_next_sch_seq                              := l_next_sch_seq + 1;

                        ELSE
                          EXIT;
                        END IF;
                     END LOOP;

                     OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);

                    IF (G_DEBUG_ENABLED = 'Y') THEN
                        okc_debug.log('After oks_pms_pvt update_row', 3);
                     END IF;

                    IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                        OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'updating PM schedules');

                        Raise G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    pms_upd_ctr    := 0;
                 END IF;

            IF  NOT  (l_pmschv_start(1).sch_sequence = 1 AND
                      l_pmlrulv_tbl_start(1).id = l_first_rule_id AND
                      l_pmlrulv_tbl_start(1).AUTOSCHEDULE_YN = 'Y') THEN


               IF trunc(p_new_start_date) <> trunc(nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from)) THEN
                okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from) - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);
                IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

               ELSE

                    l_duration      := NULL;
                    l_timeunit      := NULL;

               END IF;


                IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

                l_pmlrulv_tbl_start(1).OFFSET_DURATION              :=  l_duration;
                l_pmlrulv_tbl_start(1).OFFSET_UOM              :=  l_timeunit;
                l_pmlrulv_tbl_start(1).start_date              :=  p_new_start_date;

            ELSIF    (l_pmschv_start(1).sch_sequence = 1 AND
                      l_pmlrulv_tbl_start(1).id = l_first_rule_id AND
                      l_pmlrulv_tbl_start(1).AUTOSCHEDULE_YN = 'Y') THEN

               l_pmlrulv_tbl_start(1).start_date              :=  p_new_start_date;

               l_pmschvtbl_Ins.DELETE;
               l_prev_sch_date  := NULL;

               pms_ins_ctr  := 0;
               pms_upd_ctr  := 0;

               l_prev_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_pmschv_start(1).schedule_date - 1,
                                                        l_pmlrulv_tbl_start(1).frequency_uom,
                                                       -1*(to_number(l_pmlrulv_tbl_start(1).frequency))));

               WHILE 1 = 1 LOOP


                IF l_prev_sch_date >= trunc(p_new_start_date) THEN

                    pms_ins_ctr                                         := pms_ins_ctr + 1;
                    l_pmschvtbl_Ins(pms_ins_ctr)                        := l_pmschv_start(1);
                    l_pmschvtbl_Ins(pms_ins_ctr).id                     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date          := l_prev_sch_date;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_from     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_to       := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).sch_sequence           := NULL;
                ELSE



                     IF l_pmschvtbl_Ins.COUNT > 0 THEN



                        FOR i in l_pmschvtbl_Ins.FIRST..l_pmschvtbl_Ins.LAST LOOP
                          l_pmschvtbl_Ins(i).sch_sequence   := pms_ins_ctr - i + 1;
                        END LOOP;

                        l_next_sch_seq        := l_pmschvtbl_Ins.COUNT + 1;

                        FOR Cr_NewPMSch in Cu_NewPMSch(l_pmlrulv_tbl_start(1).id) LOOP
                          pms_upd_ctr                                 := pms_upd_ctr + 1;
                          l_pmschvtbl_Upd(pms_upd_ctr)                := Cr_NewPMSch;
                          l_pmschvtbl_Upd(pms_upd_ctr).sch_sequence   := l_next_sch_seq;
                          l_next_sch_seq                              := l_next_sch_seq + 1;
                        END LOOP;

                        l_pmlrulv_tbl_start(1).number_of_occurences   :=   l_next_sch_seq - 1;


                        IF trunc(p_new_start_date) <> trunc(l_pmschvtbl_Ins(pms_ins_ctr).schedule_date) THEN

                         okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => l_pmschvtbl_Ins(pms_ins_ctr).schedule_date - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                        ELSE

                            l_duration      := NULL;
                            l_timeunit      := NULL;

                        END IF;

                    ELSE

                        IF trunc(p_new_start_date) <> trunc(nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from)) THEN

                         okc_time_util_pub.get_duration(
                            p_start_date    => trunc(p_new_start_date),
                            p_end_date      => nvl(l_pmschv_start(1).schedule_date,
                                                    l_pmschv_start(1).schedule_date_from) - 1,
                            x_duration      => l_duration,
                            x_timeunit      => l_timeunit,
                            x_return_status => l_return_status);

                        ELSE

                            l_duration      := NULL;
                            l_timeunit      := NULL;

                        END IF;
                    END IF;


                    IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    l_pmlrulv_tbl_start(1).OFFSET_DURATION              :=  l_duration;
                    l_pmlrulv_tbl_start(1).OFFSET_UOM              :=  l_timeunit;

                    EXIT;

                END IF;

                l_prev_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_prev_sch_date - 1,
                                                        l_pmlrulv_tbl_start(1).frequency_uom,
                                                       -1*(to_number(l_pmlrulv_tbl_start(1).frequency))));

               END LOOP;

               OKS_PMS_PVT.insert_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins_out);
                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt insert_row', 3);
                 END IF;
                IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'insert pm schedules');

                    Raise G_EXCEPTION_HALT_VALIDATION;
                END IF;

                OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);

                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt update_row', 3);
                 END IF;
                IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'update pm schedules');

                    Raise G_EXCEPTION_HALT_VALIDATION;
                END IF;

                pms_ins_ctr  := 0;
                pms_upd_ctr  := 0;


               l_prev_sch_date      := NULL;

            END IF;


            l_pmlrulv_tbl_start(1).number_of_occurences :=
                    l_pmlrulv_tbl_start(1).number_of_occurences - l_pmschv_start(1).sch_sequence + 1;


            pml_upd_ctr     := 0;

            pml_upd_ctr                                         := pml_upd_ctr + 1;
            l_pmlrulv_tbl_upd(pml_upd_ctr)                      := l_pmlrulv_tbl_start(1);

            oks_pml_pvt.update_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_upd,
            x_pmlv_tbl                      => l_pmlrulv_tbl_upd_out);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt update_row', 3);
             END IF;
             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'updating pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

             pml_upd_ctr     := 0;

        ELSIF trunc(p_new_start_date) >= nvl(l_pmschv_start(1).schedule_date,l_pmschv_start(1).schedule_date_from) THEN

            l_pmlrulv_tbl_start(1).start_date             :=  p_new_start_date;

            pms_upd_ctr := 0;

            IF l_pmschv_start(1).sch_sequence <> 1 THEN

                    l_next_sch_seq   := 1;

                    FOR CR_NewPMSch in Cu_NewPMSch(l_pmschv_start(1).stream_line_id) LOOP

                        IF CR_NewPMSch.sch_sequence >= l_pmschv_start(1).sch_sequence   THEN

                        pms_upd_ctr                                 := pms_upd_ctr + 1;
                        l_pmschvtbl_Upd(pms_upd_ctr)                := CR_NewPMSch;
                        l_pmschvtbl_Upd(pms_upd_ctr).sch_sequence   := l_next_sch_seq;
                        l_next_sch_seq                              := l_next_sch_seq + 1;

                        ELSE
                          EXIT;
                        END IF;
                     END LOOP;

                     OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);
                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt update_row', 3);
                 END IF;

                    IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                        OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'updating PM schedules');

                        Raise G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                    pms_upd_ctr    := 0;

                 END IF;

            l_pmlrulv_tbl_start(1).OFFSET_DURATION              :=  NULL;
            l_pmlrulv_tbl_start(1).OFFSET_UOM              :=  NULL;

            l_pmlrulv_tbl_start(1).number_of_occurences              :=
--                    to_char(to_number(l_pmlrulv_tbl_start(1).number_of_occurences) - l_pmschv_start(1).sch_sequence + 1);
                    l_pmlrulv_tbl_start(1).number_of_occurences - l_pmschv_start(1).sch_sequence + 1;


            pml_upd_ctr     := 0;

            pml_upd_ctr                                         := pml_upd_ctr + 1;
            l_pmlrulv_tbl_upd(pml_upd_ctr)                      := l_pmlrulv_tbl_start(1);

            oks_pml_pvt.update_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_upd,
            x_pmlv_tbl                      => l_pmlrulv_tbl_upd_out);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt update_row', 3);
             END IF;

             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'updating pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

             pml_upd_ctr     := 0;

         END IF;

      END IF;

  ELSIF trunc(p_new_start_date) IS  NULL AND trunc(p_new_end_date) IS NOT NULL THEN

        pms_del_ctr := 0;
        pml_del_ctr := 0;

        FOR i in l_rulv_tbl_in.FIRST..l_rulv_tbl_in.LAST LOOP
                IF to_number(l_rulv_tbl_in(i).sequence_number) > l_end_rule_seq THEN
                    pml_del_ctr                     := pml_del_ctr + 1;
                    l_pmlrulv_tbl_del(pml_del_ctr)  := l_rulv_tbl_in(i);
                END IF;
                FOR CR_NewPMSch in Cu_NewPMSch(l_rulv_tbl_in(i).id) LOOP
                    IF trunc(p_new_end_date) < nvl(CR_NewPMSch.schedule_date,CR_NewPMSch.schedule_date_from) THEN
                    pms_del_ctr                     := pms_del_ctr + 1;
                    l_pmschvtbl_Del(pms_del_ctr)    := CR_NewPMSch;
                    END IF;
                END LOOP;
        END LOOP;

              OKS_PMS_PVT.delete_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_Del);

                 IF (G_DEBUG_ENABLED = 'Y') THEN
                    okc_debug.log('After oks_pms_pvt delete_row', 3);
                 END IF;

              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pm schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

            oks_pml_pvt.delete_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_del);


             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'delete pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

        pms_del_ctr := 0;
        pml_del_ctr := 0;


      IF l_end_rule_seq IS NULL THEN -- not possible
        null;
       ELSE


        IF  trunc(p_new_end_date) <= nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to)  THEN

            l_pmlrulv_tbl_upd(1)                      := l_pmlrulv_tbl_end(1);
            l_pmlrulv_tbl_upd(1).number_of_occurences    := l_pmschv_end(1).sch_sequence;
            l_pmlrulv_tbl_upd(1).end_date    := p_new_end_date;

            IF l_pmschv_end(1).schedule_date_to IS NOT NULL THEN
                  l_pmschvtbl_upd(1)                    := l_pmschv_end(1);
                  l_pmschvtbl_upd(1).schedule_date_to   := trunc(p_new_end_date);
            END IF;



            OKS_PMS_PVT.update_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_upd_out);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt update_row', 3);
             END IF;
             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'update pm schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;


            oks_pml_pvt.update_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_upd,
            x_pmlv_tbl                      => l_pmlrulv_tbl_upd_out);




             IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'updating pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
             END IF;

             pml_upd_ctr     := 0;

       ELSIF  trunc(p_new_end_date) >= nvl(l_pmschv_end(1).schedule_date,l_pmschv_end(1).schedule_date_to) THEN


            l_pmlrulv_tbl_upd(1)                      := l_pmlrulv_tbl_end(1);
            l_pmlrulv_tbl_upd(1).number_of_occurences    := l_pmschv_end(1).sch_sequence;
            l_pmlrulv_tbl_upd(1).end_date    := p_new_end_date;

            IF    (l_pmschv_end(1).sch_sequence = l_pmschv_end_lst_seq AND
                   l_pmlrulv_tbl_end(1).id = l_last_rule_id AND
                   l_pmlrulv_tbl_end(1).AUTOSCHEDULE_YN = 'Y') THEN

               l_pmschvtbl_Ins.DELETE;
               pms_ins_ctr      := 0;

               l_next_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_pmschv_end(1).schedule_date + 1,
                                                        l_pmlrulv_tbl_end(1).frequency_uom,
                                                       to_number(l_pmlrulv_tbl_end(1).frequency)));

               WHILE 1 = 1 LOOP


                IF l_next_sch_date <= trunc(p_new_end_date) THEN

                    pms_ins_ctr                                         := pms_ins_ctr + 1;
                    l_pmschvtbl_Ins(pms_ins_ctr)                        := l_pmschv_end(1);
                    l_pmschvtbl_Ins(pms_ins_ctr).id                     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date          := l_next_sch_date;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_from     := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).schedule_date_to       := NULL;
                    l_pmschvtbl_Ins(pms_ins_ctr).sch_sequence           := l_pmschv_end(1).sch_sequence + pms_ins_ctr;

                ELSE

                    l_pmlrulv_tbl_upd(1).number_of_occurences    := l_pmschv_end(1).sch_sequence + pms_ins_ctr;

                    EXIT;

                END IF;

                l_next_sch_date      :=  trunc(okc_time_util_pub.get_enddate(l_next_sch_date + 1,
                                                        l_pmlrulv_tbl_end(1).frequency_uom,
                                                       to_number(l_pmlrulv_tbl_end(1).frequency)));

               END LOOP;

               l_next_sch_date  := NULL;


               OKS_PMS_PVT.insert_row(
                        p_api_version                  => l_api_version,
                        p_init_msg_list                => l_init_msg_list,
                        x_return_status                => l_return_status,
                        x_msg_count                    => l_msg_count,
                        x_msg_data                     => l_msg_data,
                        p_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins,
                        x_oks_pm_schedules_v_tbl       => l_pmschvtbl_ins_out);
             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pms_pvt insert_row', 3);
             END IF;

              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'update pm schedules');

                Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;


            END IF;

            oks_pml_pvt.update_row(
            p_api_version                   => l_api_version,
            p_init_msg_list                 => l_init_msg_list,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data,
            p_pmlv_tbl                      => l_pmlrulv_tbl_upd,
            x_pmlv_tbl                      => l_pmlrulv_tbl_upd_out);

             IF (G_DEBUG_ENABLED = 'Y') THEN
                okc_debug.log('After oks_pml_pvt update_row', 3);
             END IF;

              IF Not l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                   OKC_API.set_message
                     (G_APP_NAME,
                      G_REQUIRED_VALUE,
                      G_COL_NAME_TOKEN,
                      'updating pml rules');

                Raise G_EXCEPTION_HALT_VALIDATION;
              END IF;



       END IF;

   END IF;

  END IF;

  END IF;

  end loop;

  end loop;
  IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Adjust_PM_Program_Schedule', 3);
		okc_debug.Reset_Indentation;
  END IF;

  x_return_status       := l_return_status;
  x_msg_count           := l_msg_count;
  x_msg_data            := l_msg_data;

EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status ;
      IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.log('Exiting Adjust_PM_Program_Schedule'||l_return_Status, 3);
		okc_debug.Reset_Indentation;
      END IF;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1	        => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);
------------dbms_output.put_line('Value of l_return_status6='||l_return_status||substr(sqlerrm,1,200));
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count :=l_msg_count;
        IF (G_DEBUG_ENABLED = 'Y') THEN
		    okc_debug.log('Exiting Adjust_PM_Program_Schedule'||sqlerrm, 3);
    		okc_debug.Reset_Indentation;
        END IF;

END ADJUST_PM_PROGRAM_SCHEDULE;

PROCEDURE migrate_to_program
          (    p_start_rowid IN ROWID,
               p_end_rowid IN ROWID,
               p_api_version                   IN NUMBER,
               p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
               x_msg_count                     OUT NOCOPY NUMBER,
               x_return_status OUT NOCOPY VARCHAR2,
               x_msg_data  OUT NOCOPY VARCHAR2)
IS
BEGIN
--stubbed out as it is no longer being used
	null;
END migrate_to_program;

PROCEDURE migrate_to_activities
          (    p_start_rowid IN ROWID,
               p_end_rowid IN ROWID,
               p_api_version                   IN NUMBER,
               p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
               x_msg_count                     OUT NOCOPY NUMBER,
               x_return_status OUT NOCOPY VARCHAR2,
               x_msg_data  OUT NOCOPY VARCHAR2)

IS
BEGIN
--stubbed out as it is no longer being used
  null;
END migrate_to_activities;

-- procedure called from CHECK_PM_MATCH
Procedure CHECK_PM_STREAM_MATCH
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Source_coverage_Line_Id       IN NUMBER,
    P_Target_coverage_Line_Id       IN NUMBER,
    P_Source_activity_Line_Id       IN NUMBER,
    P_Target_activity_Line_Id       IN NUMBER,
    x_pm_stream_match         OUT  NOCOPY VARCHAR2)
   IS


   CURSOR Cu_get_PML(cp_cov_line_id  IN NUMBER) IS
   SELECT SEQUENCE_NUMBER ,
          NUMBER_OF_OCCURENCES   ,
        FREQUENCY ,
        FREQUENCY_UOM      ,
        nvl(OFFSET_DURATION,0) OFFSET_DURATION ,
        nvl(OFFSET_UOM,0) OFFSET_UOM ,
        AUTOSCHEDULE_YN,
        ACTIVITY_LINE_ID,
        CLE_ID
        DNZ_CHR_ID
   FROM  OKS_PM_STREAM_LEVELS_V PML
   WHERE  CLE_ID=cp_cov_line_id
   and activity_line_id is null
   ORDER BY SEQUENCE_NUMBER;

   CURSOR Cu_get_ActPML(cp_activity_line_id IN NUMBER) IS
   SELECT SEQUENCE_NUMBER ,
          NUMBER_OF_OCCURENCES   ,
        FREQUENCY ,
        FREQUENCY_UOM      ,
        nvl(OFFSET_DURATION,0) OFFSET_DURATION ,
        nvl(OFFSET_UOM,0) OFFSET_UOM ,
        AUTOSCHEDULE_YN,
        ACTIVITY_LINE_ID,
        CLE_ID
        DNZ_CHR_ID
   FROM  OKS_PM_STREAM_LEVELS_V PML
   WHERE  activity_line_id =cp_activity_line_id
   ORDER BY SEQUENCE_NUMBER;


src_pml_index               NUMBER :=0;
tgt_pml_index               NUMBER :=0;
src_pml_index1              NUMBER :=0;
tgt_pml_index1              NUMBER := 0;
l_source_pml_tbl	       oks_pml_pvt.pmlv_tbl_type;
l_target_pml_tbl	       oks_pml_pvt.pmlv_tbl_type;
l_pml_match                 VARCHAR2(1);
G_MISMATCH                EXCEPTION ;

BEGIN
--Compare Program Stream Levels
--
IF P_SOURCE_ACTIVITY_LINE_ID IS NULL THEN
    FOR  CR_get_PML IN CU_get_PML(P_Source_coverage_Line_Id) LOOP
        src_pml_index :=src_pml_index +1;
        l_source_pml_tbl(src_pml_index).SEQUENCE_NUMBER := CR_get_PML.SEQUENCE_NUMBER;
        l_source_pml_tbl(src_pml_index).NUMBER_OF_OCCURENCES:= CR_get_PML.NUMBER_OF_OCCURENCES;
        l_source_pml_tbl(src_pml_index).FREQUENCY:= CR_get_PML.FREQUENCY;
        l_source_pml_tbl(src_pml_index).FREQUENCY_UOM:= CR_get_PML.FREQUENCY_UOM;
        l_source_pml_tbl(src_pml_index).OFFSET_DURATION:= CR_get_PML.OFFSET_DURATION;
        l_source_pml_tbl(src_pml_index).OFFSET_UOM:= CR_get_PML.OFFSET_UOM;
        l_source_pml_tbl(src_pml_index).AUTOSCHEDULE_YN:= CR_get_PML.AUTOSCHEDULE_YN;
    END LOOP;

    FOR  CR_get_PML IN CU_get_PML(P_Target_coverage_Line_Id) LOOP
        tgt_pml_index :=tgt_pml_index +1;
        l_target_pml_tbl(tgt_pml_index).SEQUENCE_NUMBER := CR_get_PML.SEQUENCE_NUMBER;
        l_target_pml_tbl(tgt_pml_index).NUMBER_OF_OCCURENCES:= CR_get_PML.NUMBER_OF_OCCURENCES;
        l_target_pml_tbl(tgt_pml_index).FREQUENCY:= CR_get_PML.FREQUENCY;
        l_target_pml_tbl(tgt_pml_index).FREQUENCY_UOM:= CR_get_PML.FREQUENCY_UOM;
        l_target_pml_tbl(tgt_pml_index).OFFSET_DURATION:= CR_get_PML.OFFSET_DURATION;
        l_target_pml_tbl(tgt_pml_index).OFFSET_UOM:= CR_get_PML.OFFSET_UOM;
        l_target_pml_tbl(tgt_pml_index).AUTOSCHEDULE_YN:= CR_get_PML.AUTOSCHEDULE_YN;
    END LOOP;
ELSE
    FOR  CR_get_ActPML IN CU_get_ActPML(P_Source_activity_Line_Id) LOOP
        src_pml_index :=src_pml_index +1;
        l_source_pml_tbl(src_pml_index).SEQUENCE_NUMBER := CR_get_ActPML.SEQUENCE_NUMBER;
        l_source_pml_tbl(src_pml_index).NUMBER_OF_OCCURENCES:= CR_get_ActPML.NUMBER_OF_OCCURENCES;
        l_source_pml_tbl(src_pml_index).FREQUENCY:= CR_get_ActPML.FREQUENCY;
        l_source_pml_tbl(src_pml_index).FREQUENCY_UOM:= CR_get_ActPML.FREQUENCY_UOM;
        l_source_pml_tbl(src_pml_index).OFFSET_DURATION:= CR_get_ActPML.OFFSET_DURATION;
        l_source_pml_tbl(src_pml_index).OFFSET_UOM:= CR_get_ActPML.OFFSET_UOM;
        l_source_pml_tbl(src_pml_index).AUTOSCHEDULE_YN:= CR_get_ActPML.AUTOSCHEDULE_YN;
    END LOOP;

    FOR  CR_get_ActPML IN CU_get_ActPML(P_Target_activity_Line_Id) LOOP
        tgt_pml_index :=tgt_pml_index +1;
        l_target_pml_tbl(tgt_pml_index).SEQUENCE_NUMBER := CR_get_ActPML.SEQUENCE_NUMBER;
        l_target_pml_tbl(tgt_pml_index).NUMBER_OF_OCCURENCES:= CR_get_ActPML.NUMBER_OF_OCCURENCES;
        l_target_pml_tbl(tgt_pml_index).FREQUENCY:= CR_get_ActPML.FREQUENCY;
        l_target_pml_tbl(tgt_pml_index).FREQUENCY_UOM:= CR_get_ActPML.FREQUENCY_UOM;
        l_target_pml_tbl(tgt_pml_index).OFFSET_DURATION:= CR_get_ActPML.OFFSET_DURATION;
        l_target_pml_tbl(tgt_pml_index).OFFSET_UOM:= CR_get_ActPML.OFFSET_UOM;
        l_target_pml_tbl(tgt_pml_index).AUTOSCHEDULE_YN:= CR_get_ActPML.AUTOSCHEDULE_YN;
    END LOOP;
END IF;
IF l_source_pml_tbl.count <> l_target_pml_tbl.count Then
    RAISE G_MISMATCH ;
END IF;
IF l_source_pml_tbl.count >0 then
    FOR src_pml_index1 IN l_source_pml_tbl.FIRST..l_source_pml_tbl.LAST
    LOOP
        IF l_source_pml_tbl(src_pml_index1).NUMBER_OF_OCCURENCES= l_target_pml_tbl(src_pml_index1).NUMBER_OF_OCCURENCES
            AND l_source_pml_tbl(src_pml_index1).FREQUENCY= l_target_pml_tbl(src_pml_index1).FREQUENCY
            AND l_source_pml_tbl(src_pml_index1).FREQUENCY_UOM=l_target_pml_tbl(src_pml_index1).FREQUENCY_UOM
            AND l_source_pml_tbl(src_pml_index1).OFFSET_DURATION= l_target_pml_tbl(src_pml_index1).OFFSET_DURATION
            AND l_source_pml_tbl(src_pml_index1).OFFSET_UOM= l_target_pml_tbl(src_pml_index1).OFFSET_UOM
            AND l_source_pml_tbl(src_pml_index1).AUTOSCHEDULE_YN= l_target_pml_tbl(src_pml_index1).AUTOSCHEDULE_YN THEN
            l_pml_match :='Y';
        ELSE
            l_pml_match :='N';
            exit;
        END IF;
        END LOOP;
            IF l_pml_match ='N' THEN
                RAISE G_MISMATCH ;
             END IF;
END IF;

    l_source_pml_tbl.delete;
    l_target_pml_tbl.delete;
    x_return_status:= OKC_API.G_RET_STS_SUCCESS;
    x_pm_stream_match:= 'Y';
 Exception

  When G_MISMATCH THEN
     x_pm_stream_match:= 'N';
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;

   WHEN OTHERS THEN
     OKC_API.set_message(G_APP_NAME,
			  G_UNEXPECTED_ERROR,
			  G_SQLCODE_TOKEN,
			  SQLCODE,
			  G_SQLERRM_TOKEN,
			  SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      x_pm_stream_match:= 'E';


END CHECK_PM_STREAM_MATCH;

Procedure CHECK_PM_MATCH
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Source_coverage_Line_Id       IN NUMBER,
    P_Target_coverage_Line_Id       IN NUMBER,
    x_pm_match         OUT  NOCOPY VARCHAR2)
   IS

     CURSOR CU_get_PMA(cp_cov_line_id NUMBER) IS
        SELECT
            ID ,
            CLE_ID,
            ACTIVITY_ID,
            SELECT_YN,
            CONF_REQ_YN,
            SCH_EXISTS_YN
        FROM
            oks_pm_activities
        WHERE
            cle_id=cp_cov_line_id;

  -- GLOBAL VARIABLES
src_pma_index               NUMBER :=0;
tgt_pma_index               NUMBER :=0;
src_pma_index1              NUMBER :=0;
tgt_pma_index1              NUMBER :=0;

l_source_pma_tbl           oks_pma_pvt.pmav_tbl_type;
l_target_pma_tbl           oks_pma_pvt.pmav_tbl_type;

G_MISMATCH                EXCEPTION ;
--07/28/2004
l_pma_match                 VARCHAR2(1);
l_pm_stream_match           VARCHAR2(1);
l_api_version		        CONSTANT	NUMBER     := 1.0;
l_init_msg_list	            CONSTANT	VARCHAR2(1):= 'F';
l_return_status	            VARCHAR2(1);
l_msg_count		            NUMBER;
l_msg_data		            VARCHAR2(2000):=null;
l_Source_coverage_Line_Id   NUMBER;
l_Target_coverage_Line_Id   NUMBER;

BEGIN
--Compare Program Stream Levels
--
l_Source_coverage_Line_Id :=P_Source_coverage_Line_Id;
l_Target_coverage_Line_Id :=P_Target_coverage_Line_Id;
check_pm_stream_match
       ( p_api_version 		=> l_api_version,
        p_init_msg_list 	=> l_init_msg_list,
        x_return_status		=> l_return_status,
        x_msg_count			=> l_msg_count,
        x_msg_data			=> l_msg_data,
        P_Source_coverage_Line_Id	=> l_Source_coverage_Line_Id,
        P_Target_coverage_Line_Id	=> l_Target_coverage_Line_Id,
        P_Source_activity_Line_Id	=> null,
        P_Target_activity_Line_Id	=> null,
        x_pm_stream_match			=> l_pm_stream_match);

IF l_pm_stream_match <> 'Y' THEN
	Raise G_MISMATCH;
END IF;

--Compare Activity lines
FOR CR_get_PMA IN  Cu_get_PMA(P_Source_coverage_Line_Id) LOOP
    src_pma_index :=src_pma_index+1;
    l_source_pma_tbl(src_pma_index).ID := CR_get_PMA.ID;
    l_source_pma_tbl(src_pma_index).ACTIVITY_ID := CR_get_PMA.ACTIVITY_ID;
    l_source_pma_tbl(src_pma_index).SELECT_YN := CR_get_PMA.SELECT_YN;
    l_source_pma_tbl(src_pma_index).CONF_REQ_YN := CR_get_PMA.CONF_REQ_YN;
    l_source_pma_tbl(src_pma_index).SCH_EXISTS_YN := CR_get_PMA.SCH_EXISTS_YN;
END LOOP;
FOR CR_get_PMA IN  Cu_get_PMA(P_target_coverage_Line_Id) LOOP
    tgt_pma_index :=tgt_pma_index+1;
    l_target_pma_tbl(tgt_pma_index).ID := CR_get_PMA.ID;
    l_target_pma_tbl(tgt_pma_index).ACTIVITY_ID := CR_get_PMA.ACTIVITY_ID;
    l_target_pma_tbl(tgt_pma_index).SELECT_YN := CR_get_PMA.SELECT_YN;
    l_target_pma_tbl(tgt_pma_index).CONF_REQ_YN := CR_get_PMA.CONF_REQ_YN;
    l_target_pma_tbl(tgt_pma_index).SCH_EXISTS_YN := CR_get_PMA.SCH_EXISTS_YN;
END LOOP;
IF l_source_pma_tbl.count <> l_target_pma_tbl.count Then
   RAISE G_MISMATCH ;
END IF ;
IF l_source_pma_tbl.count >0 then
    FOR src_pma_index1 IN l_source_pma_tbl.FIRST..l_source_pma_tbl.LAST
    LOOP
       FOR tgt_pma_index1 IN l_target_pma_tbl.FIRST..l_target_pma_tbl.LAST
       LOOP
        IF    l_source_pma_tbl(src_pma_index1).ACTIVITY_ID = l_target_pma_tbl(tgt_pma_index1).ACTIVITY_ID
            AND  l_source_pma_tbl(src_pma_index1).SELECT_YN = l_target_pma_tbl(tgt_pma_index1).SELECT_YN
            AND l_source_pma_tbl(src_pma_index1).CONF_REQ_YN = l_target_pma_tbl(tgt_pma_index1).CONF_REQ_YN
            AND l_source_pma_tbl(src_pma_index1).SCH_EXISTS_YN = l_target_pma_tbl(tgt_pma_index1).SCH_EXISTS_YN THEN
            l_pma_match :='Y';
            check_pm_stream_match
           ( p_api_version 		=> l_api_version,
            p_init_msg_list 	=> l_init_msg_list,
            x_return_status		=> l_return_status,
            x_msg_count			=> l_msg_count,
            x_msg_data			=> l_msg_data,
            P_Source_coverage_Line_Id	=> l_Source_coverage_Line_Id,
            P_Target_coverage_Line_Id	=> l_Target_coverage_Line_Id,
            P_Source_activity_Line_Id	=> l_source_pma_tbl(src_pma_index1).ID,
            P_Target_activity_Line_Id	=> l_target_pma_tbl(tgt_pma_index1).ID,
            x_pm_stream_match			=> l_pm_stream_match);

            IF l_pm_stream_match <> 'Y' THEN
            	Raise G_MISMATCH;
            ELSE
                exit;
            END IF;
        ELSE
            l_pma_match :='N';
        END IF;
       END LOOP;
        IF l_pma_match ='N' THEN
            RAISE G_MISMATCH ;
        END IF;
        END LOOP;
  END IF ;
        --===
l_source_pma_tbl.delete;
l_target_pma_tbl.delete;

     x_return_status:= OKC_API.G_RET_STS_SUCCESS;
     x_pm_match:= 'Y';
 Exception

  When G_MISMATCH THEN
     x_pm_match:= 'N';
     x_return_status:= OKC_API.G_RET_STS_SUCCESS;

   WHEN OTHERS THEN
     OKC_API.set_message(G_APP_NAME,
			  G_UNEXPECTED_ERROR,
			  G_SQLCODE_TOKEN,
			  SQLCODE,
			  G_SQLERRM_TOKEN,
			  SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      x_pm_match:= 'E';


END CHECK_PM_MATCH;

--Procedure modified on 02/19/04 to check if program/activity has been terminated
PROCEDURE CHECK_PM_PROGRAM_EFFECTIVITY (
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
)
IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_prog_term_flag  VARCHAR2(1);
  CURSOR l_cle_csr(p_chr_id IN NUMBER) IS
  SELECT  srvcle.id
             , srvcle.line_number
        FROM
               OKC_K_LINES_B srvcle,
                OKC_K_LINES_B covcle,
                OKS_K_LINES_B cov
        WHERE
          srvcle.chr_id      = p_chr_id
        and srvcle.id=covcle.cle_id
        and covcle.id=cov.cle_id
        and cov.pm_program_id is not null
        and covcle.lse_id in (2,15,20);

    l_cle_rec  l_cle_csr%ROWTYPE;


    CURSOR l_prog_csr(p_cle_id IN NUMBER) IS
         select 'x' terminate
         FROM  okc_k_lines_b cle,
               oks_k_lines_b pmp,
               okx_pm_programs_v  opv
         WHERE cle.id = pmp.cle_id
         and cle.dnz_chr_id  = pmp.dnz_chr_id
         and pmp.pm_program_id= opv.id1
         and cle.cle_id=p_cle_id
--         and opv.mr_status_code ='TERMINATED';
           and opv.mr_status_code  in ('TERMINATED','TERMINATE_PENDING');
     l_prog_rec l_prog_csr%ROWTYPE;

    CURSOR l_act_csr(p_cle_id IN NUMBER) IS
         select 'x' terminate
         FROM  okc_k_lines_b cle,
               oks_k_lines_b pmp,
               oks_pm_activities  oksact,
               okx_pm_activities_v act
         WHERE cle.id = pmp.cle_id
         and cle.dnz_chr_id  = pmp.dnz_chr_id
--changed for using index         and pmp.pm_program_id= oksact.program_id
         and pmp.cle_id= oksact.cle_id
         and oksact.activity_id=act.id1
         and cle.cle_id=p_cle_id
--         and act.mr_status_code = 'TERMINATED'
           and act.mr_status_code  in ('TERMINATED','TERMINATE_PENDING')
         and rownum <2;
     l_act_rec l_act_csr%ROWTYPE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN l_cle_csr(p_chr_id);

    LOOP
       FETCH l_cle_csr INTO l_cle_rec;
       EXIT WHEN l_cle_csr%NOTFOUND;
       l_prog_term_flag :='N';
       OPEN  l_prog_csr(l_cle_rec.id);
       FETCH l_prog_csr into l_prog_rec;
       If l_prog_csr%FOUND THEN
            If l_prog_rec.terminate is not null THEN
                    OKC_API.set_message(
                    p_app_name      => G_APP_NAME_OKS,
                    p_msg_name      => 'OKS_PM_PROGRAM_EFFECTIVITY',
                    p_token1	    => 'CONTRACT_LINE',
                    p_token1_value    =>l_cle_rec.line_number);
                    -- notify caller of an error
--modified to return 'E' instead of 'W'    x_return_status := 'W'; --OKC_API.G_RET_STS_ERROR;
                    x_return_status := 'E'; --OKC_API.G_RET_STS_ERROR;
                    l_prog_term_flag :='Y';
             End if;--03/01
        END IF;
         CLOSE l_prog_csr;
         IF l_prog_term_flag <> 'Y' THEN --03/01
            OPEN  l_act_csr(l_cle_rec.id);
            FETCH l_act_csr into l_act_rec;
            If l_act_csr%FOUND THEN
            If l_act_rec.terminate is not null THEN
                      OKC_API.set_message(
                      p_app_name      => G_APP_NAME_OKS,
                      p_msg_name      => 'OKS_PM_PROGRAM_EFFECTIVITY',
-- token replaced                     p_token1	    => 'LINE_NUMBER',
                      p_token1	    => 'CONTRACT_LINE',
                      p_token1_value    =>l_cle_rec.line_number);
                     -- notify caller of an error
--modified to return 'E' instead of 'W'    x_return_status := 'W'; --OKC_API.G_RET_STS_ERROR;
                     x_return_status := 'E';
                End If;
                End if;
                CLOSE l_act_csr;
  END IF;--03/01
     END LOOP;
     CLOSE l_cle_csr;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack

    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_cle_csr%ISOPEN THEN
      CLOSE l_cle_csr;
    END IF;
    IF l_prog_csr%ISOPEN THEN
      CLOSE l_prog_csr;
    END IF;
  END CHECK_PM_PROGRAM_EFFECTIVITY;

--new procedure for QA check with return as  'Error'
PROCEDURE CHECK_PM_REQUIRED_VALUES (
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
)
IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_prog_term_flag  VARCHAR2(1);
    l_prog1_term_flag VARCHAR2(1);
  CURSOR l_cle_csr(p_chr_id IN NUMBER) IS
  SELECT  srvcle.id
             , srvcle.line_number
        FROM
               OKC_K_LINES_B srvcle,
                OKC_K_LINES_B covcle,
                OKS_K_LINES_B cov
        WHERE
          srvcle.chr_id      = p_chr_id
        and srvcle.id=covcle.cle_id
        and covcle.id=cov.cle_id
        and cov.pm_program_id is not null
        and covcle.lse_id in (2,15,20);

    l_cle_rec  l_cle_csr%ROWTYPE;

     CURSOR l_prog_csr(p_cle_id IN NUMBER) IS
         select opv.mr_header_id
         FROM  okc_k_lines_b cle,
               oks_k_lines_b pmp,
               --okx_pm_programs_v  opv
               ahl_mr_headers_b opv
         WHERE cle.id = pmp.cle_id
         and cle.dnz_chr_id  = pmp.dnz_chr_id
         and pmp.pm_program_id= opv.mr_header_id
         and cle.cle_id=p_cle_id
         and trunc(opv.effective_from) > trunc(cle.start_date);
     l_prog_rec l_prog_csr%ROWTYPE;

    CURSOR l_act_csr(p_cle_id IN NUMBER) IS
         select act.mr_header_id
         FROM  okc_k_lines_b cle,
               oks_k_lines_b pmp,
               oks_pm_activities  oksact,
               ahl_mr_headers_b act
         WHERE cle.id = pmp.cle_id
         and cle.dnz_chr_id  = pmp.dnz_chr_id
         and pmp.cle_id= oksact.cle_id
         and oksact.activity_id=act.mr_header_id
         and cle.cle_id=p_cle_id
         and trunc(act.effective_from) > trunc(cle.start_date)
         and rownum <2;
     l_act_rec l_act_csr%ROWTYPE;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN l_cle_csr(p_chr_id);

    LOOP
       FETCH l_cle_csr INTO l_cle_rec;
       EXIT WHEN l_cle_csr%NOTFOUND;
       l_prog_term_flag :='N';
       OPEN  l_prog_csr(l_cle_rec.id);
       FETCH l_prog_csr into l_prog_rec;
       If l_prog_csr%FOUND THEN
            If l_prog_rec.mr_header_id is not null THEN
                    OKC_API.set_message(
                    p_app_name      => G_APP_NAME_OKS,
                    p_msg_name      => 'OKS_PM_MR_EFFECTIVITY',
                    p_token1	    => 'CONTRACT_LINE',
                    p_token1_value    =>l_cle_rec.line_number);
                    -- notify caller of an error
                    x_return_status := 'E'; --OKC_API.G_RET_STS_ERROR;
                    l_prog_term_flag :='Y';
             End if;
        END IF;
         CLOSE l_prog_csr;
         IF l_prog_term_flag <> 'Y' THEN
            OPEN  l_act_csr(l_cle_rec.id);
            FETCH l_act_csr into l_act_rec;
            If l_act_csr%FOUND THEN
            If l_act_rec.mr_header_id is not null THEN
                      OKC_API.set_message(
                      p_app_name      => G_APP_NAME_OKS,
                      p_msg_name      => 'OKS_PM_MR_EFFECTIVITY',
                      p_token1	    => 'CONTRACT_LINE',
                      p_token1_value    =>l_cle_rec.line_number);
                     -- notify caller of an error
                      x_return_status := 'E'; --OKC_API.G_RET_STS_ERROR;
                End If;
                End if;
                CLOSE l_act_csr;
          END IF;
     END LOOP;
     CLOSE l_cle_csr;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack

    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_cle_csr%ISOPEN THEN
      CLOSE l_cle_csr;
    END IF;
    IF l_prog_csr%ISOPEN THEN
      CLOSE l_prog_csr;
    END IF;
  END CHECK_PM_REQUIRED_VALUES;


PROCEDURE check_pm_schedule (
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
)
IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
 /* Modified by jvorugan for Bug:5215180
 CURSOR l_cle_csr(p_chr_id IN NUMBER) IS
      SELECT  srvcle.id
             , srvcle.line_number
        FROM
               OKC_K_LINES_B srvcle,
                OKC_K_LINES_B covcle,
                OKS_K_LINES_B cov
        WHERE
          srvcle.chr_id      = p_chr_id
        and srvcle.id=covcle.cle_id
        and covcle.id=cov.cle_id
        and cov.pm_program_id is not null
        and covcle.lse_id in (2,15,20);
*/

 CURSOR l_cle_csr(p_chr_id IN NUMBER) IS
      SELECT  srvcle.id
             , srvcle.line_number
        FROM
               OKC_K_LINES_B srvcle,
                OKS_K_LINES_B cov
        WHERE
          srvcle.chr_id      = p_chr_id
        and srvcle.id=cov.cle_id
        and cov.pm_program_id is not null
        and srvcle.lse_id in (1,14,19);


/*    CURSOR l_cle_csr(p_chr_id IN NUMBER) IS
      SELECT  cle.id
            , lse.lty_code
             , cle.name
             , cle.start_date
             , cle.end_date
             , cim.jtot_object1_code
             , cim.object1_id1
             , cim.object1_id2
             , cle.line_number
        FROM   OKC_K_ITEMS cim,
               OKC_LINE_STYLES_B lse,
               OKC_K_LINES_V cle
        WHERE  cim.cle_id      = cle.id
        and    lse.id          = cle.lse_id
        and    cle.chr_id      = p_chr_id
        and    cle.lse_id in (2,15,20);*/

      l_cle_rec  l_cle_csr%ROWTYPE;
--not needed
/*    CURSOR l_prog_csr(p_cle_id IN NUMBER) IS
     SELECT  pmp.id
         FROM  okc_k_lines_b cle,oks_k_lines_b pmp
         WHERE cle.id = pmp.cle_id
         and cle.dnz_chr_id  = pmp.dnz_chr_id
         and cle.cle_id=p_cle_id
         and pmp.pm_program_id is not null;

     l_prog_rec l_prog_csr%ROWTYPE;*/

 /* Modified by Jvorugan for Bug:5215180
 CURSOR l_sch_csr(p_cle_id IN NUMBER) IS

         SELECT pms.id
         FROM  okc_k_lines_b cle,
               oks_pm_schedules_v pms
         WHERE cle.id = pms.cle_id
         and cle.cle_id=p_cle_id
         --added condition
         and pms.activity_line_id is null;
*/
 CURSOR l_sch_csr(p_cle_id IN NUMBER) IS

         SELECT pms.id
         FROM  oks_pm_schedules_v pms
         WHERE  pms.cle_id = p_cle_id
         --added condition
         and pms.activity_line_id is null;

     l_sch_rec l_sch_csr%ROWTYPE;
--CK
/* Modified by Jvorugan for Bug:5215180
CURSOR l_act_csr(p_cle_id IN NUMBER) IS
     SELECT  pma.id
         FROM okc_k_lines_b cle,
         oks_pm_activities pma
           WHERE cle.id = pma.cle_id
         and cle.cle_id=p_cle_id;
*/
CURSOR l_act_csr(p_cle_id IN NUMBER) IS
     SELECT  pma.id
         FROM  oks_pm_activities pma
           WHERE  pma.cle_id = p_cle_id;
     l_act_rec l_act_csr%ROWTYPE;


/* Modified by JVorugan for Bug:5215180
CURSOR l_actsch_csr(p_cle_id IN NUMBER) IS
         SELECT pms.id
         FROM  okc_k_lines_b cle,
               oks_pm_schedules_v pms
         WHERE cle.id = pms.cle_id
         and cle.cle_id=p_cle_id
         and activity_line_id is not null;
*/
CURSOR l_actsch_csr(p_cle_id IN NUMBER) IS
         SELECT pms.id
         FROM oks_pm_schedules_v pms
         WHERE pms.cle_id = p_cle_id
         and activity_line_id is not null;


      l_actsch_rec l_actsch_csr%ROWTYPE;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN l_cle_csr(p_chr_id);

    LOOP

       FETCH l_cle_csr INTO l_cle_rec;
       EXIT WHEN l_cle_csr%NOTFOUND;
/*       OPEN  l_prog_csr(l_cle_rec.id);
       FETCH l_prog_csr into l_prog_rec;
       If    (l_prog_csr%FOUND) Then
*/
            OPEN  l_sch_csr(l_cle_rec.id);
            FETCH l_sch_csr into l_sch_rec;
            If    l_sch_csr%NOTFOUND  Then

                    OKC_API.set_message(
                    p_app_name      => G_APP_NAME_OKS,
                    p_msg_name      => 'OKS_PM_REQUIRED_SCHEDULE',
--03/23 modified token
 --                   p_token1	    => 'LINE_NUMBER',
                    p_token1	    => 'CONTRACT_LINE',
                    p_token1_value    =>l_cle_rec.line_number);

                -- notify caller of an error
                --modified to return 'E' instead of 'W'    x_return_status := 'W'; --OKC_API.G_RET_STS_ERROR;
                  x_return_status := 'E';

            End If;
--        END IF;

        IF l_sch_csr%ISOPEN THEN
                CLOSE l_sch_csr;
        END IF;
--        CLOSE l_prog_csr;
     END LOOP;

     --CK
       OPEN  l_act_csr(l_cle_rec.id);
       FETCH l_act_csr into l_act_rec;
       If    (l_act_csr%FOUND) Then
            OPEN  l_actsch_csr(l_cle_rec.id);
            FETCH l_actsch_csr into l_actsch_rec;
            If    (l_actsch_csr%NOTFOUND) Then

                    OKC_API.set_message(
                    p_app_name      => G_APP_NAME_OKS,
                    p_msg_name      => 'OKS_PMACT_REQUIRED_SCHEDULE',
--03/23 modified token
 --                   p_token1	    => 'LINE_NUMBER',
                    p_token1	    => 'CONTRACT_LINE',
                    p_token1_value    =>l_cle_rec.line_number);
                -- notify caller of an error
                --modified to return 'E' instead of 'W'    x_return_status := 'W'; --OKC_API.G_RET_STS_ERROR;
                  x_return_status := 'E'; --OKC_API.G_RET_STS_ERROR;
            End If;
            CLOSE l_actsch_csr;
    END if;
    CLOSE l_act_csr;
    --CK
     CLOSE l_cle_csr;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack

    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_cle_csr%ISOPEN THEN
      CLOSE l_cle_csr;
    END IF;
  /*  IF l_prog_csr%ISOPEN THEN
      CLOSE l_prog_csr;
    END IF;*/

   IF l_sch_csr%ISOPEN THEN
      CLOSE l_sch_csr;
    END IF;

END check_pm_schedule;

--02/18 added new qa check to check for new activities added to program in CMRO
PROCEDURE check_pm_new_activities(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
)
IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_act_tbl               act_tbl_type;
/* Modified by Jvorugan for Bug:5215180
CURSOR l_cle_csr(p_chr_id IN NUMBER) IS
  SELECT  srvcle.id
             , srvcle.line_number
        FROM
               OKC_K_LINES_B srvcle,
                OKC_K_LINES_B covcle,
                OKS_K_LINES_B cov
        WHERE
          srvcle.chr_id      = p_chr_id
        and srvcle.id=covcle.cle_id
        and covcle.id=cov.cle_id
        and cov.pm_program_id is not null
        and covcle.lse_id in (2,15,20);
*/
CURSOR l_cle_csr(p_chr_id IN NUMBER) IS
  SELECT  srvcle.id
             , srvcle.line_number
        FROM
               OKC_K_LINES_B srvcle,
                OKS_K_LINES_B cov
        WHERE
          srvcle.chr_id      = p_chr_id
        and srvcle.id=cov.cle_id
        and cov.pm_program_id is not null
        and srvcle.lse_id in (1,14,19);


    l_cle_rec  l_cle_csr%ROWTYPE;

--Cursor to fetch activities for the program defined in CMRO
    CURSOR l_prog_csr(p_cle_id IN NUMBER) IS
         SELECT act.id1 activity_id
         FROM  okc_k_lines_b cle,
               oks_k_lines_b okscle,
               okx_pm_activities_v  act
         WHERE cle.id = okscle.cle_id
         and cle.dnz_chr_id  = okscle.dnz_chr_id
         and okscle.pm_program_id= act.program_id
	 and cle.id =p_cle_id
       -- modified by Jvorugan for Bug:5215180  and cle.cle_id=p_cle_id
         and act.mr_status_code='COMPLETE';
     l_prog_rec l_prog_csr%ROWTYPE;

--Cursor to fetch activities for the program associated with the service line
    CURSOR l_act_csr(p_cle_id IN NUMBER) IS
         SELECT oksact.activity_id
         FROM  okc_k_lines_b cle,
               oks_k_lines_b okscle,
               oks_pm_activities_v  oksact
         WHERE cle.id = okscle.cle_id
         and cle.dnz_chr_id  = okscle.dnz_chr_id
         and cle.id=oksact.cle_id
         and cle.dnz_chr_id=oksact.dnz_chr_id
	 and cle.id=p_cle_id;
       -- Modified by Jvorugan for Bug:5215180 and cle.cle_id=p_cle_id;

     l_act_rec l_act_csr%ROWTYPE;
     l_act_ctr NUMBER;
     l_act_ctr1 NUMBER;
     l_act_exists  VARCHAR2(1):='Y';
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN l_cle_csr(p_chr_id);

    LOOP
       FETCH l_cle_csr INTO l_cle_rec;
       EXIT WHEN l_cle_csr%NOTFOUND;
       l_act_tbl.DELETE;
       OPEN  l_prog_csr(l_cle_rec.id);
       l_act_ctr :=0;
       LOOP
         l_act_ctr :=l_act_ctr+1;
          FETCH l_prog_csr into l_act_tbl(l_act_ctr).activity_id;
          EXIT WHEN l_prog_csr%NOTFOUND;
       END LOOP;
       CLOSE l_prog_csr;
        l_act_ctr1 :=1;
       IF l_act_tbl.count > 0 THEN
       FOR l_act_ctr1 in 1..l_act_tbl.count LOOP
       OPEN  l_act_csr(l_cle_rec.id);
       LOOP
          FETCH l_act_csr into l_act_rec;
          IF l_act_tbl(l_act_ctr1).activity_id=l_act_rec.activity_id THEN
                    l_act_exists :='Y';
                    exit;
          ELSE
                     l_act_exists :='N';
          END IF;
--          l_act_ctr1 :=l_act_ctr1+1;
          EXIT WHEN l_act_csr%NOTFOUND;
       END LOOP;
       CLOSE l_act_csr;
--       END LOOP;
       IF l_act_exists ='N' THEN
                      OKC_API.set_message(
                      p_app_name      => G_APP_NAME_OKS,
                      p_msg_name      => 'OKS_PM_NEW_ACTIVITIES',
-- 03/23 changed token                     p_token1	    => 'LINE_NUMBER',
                      p_token1	    => 'CONTRACT_LINE',
                      p_token1_value    =>l_cle_rec.line_number);
                     -- notify caller of an error
                     --modified to return 'E' instead of 'W'    x_return_status := 'W'; --OKC_API.G_RET_STS_ERROR;
                      x_return_status := 'E'; --OKC_API.G_RET_STS_ERROR;
       END IF;
       END LOOP;
       END IF;
     END LOOP;
     CLOSE l_cle_csr;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack

    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_cle_csr%ISOPEN THEN
      CLOSE l_cle_csr;
    END IF;
    IF l_prog_csr%ISOPEN THEN
      CLOSE l_prog_csr;
    END IF;
  END check_pm_new_activities;

PROCEDURE UNDO_PM_LINE(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cle_id               IN NUMBER--COVERAGE LINE ID
    ) IS

    CURSOR CU_GET_PMA IS
    SELECT ID FROM OKS_PM_ACTIVITIES
    WHERE CLE_ID = p_cle_id;

    CURSOR CU_GET_PML IS
    SELECT ID FROM OKS_PM_STREAM_LEVELS
    WHERE CLE_ID = p_cle_id;

    CURSOR CU_GET_SCH IS
    SELECT ID FROM OKS_PM_SCHEDULES
    WHERE CLE_ID = p_cle_id;
    l_pmav_tbl  OKS_PMA_PVT.pmav_tbl_type ;
    l_pmlv_tbl  OKS_PML_PVT.pmlv_tbl_type ;
    l_pm_schedules_v_tbl  OKS_PMS_PVT.oks_pm_schedules_v_tbl_type ;
    l_pma_index NUMBER :=0;
    l_pml_index NUMBER :=0;
    l_sch_index NUMBER :=0;
    l_api_version		               CONSTANT	NUMBER     := 1.0;
    l_init_msg_list	               CONSTANT	VARCHAR2(1):= 'F';
    l_return_status	               VARCHAR2(1);
    l_msg_count		               NUMBER;
    l_msg_data		               VARCHAR2(2000):=null;
    l_msg_index_out                  Number;
    l_api_name                       CONSTANT VARCHAR2(30) := 'UNDO  PM LINE';

BEGIN
IF (G_DEBUG_ENABLED = 'Y') THEN
		okc_debug.Set_Indentation('Undo_PM_Line');
		okc_debug.log('Entered Undo_PM_Line', 3);
END IF;
x_return_status:=OKC_API.G_Ret_Sts_Success;
--Deleting activities
  FOR CR_GET_PMA IN CU_GET_PMA
  LOOP
        l_pma_index:= l_pma_index + 1 ;
        l_pmav_tbl(l_pma_index).id:= CR_GET_PMA.ID;
  END LOOP ;

  IF l_pmav_tbl.count  <> 0 then
   OKS_PMA_PVT.delete_row(
    p_api_version               => l_api_version,
    p_init_msg_list             => l_init_msg_list,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    p_pmav_tbl                  =>   l_pmav_tbl);
   END IF ;
   IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.log('After OKS_PMA_PVT delete_row', 3);
   END IF;

   IF NOT nvl(l_return_status,'S') = OKC_API.G_RET_STS_SUCCESS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;
     OKC_API.Set_Message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ERROR IN DELETING PM Activities');
      RETURN;
   END IF;
   --Deleting stream levels
   FOR CR_GET_PML IN CU_GET_PML
   LOOP
        l_pml_index:= l_pml_index + 1 ;
        l_pmlv_tbl(l_pml_index).id:= CR_GET_PML.ID;
   END LOOP ;

  IF l_pmlv_tbl.count  <> 0 then
   OKS_PML_PVT.delete_row(
    p_api_version               => l_api_version,
    p_init_msg_list             => l_init_msg_list,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    p_pmlv_tbl                  =>   l_pmlv_tbl);
   END IF ;

   IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.log('After OKS_PML_PVT delete_row', 3);
   END IF;

   IF NOT nvl(l_return_status,'S') = OKC_API.G_RET_STS_SUCCESS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;
     OKC_API.Set_Message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ERROR IN DELETING PM Stream Levels');
      RETURN;
   END IF;
--Deleting schedules
  FOR CR_GET_SCH IN CU_GET_SCH
  LOOP
        l_sch_index:= l_sch_index + 1 ;
        l_pm_schedules_v_tbl(l_sch_index).id:= CR_GET_SCH.ID;
  END LOOP ;

  IF l_pm_schedules_v_tbl.count  <> 0 then
   OKS_PMS_PVT.delete_row(
    p_api_version                       => l_api_version,
    p_init_msg_list             => l_init_msg_list,
    x_return_status             => l_return_status,
    x_msg_count                 => l_msg_count,
    x_msg_data                  => l_msg_data,
    p_oks_pm_schedules_v_tbl    =>   l_pm_schedules_v_tbl);
   END IF ;

   IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.log('After OKS_PMS_PVT delete_row', 3);
   END IF;

   IF NOT nvl(l_return_status,'S') = OKC_API.G_RET_STS_SUCCESS THEN
     x_return_status := OKC_API.G_RET_STS_ERROR;
     OKC_API.Set_Message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ERROR IN DELETING PM_SCHEDULES');
      RETURN;
   END IF;
   IF (G_DEBUG_ENABLED = 'Y') THEN
        okc_debug.log('Exiting Undo_PM_Line', 3);
        okc_debug.Reset_Indentation;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
    x_msg_count :=l_msg_count;
    OKC_API.SET_MESSAGE(
      p_app_name        => g_app_name,
      p_msg_name        => g_unexpected_error,
      p_token1	        => g_sqlcode_token,
      p_token1_value    => sqlcode,
      p_token2          => g_sqlerrm_token,
      p_token2_value    => sqlerrm);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF (G_DEBUG_ENABLED = 'Y') THEN
	    okc_debug.log('Exiting Undo_PM_Line'||sqlerrm, 3);
    	okc_debug.Reset_Indentation;
    END IF;
END UNDO_PM_LINE;

PROCEDURE INIT_OKS_K_LINE(x_klnv_tbl  OUT NOCOPY OKS_KLN_PVT.klnv_tbl_type)
IS


BEGIN


 x_klnv_tbl(1).ID                     :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLE_ID                 :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DNZ_CHR_ID             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DISCOUNT_LIST          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).ACCT_RULE_ID           :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).PAYMENT_TYPE           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).CC_NO                  :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).CC_EXPIRY_DATE         :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).CC_BANK_ACCT_ID        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CC_AUTH_CODE           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).COMMITMENT_ID          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).LOCKED_PRICE_LIST_ID   :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).USAGE_EST_YN           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).USAGE_EST_METHOD       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).USAGE_EST_START_DATE   :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).TERMN_METHOD           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).UBT_AMOUNT             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CREDIT_AMOUNT          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SUPPRESSED_CREDIT      :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).OVERRIDE_AMOUNT        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).GRACE_DURATION         :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).GRACE_PERIOD           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).INV_PRINT_FLAG         :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PRICE_UOM              :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TAX_AMOUNT             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TAX_INCLUSIVE_YN       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TAX_STATUS             :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TAX_CODE               :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TAX_EXEMPTION_ID       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).IB_TRANS_TYPE          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).IB_TRANS_DATE          :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).PROD_PRICE             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SERVICE_PRICE          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_LIST_PRICE        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_QUANTITY          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_EXTENDED_AMT      :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CLVL_UOM_CODE          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TOPLVL_OPERAND_CODE    :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TOPLVL_OPERAND_VAL     :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TOPLVL_QUANTITY        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TOPLVL_UOM_CODE        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TOPLVL_ADJ_PRICE       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).TOPLVL_PRICE_QTY       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).AVERAGING_INTERVAL     :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SETTLEMENT_INTERVAL    :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).MINIMUM_QUANTITY       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DEFAULT_QUANTITY       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).AMCV_FLAG              :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).FIXED_QUANTITY         :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).USAGE_DURATION         :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).USAGE_PERIOD           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).LEVEL_YN               :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).USAGE_TYPE             :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).UOM_QUANTIFIED         :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).BASE_READING           :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).BILLING_SCHEDULE_TYPE  :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).COVERAGE_TYPE          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).EXCEPTION_COV_ID       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).LIMIT_UOM_QUANTIFIED   :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).DISCOUNT_AMOUNT        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).DISCOUNT_PERCENT       :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).OFFSET_DURATION        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).OFFSET_PERIOD          :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).INCIDENT_SEVERITY_ID   :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).PDF_ID                 :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).WORK_THRU_YN           :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).REACT_ACTIVE_YN        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).TRANSFER_OPTION        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PROD_UPGRADE_YN        :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).INHERITANCE_TYPE       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PM_PROGRAM_ID          :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).PM_CONF_REQ_YN         :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).PM_SCH_EXISTS_YN       :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).ALLOW_BT_DISCOUNT      :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).APPLY_DEFAULT_TIMEZONE :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).SYNC_DATE_INSTALL      :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).SFWT_FLAG              :=  OKC_API.G_MISS_CHAR;
 x_klnv_tbl(1).OBJECT_VERSION_NUMBER  :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).SECURITY_GROUP_ID      :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).REQUEST_ID             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CREATED_BY             :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).CREATION_DATE          :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).LAST_UPDATED_BY        :=  OKC_API.G_MISS_NUM;
 x_klnv_tbl(1).LAST_UPDATE_DATE       :=  OKC_API.G_MISS_DATE;
 x_klnv_tbl(1).LAST_UPDATE_LOGIN      :=  OKC_API.G_MISS_NUM;
END init_oks_k_line;


PROCEDURE Version_PM(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER,
                p_major_version                IN NUMBER) IS

l_chr_id CONSTANT NUMBER  := p_chr_id;
l_major_version CONSTANT NUMBER  := p_major_version;
l_return_Status VARCHAR2(1);

BEGIN


l_return_Status := OKS_PMA_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

l_return_Status := OKS_PML_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

l_return_Status := OKS_PMS_PVT.Create_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

x_return_status :=  OKC_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Version_PM;


PROCEDURE Restore_PM(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER)
                IS --take out p_major_version from here from pub/pvt spec and body

l_chr_id CONSTANT NUMBER  := p_chr_id;
l_major_version CONSTANT NUMBER  := -1; --p_major_version;
l_return_Status VARCHAR2(1);

BEGIN


l_return_Status := OKS_PMA_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

l_return_Status := OKS_PML_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

l_return_Status := OKS_PMS_PVT.Restore_Version(
                            p_id  => l_chr_id,
                            p_major_version  =>l_major_version);

x_return_status :=  OKC_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Restore_PM;



PROCEDURE	Delete_PMHistory(
    			p_api_version                  IN NUMBER,
    			p_init_msg_list                IN VARCHAR2,
    			x_return_status                OUT NOCOPY VARCHAR2,
    			x_msg_count                    OUT NOCOPY NUMBER,
    			x_msg_data                     OUT NOCOPY VARCHAR2,
    			p_chr_id                       IN NUMBER) IS

l_chr_id CONSTANT NUMBER  := p_chr_id;
l_return_Status VARCHAR2(1);

BEGIN

DELETE OKS_PM_SCHEDULES
WHERE dnz_chr_id = l_chr_id;

DELETE OKS_PM_STREAM_LEVELS
WHERE dnz_chr_id = l_chr_id;

DELETE OKS_PM_ACTIVITIES
WHERE dnz_chr_id = l_chr_id;

x_return_status :=  OKC_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN

       OKC_API.SET_MESSAGE(
        p_app_name        => g_app_name,
        p_msg_name        => g_unexpected_error,
        p_token1                => g_sqlcode_token,
        p_token1_value    => sqlcode,
        p_token2          => g_sqlerrm_token,
        p_token2_value    => sqlerrm);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Delete_PMHistory;

PROCEDURE Delete_PMSaved_Version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER) IS

 l_api_version   			NUMBER := 1;
l_init_msg_list            	VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
l_return_status            	VARCHAR2(1);
l_return_msg               	VARCHAR2(2000);
l_msg_count                	NUMBER;
l_msg_data                 	VARCHAR2(2000);
l_api_name                 	VARCHAR2(30):= 'Delete_Saved_Version';
l_chr_id					CONSTANT NUMBER  := p_chr_id;

BEGIN

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
					           p_init_msg_list,
					                    '_PUB',
                                         x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR)
    THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    ELSIF l_return_status IS NULL
    THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


				DELETE OKS_PM_SCHEDULES_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;

				DELETE OKS_PM_STREAM_LEVELS_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;

				DELETE OKS_PM_ACTIVITIES_H
				WHERE dnz_chr_id = l_chr_id
				And major_version = -1;

    x_Return_status:=l_Return_Status;

EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKC_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PUB');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKC_API.G_RET_STS_UNEXP_ERROR',
       x_msg_count,
       x_msg_data,
       '_PUB');
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK ;
END Delete_PMSaved_Version;

  /*  New procedure for copying PM for coverage template. This procedure is called by
      oks_coverages_pvt.copy_coverage while copying the standard coverage template. */

PROCEDURE  Copy_PM_Template (
                p_api_version           IN NUMBER,
                p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_old_coverage_id       IN NUMBER,
                p_new_coverage_id       IN NUMBER) IS   --instantiated cle id

---------------------------------------------------------

l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_old_cle_id    NUMBER;
l_new_cle_id    NUMBER;

-- This function is to insert values into oks_pm_activities
FUNCTION CREATE_OKS_PM_ACTIVITIES(p_new_cle_id NUMBER,
                                  p_old_cle_id NUMBER) return VARCHAR2 IS

l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

 INSERT INTO oks_pm_activities
   ( ID,
     CLE_ID,
     DNZ_CHR_ID,
     ACTIVITY_ID,
     SELECT_YN,
     CONF_REQ_YN,
     SCH_EXISTS_YN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     OBJECT_VERSION_NUMBER,
     SECURITY_GROUP_ID,
     REQUEST_ID,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
   --  SERVICE_LINE_ID,
     ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_SOURCE_CODE,
     ORIG_SYSTEM_REFERENCE1 )
 SELECT
     okc_p_util.raw_to_number(sys_guid()),
     p_new_cle_id CLE_ID,
     DNZ_CHR_ID,
     ACTIVITY_ID,
     SELECT_YN,
     CONF_REQ_YN,
     SCH_EXISTS_YN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     OBJECT_VERSION_NUMBER,
     SECURITY_GROUP_ID,
     REQUEST_ID,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
   --  SERVICE_LINE_ID,
     ID ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_SOURCE_CODE,
     ORIG_SYSTEM_REFERENCE1
  FROM oks_pm_activities
  WHERE cle_id =p_old_cle_id;

RETURN l_return_status;

EXCEPTION
WHEN others THEN
OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
return x_return_status;

END CREATE_OKS_PM_ACTIVITIES;

-- This function is to insert values into oks_pm_stream_levels
FUNCTION CREATE_OKS_PM_STREAM_LEVELS(p_new_cle_id NUMBER,
                                     p_old_cle_id NUMBER) return VARCHAR2 IS

l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

 INSERT INTO oks_pm_stream_levels
   ( ID,
     CLE_ID,
     DNZ_CHR_ID,
     ACTIVITY_LINE_ID,
     SEQUENCE_NUMBER,
     NUMBER_OF_OCCURENCES,
     START_DATE,
     END_DATE,
     FREQUENCY,
     FREQUENCY_UOM,
     OFFSET_DURATION,
     OFFSET_UOM,
     AUTOSCHEDULE_YN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     OBJECT_VERSION_NUMBER,
     SECURITY_GROUP_ID,
     REQUEST_ID,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
  -- TOLERANCE_BEFORE,
  -- TOLERANCE_AFTER,
  -- SERVICE_LINE_ID,
     ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_SOURCE_CODE,
     ORIG_SYSTEM_REFERENCE1 )
  SELECT
     okc_p_util.raw_to_number(sys_guid()),
     p_new_cle_id CLE_ID,
     DNZ_CHR_ID,
     DECODE(ACTIVITY_LINE_ID,NULL,NULL,(SELECT id  from oks_pm_activities where ORIG_SYSTEM_ID1 =ACTIVITY_LINE_ID and cle_id =p_new_cle_id)),
     SEQUENCE_NUMBER,
     NUMBER_OF_OCCURENCES,
     START_DATE,
     END_DATE,
     FREQUENCY,
     FREQUENCY_UOM,
     OFFSET_DURATION,
     OFFSET_UOM,
     AUTOSCHEDULE_YN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     OBJECT_VERSION_NUMBER,
     SECURITY_GROUP_ID,
     REQUEST_ID,
     FND_GLOBAL.USER_ID CREATED_BY,
     SYSDATE CREATION_DATE,
     FND_GLOBAL.USER_ID LAST_UPDATED_BY,
     SYSDATE LAST_UPDATE_DATE,
     FND_GLOBAL.LOGIN_ID LAST_UPDATE_LOGIN,
  -- TOLERANCE_BEFORE,
  -- TOLERANCE_AFTER,
  --  SERVICE_LINE_ID,
     ID ORIG_SYSTEM_ID1,
     ORIG_SYSTEM_SOURCE_CODE,
     ORIG_SYSTEM_REFERENCE1
  FROM oks_pm_stream_levels
  WHERE cle_id=p_old_cle_id;
RETURN l_return_status;

EXCEPTION
WHEN others THEN
      OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
return x_return_status;

END CREATE_OKS_PM_STREAM_LEVELS;


BEGIN

   IF (G_DEBUG_ENABLED = 'Y') THEN
	okc_debug.Set_Indentation('Copy_PM_Template');
	okc_debug.log('Entered Copy_PM_Template', 3);
   END IF;
   l_return_status := CREATE_OKS_PM_ACTIVITIES(p_new_coverage_id,p_old_coverage_id);
   IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.log('After CREATE_OKS_PM_ACTIVITIES'||l_return_status, 3);
   END IF;
   IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
   THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
   l_return_status := CREATE_OKS_PM_STREAM_LEVELS(p_new_coverage_id,p_old_coverage_id);
   IF (G_DEBUG_ENABLED = 'Y') THEN
       okc_debug.log('After CREATE_OKS_PM_STREAM_LEVELS'||l_return_status, 3);
   END IF;

   IF l_return_status <> OKC_API.G_RET_STS_SUCCESS
   THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

x_return_status := l_return_status;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := l_return_status ;
  WHEN others THEN
         OKC_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Copy_PM_Template;



END OKS_PM_PROGRAMS_PVT;

/
