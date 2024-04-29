--------------------------------------------------------
--  DDL for Package Body PA_PERIOD_MASKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERIOD_MASKS_PUB" as
/* $Header: PAFPPMMB.pls 120.0.12000000.2 2007/09/10 12:12:56 admarath ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE maintain_period_masks(
                    	p_period_mask_id	    IN NUMBER,
                    	p_name			    IN VARCHAR2,
                        p_description		    IN VARCHAR2,
                        p_time_phase_code	    IN VARCHAR2,
                        p_effective_start_date	    IN pa_period_masks_b.effective_start_date%type,
                        p_effective_end_date	    IN pa_period_masks_b.effective_end_date%type,
			p_record_version_number	    IN NUMBER,
			p_num_of_periods	    IN PA_NUM_1000_NUM,
			p_anchor_period_flag 	    IN PA_VC_1000_150,
		        p_from_anchor_position	    IN PA_NUM_1000_NUM,
			p_error_flag_tab            IN OUT NOCOPY PA_VC_1000_150,
			p_init_msg_flag             IN VARCHAR2,
     			p_commit_flag               IN VARCHAR2,
                        x_return_status       	    OUT NOCOPY VARCHAR2,
                        x_msg_count           	    OUT NOCOPY NUMBER,
                        x_msg_data            	    OUT NOCOPY VARCHAR2 )

IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_PERIOD_MASKS_PUB.maintain_period_masks';
    l_project_id_tab  	           SYSTEM.pa_num_tbl_type:=SYSTEM.pa_num_tbl_type();
    l_period_masks_s 		number := 0;

    l_language 			varchar2(100) := null;

    l_rec_count        		number := 0;
    --Initialize plsql tables
    --l_num_of_periods.delete;
    --l_anchor_period_flag.delete;
    --l_from_anchor_position.delete;
    l_return_status varchar2(30);
BEGIN
   IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
      PA_DEBUG.init_err_stack('PAFPPMMB.PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK');
   ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            pa_debug.set_curr_function( p_function     => 'maintain_period_masks'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
   END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.Initialize;
    END IF;

    /*********Name Validation***********/
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling  pa_fp_period_masks_utils.name_validation',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    pa_fp_period_masks_utils.name_validation(
                        p_name => p_name,
			p_period_mask_id => p_period_mask_id,
			p_init_msg_flag => 'N',
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data );
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_period_masks_utils.name_validation: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;
    l_return_status := x_return_status;

    /*********Effective Date Validation***********/
    /**Doosan changes. Moved this api from pa_fin_plan_type_utils
      *to pa_fin_plan_utils
      *pa_fin_plan_types_utils.end_date_active_val(*/
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_period_masks_utils.end_date_active_val',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    pa_fin_plan_utils.end_date_active_val(
                    p_start_date_active => p_effective_start_date,
	            p_end_date_active => p_effective_end_date,
		    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
		    x_msg_data => x_msg_data);

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_period_masks_utils.end_date_active_val: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);

    END IF;
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        l_return_status := x_return_status;
    END IF;

    /*********Number of Period Validation***********/
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               pa_fp_period_masks_utils.nop_validation',
              p_module_name => l_module_name,
              p_log_level   => 5);
   END IF;
    pa_fp_period_masks_utils.nop_validation(
                p_num_of_periods => p_num_of_periods,
		p_init_msg_flag => 'N',
		p_error_flag_tab => p_error_flag_tab,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);
    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              pa_fp_period_masks_utils.nop_validation: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        l_return_status := x_return_status;
    END IF;
    x_return_status := l_return_status;

    IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        return;
    END IF;

    /**if period_mask_id is null, then we need to INSERT
      *Populate both the master record in pa_period_masks_s + pa_period_masks_tl
      *and detail record in pa_period_mask_details*/
    IF p_period_mask_id = 0  THEN
        SELECT pa_period_masks_s.nextval INTO l_period_masks_s FROM DUAL;
	SELECT userenv('LANG') INTO l_language FROM dual;
	/*populating table pa_period_masks_b*/
        INSERT INTO pa_period_masks_b (
     			PERIOD_MASK_ID,
			EFFECTIVE_START_DATE,
			EFFECTIVE_END_DATE,
		        TIME_PHASE_CODE,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			LAST_UPDATED_BY,
		        LAST_UPDATE_DATE,
			RECORD_VERSION_NUMBER,
			PRE_DEFINED_FLAG)
		VALUES(
			l_period_masks_s,
			p_effective_start_date,
			p_effective_end_date,
                        p_time_phase_code,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID,
                        FND_GLOBAL.LOGIN_ID,
                        sysdate,
			1,
			'N');
        /*populating table pa_period_masks_tl*/
	INSERT INTO pa_period_masks_tl (
			PERIOD_MASK_ID,
			NAME,
			DESCRIPTION,
			LANGUAGE,
			SOURCE_LANG,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN )
		select  l_period_masks_s,
			p_name,
			p_description,
			L.LANGUAGE_CODE, /* Bug 6275098*/
			l_language,
                        sysdate,
                        FND_GLOBAL.LOGIN_ID,
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.LOGIN_ID /*Changes for Bug 6275098 */
			from FND_LANGUAGES L where L.INSTALLED_FLAG in ('I', 'B')
			and not exists
			(select null from PA_PERIOD_MASKS_TL T
			where T.PERIOD_MASK_ID = l_period_masks_s
			and T.LANGUAGE = L.LANGUAGE_CODE);

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5);
        END IF;
        /*populating table pa_period_mask_details*/
	PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK_DTLS(
		        p_period_mask_id => l_period_masks_s,
		        p_num_of_periods => p_num_of_periods,
			p_anchor_period_flag => p_anchor_period_flag,
			p_from_anchor_position => p_from_anchor_position,
			p_init_msg_flag => 'N',
			p_commit_flag => 'N',
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);
        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK_DTL: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
        END IF;

	IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
                PA_DEBUG.reset_err_stack;
            ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
	    RETURN;
	END IF;

    /**if period_mask_id is not null, then we need to UPDATE
      *Update both the master record in pa_period_masks_s + pa_period_masks_tl
      *and detail record in pa_period_mask_details*/
    ELSE
        UPDATE pa_period_masks_b
        SET effective_start_date = p_effective_start_date,
       	    effective_end_date = p_effective_end_date,
 	    time_phase_code = p_time_phase_code,
	    last_update_login = FND_GLOBAL.LOGIN_ID,
	    last_updated_by = FND_GLOBAL.LOGIN_ID,
	    last_update_date = sysdate,
            record_version_number = record_version_number + 1
        WHERE period_mask_id = p_period_mask_id
              and record_version_number = p_record_version_number;
        IF (sql%notfound) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_PM_INVALID');
            IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
                PA_DEBUG.reset_err_stack;
            ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
            RETURN;
        END IF;

        UPDATE pa_period_masks_tl
        SET name = p_name,
   	    description = p_description,
	    last_update_login = FND_GLOBAL.LOGIN_ID,
	    last_updated_by = FND_GLOBAL.LOGIN_ID,
	    last_update_date = sysdate
        WHERE period_mask_id = p_period_mask_id;


        DELETE FROM pa_period_mask_details
        WHERE period_mask_id = p_period_mask_id;
	      l_rec_count := p_num_of_periods.count();

        IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK_DTLS',
              p_module_name => l_module_name,
              p_log_level   => 5);
        END IF;
        PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK_DTLS(
                p_period_mask_id => p_period_mask_id,
	        p_num_of_periods => p_num_of_periods,
		p_anchor_period_flag => p_anchor_period_flag,
		p_from_anchor_position => p_from_anchor_position,
		p_init_msg_flag => 'N',
		p_commit_flag => 'N',
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);
	IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
                              PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK_DTL: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
                PA_DEBUG.reset_err_stack;
            ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
                PA_DEBUG.Reset_Curr_Function;
            END IF;
            RETURN;
        END IF;

    END IF;

    IF (p_commit_flag = 'Y') THEN
        COMMIT;
    END IF;
    IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
        PA_DEBUG.reset_err_stack;
    ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
        PA_DEBUG.Reset_Curr_Function;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := substr(SQLERRM,1,240);

        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PERIOD_MASKS_PUB',
                                 p_procedure_name   => 'maintain_period_masks');

        IF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'Y' THEN
            PA_DEBUG.reset_err_stack;
        ELSIF p_pa_debug_mode = 'Y' AND p_init_msg_flag = 'N' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END maintain_period_masks;


--*********************
PROCEDURE MAINTAIN_PERIOD_MASK_DTLS
    (p_period_mask_id                IN     PA_PERIOD_MASKS_B.PERIOD_MASK_ID%TYPE,
     p_num_of_periods                IN     PA_NUM_1000_NUM,
     p_anchor_period_flag            IN     PA_VC_1000_150,
     p_from_anchor_position          IN     PA_NUM_1000_NUM,
     p_init_msg_flag                 IN     VARCHAR2,
     p_commit_flag                   IN     VARCHAR2,
     x_return_status                 OUT    NOCOPY VARCHAR2,
     x_msg_count                     OUT    NOCOPY NUMBER,
     x_msg_data                      OUT    NOCOPY VARCHAR2)
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_PERIOD_MASKS_PUB.MAINTAIN_PERIOD_MASK_DTLS';

    CURSOR succ_pd IS
    SELECT from_anchor_position,num_of_periods FROM
    pa_fp_period_mask_tmp WHERE from_anchor_position > 0 ORDER BY from_anchor_position;

    CURSOR prec_pd IS
    SELECT from_anchor_position,num_of_periods FROM
    pa_fp_period_mask_tmp WHERE from_anchor_position < 0 ORDER BY from_anchor_position desc;


    l_from_anchor_position           NUMBER;
    l_first_no_of_pds                NUMBER;
    l_start_temp                     NUMBER;
    l_tmp                            NUMBER;
    l_tmp_end                        NUMBER;
    l_initial_flag                   VARCHAR2(1);
    l_anchor_period_flag             PA_VC_1000_150;
    l_flag_exists                    BOOLEAN := FALSE;

    l_count number;
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
  	pa_debug.set_curr_function( p_function   => 'MAINTAIN_PERIOD_MASK_DTLS',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.Initialize;
    END IF;

    x_msg_count := 0;


    DELETE FROM pa_fp_period_mask_tmp;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before inserting into temporary table',
              p_module_name => l_module_name,
              p_log_level   => 5);
    END IF;

    FORALL i in p_num_of_periods.FIRST..p_num_of_periods.LAST
        INSERT INTO pa_fp_period_mask_tmp(NUM_OF_PERIODS,ANCHOR_PERIOD_FLAG,FROM_ANCHOR_POSITION)
        VALUES ( p_num_of_periods(i),p_anchor_period_flag(i),p_from_anchor_position(i));

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
         (p_msg         => 'After inserting into temporary table',
          p_module_name => l_module_name,
          p_log_level   => 5);
    END IF;
    select count(*) into l_count
    from pa_fp_period_mask_tmp
    where  anchor_period_flag = 'Y';

    if l_count = 0 then
        update pa_fp_period_mask_tmp set
        anchor_period_flag = 'Y' where
        from_anchor_position = 1;
    end if;
    SELECT    from_anchor_position,num_of_periods
    INTO      l_from_anchor_position,l_first_no_of_pds
    FROM      pa_fp_period_mask_tmp
    WHERE     anchor_period_flag = 'Y';

    UPDATE  pa_fp_period_mask_tmp
    SET from_anchor_position = from_anchor_position - l_from_anchor_position;

    UPDATE   pa_fp_period_mask_tmp
    SET      from_anchor_start  = 0, from_anchor_end  = num_of_periods  - 1
    WHERE    anchor_period_flag = 'Y';

    l_initial_flag := 'Y';
    l_tmp := l_first_no_of_pds;
    l_tmp_end := l_first_no_of_pds - 1;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
         (p_msg         => 'Before succeeding period',
          p_module_name => l_module_name,
          p_log_level   => 5);
    END IF;

    FOR succ_pd_rec IN succ_pd LOOP
        l_tmp_end := l_tmp_end + succ_pd_rec.num_of_periods;

        UPDATE pa_fp_period_mask_tmp
        SET from_anchor_start  = l_tmp, from_anchor_end  = l_tmp_end
        WHERE from_anchor_position = succ_pd_rec.from_anchor_position;

        l_tmp := l_tmp + succ_pd_rec.num_of_periods;
    END LOOP;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
         (p_msg         => 'After succeeding period',
          p_module_name => l_module_name,
          p_log_level   => 5);
    END IF;

    l_tmp := 0;
    l_tmp_end := -1;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
         (p_msg         => 'Before preceeding period',
          p_module_name => l_module_name,
          p_log_level   => 5);
    END IF;

    FOR prec_pd_rec IN prec_pd LOOP
        l_tmp := l_tmp - prec_pd_rec.num_of_periods;

        UPDATE pa_fp_period_mask_tmp
        SET from_anchor_start = l_tmp, from_anchor_end = l_tmp_end
        WHERE from_anchor_position = prec_pd_rec.from_anchor_position;

        l_tmp_end := l_tmp_end -  prec_pd_rec.num_of_periods;

    END LOOP;

    IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
         (p_msg         => 'After preceeding period',
          p_module_name => l_module_name,
          p_log_level   => 5);
    END IF;

    BEGIN

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_fp_gen_amount_utils.fp_debug
         (p_msg         => 'Before inserting additional records in the temporary table',
          p_module_name => l_module_name,
          p_log_level   => 5);
      END IF;

	 --Inserting additional records in the temp table to allow additional periods before/after the project periods

        INSERT INTO pa_fp_period_mask_tmp(num_of_periods, anchor_period_flag,
                    from_anchor_start,from_anchor_end,from_anchor_position
         )
	VALUES (0,'N',-99999,-99999,-99999);

	INSERT INTO pa_fp_period_mask_tmp(num_of_periods,
                    anchor_period_flag,from_anchor_start,from_anchor_end,from_anchor_position)
	VALUES (0,'N',99999,99999,99999 );


	IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'After inserting additional records in the temporary table',
                p_module_name => l_module_name,
                p_log_level   => 5);
        END IF;



        INSERT INTO pa_period_mask_details(PERIOD_MASK_ID,
                                           num_of_periods,
                                           anchor_period_flag,
                                           from_anchor_start,
                                           from_anchor_end,
                                           from_anchor_position,
                                           CREATION_DATE,
				           CREATED_BY,
	                                   LAST_UPDATE_LOGIN,
                                           LAST_UPDATED_BY,
                                           LAST_UPDATE_DATE )
       (SELECT p_period_mask_id,
               trunc(num_of_periods),
               anchor_period_flag,
               from_anchor_start,
               from_anchor_end,
               from_anchor_position,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID,
               FND_GLOBAL.LOGIN_ID,
               sysdate FROM pa_fp_period_mask_tmp );


        IF (SQL%NOTFOUND) THEN
            IF P_PA_DEBUG_MODE = 'Y' THEN
      		PA_DEBUG.RESET_CURR_FUNCTION;
    	    END IF;
            RAISE no_data_found;
        END IF;

    END;

    if p_commit_flag = 'Y' then
	COMMIT;
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
      	PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_PERIOD_MASKS_UTILS',
                                 p_procedure_name   => 'MAINTAIN_PERIOD_MASK_DTLS');
        IF P_PA_DEBUG_MODE = 'Y' THEN
      	    PA_DEBUG.RESET_CURR_FUNCTION;
    	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END MAINTAIN_PERIOD_MASK_DTLS;

--*************************

PROCEDURE delete_period_mask( 	p_period_mask_id 		IN NUMBER,
			        p_record_version_number		IN NUMBER,
				p_init_msg_flag                 IN VARCHAR2,
     				p_commit_flag                   IN VARCHAR2,
				x_return_status     		OUT NOCOPY VARCHAR2,
                       		x_msg_count    			OUT NOCOPY NUMBER,
                       		x_msg_data     			OUT NOCOPY VARCHAR2 )
IS
    l_module_name VARCHAR2(100) := 'pa.plsql.PA_PERIOD_MASKS_PUB.delete_period_mask';
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
   	pa_debug.set_curr_function( p_function   => 'delete_period_mask',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;

    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.Initialize;
    END IF;

    DELETE FROM pa_period_masks_b
    WHERE period_mask_id = p_period_mask_id
	  and record_version_number = p_record_version_number;
    IF (sql%notfound) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_PM_INVALID2');
    	IF P_PA_DEBUG_MODE = 'Y' THEN
      	    PA_DEBUG.RESET_CURR_FUNCTION;
    	END IF;
    	RETURN;
    END IF;

    DELETE FROM pa_period_masks_tl
    WHERE period_mask_id = p_period_mask_id;

    DELETE FROM pa_period_mask_details
    WHERE period_mask_id = p_period_mask_id;

    IF (p_commit_flag = 'Y') THEN
        COMMIT;
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
      	PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
       	x_return_status := FND_API.G_RET_STS_ERROR;
    	x_msg_count := 1;
    	x_msg_data := to_char(sqlcode);
        FND_MSG_PUB.add_exc_msg( p_pkg_name  => 'PA_FP_PERIOD_MASKS_PUB',
                                 p_procedure_name   => 'delete_period_mask');
        IF P_PA_DEBUG_MODE = 'Y' THEN
      	    PA_DEBUG.RESET_CURR_FUNCTION;
    	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END delete_period_mask;


END PA_PERIOD_MASKS_PUB;

/
