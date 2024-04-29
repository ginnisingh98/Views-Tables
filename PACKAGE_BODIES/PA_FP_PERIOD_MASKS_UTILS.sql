--------------------------------------------------------
--  DDL for Package Body PA_FP_PERIOD_MASKS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_PERIOD_MASKS_UTILS" as
/* $Header: PAFPPMUB.pls 120.0 2005/06/03 13:47:08 appldev noship $ */
/*********************************************************************
Important : The appropriate procedures that make a call to the below
procedures must make a call to FND_MSG_PUB.initialize.
**********************************************************************/
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE NAME_VALIDATION
    (p_name                           IN     pa_period_masks_tl.name%TYPE,
     p_period_mask_id                 IN     pa_period_masks_b.period_mask_id%TYPE,
     p_init_msg_flag                  IN     VARCHAR2,
     x_return_status                  OUT    NOCOPY VARCHAR2,
     x_msg_count                      OUT    NOCOPY NUMBER,
     x_msg_data	                      OUT    NOCOPY VARCHAR2) IS
l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_PERIOD_MASKS_UTILS.NAME_VALIDATION';
l_exists          VARCHAR2(1);
l_msg_count       NUMBER;
l_msg_index_out   NUMBER;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_name_exists     boolean:=false;
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
    	pa_debug.set_curr_function( p_function   => 'NAME_VALIDATION',
                                    p_debug_mode => p_pa_debug_mode );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_init_msg_flag = 'Y' THEN
        FND_MSG_PUB.Initialize;
    END IF;

    x_msg_count := 0;
    BEGIN
      SELECT   'Y'
      INTO     l_exists
      FROM     pa_period_masks_tl
      WHERE    UPPER(name) = UPPER(p_name)
      AND      p_period_mask_id <> period_mask_id
      AND      ROWNUM < 2;
      --DBMS_OUTPUT.PUT_LINE(p_name || ' Already Exists');
      --Duplicate Name should not be entered
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_ALL_UNIQUE_NAME_EXISTS');
      l_name_exists:=TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      --DBMS_OUTPUT.PUT_LINE(p_name || ' not duplicated');
      NULL;
    END;
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        ELSE
             x_msg_count := l_msg_count;
        END IF;
    END IF;
    IF P_PA_DEBUG_MODE = 'Y' THEN
      	PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_PERIOD_MASKS_UTILS',
                               p_procedure_name   => 'name_validation');
      IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5);
       	  PA_DEBUG.RESET_CURR_FUNCTION;
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      -- DBMS_OUTPUT.PUT_LINE('ERROR MSG FROM WHEN OTHER EXCEPTION');
END NAME_VALIDATION;


PROCEDURE NOP_VALIDATION
    (p_num_of_periods                 IN     PA_NUM_1000_NUM,
     p_init_msg_flag                  IN     VARCHAR2,
     p_error_flag_tab                 IN OUT NOCOPY PA_VC_1000_150,
     x_return_status                  OUT    NOCOPY VARCHAR2,
     x_msg_count                      OUT    NOCOPY NUMBER,
     x_msg_data                       OUT    NOCOPY VARCHAR2) IS
l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_PERIOD_MASKS_UTILS.NOP_VALIDATION';
l_num_of_periods       PA_NUM_1000_NUM;
l_invalid_num_exists   BOOLEAN := FALSE;
l_msg_count            NUMBER;
l_msg_index_out        NUMBER;
l_data                 VARCHAR2(2000);
l_msg_data             VARCHAR2(2000);
l_err_msg_flag         VARCHAR2(1):='Y';
BEGIN
      IF P_PA_DEBUG_MODE = 'Y' THEN
    	  pa_debug.set_curr_function( p_function   => 'NOP_VALIDATION',
                                      p_debug_mode => p_pa_debug_mode );
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF p_init_msg_flag = 'Y' THEN
      FND_MSG_PUB.Initialize;
      END IF;
      x_msg_count := 0;
     /* SELECT              num_of_periods
      BULK COLLECT INTO   l_num_of_periods
      FROM                pa_fp_period_mask_tmp; */
      if p_num_of_periods.count = 0 then
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                              p_msg_name            => 'PA_FP_NO_PM_DTLS');
         IF P_PA_DEBUG_MODE = 'Y' THEN
       	     PA_DEBUG.RESET_CURR_FUNCTION;
         END IF;
         RETURN;
      end if;
      l_num_of_periods := p_num_of_periods;
      FOR j in l_num_of_periods.FIRST..l_num_of_periods.LAST LOOP
        --Setting default value before starting each iteration
        IF (l_num_of_periods(j) < 0) OR  (l_num_of_periods(j) > 1000) OR
       ((l_num_of_periods(j) > 0) and (l_num_of_periods(j)<> ROUND(l_num_of_periods(j),0)))  THEN
              p_error_flag_tab(j) := 'Y';
	      IF l_err_msg_flag = 'Y' THEN
		     PA_UTILS.ADD_MESSAGE(
                               p_app_short_name      => 'PA',
                               p_msg_name            => 'PA_FP_INVALID_NUM_HDR');
							   l_err_msg_flag := 'N';

		  END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                               p_msg_name            => 'PA_FP_INVALID_NUM',
							   p_token1              => 'INVNUM',
                               p_value1              =>  l_num_of_periods(j));
        END IF;
          --Invalid Numbers should not be entered
     END LOOP;
/*  l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > 0) THEN
        IF (l_msg_count = 1) THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        ELSE
             x_msg_count := l_msg_count;
        END IF;
    END IF;    */
    IF P_PA_DEBUG_MODE = 'Y' THEN
      	PA_DEBUG.RESET_CURR_FUNCTION;
    END IF;
   RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_PERIOD_MASKS_UTILS',
                               p_procedure_name   => 'nop_validation');
      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5);
       	  PA_DEBUG.RESET_CURR_FUNCTION;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      -- DBMS_OUTPUT.PUT_LINE('ERROR MSG FROM WHEN OTHER EXCEPTION');
END NOP_VALIDATION;



/* PROCEDURE MAINTAIN_PERIOD_MASK_DTLS
    (p_period_mask_id                IN     PA_PERIOD_MASKS_B.PERIOD_MASK_ID%TYPE,
     p_num_of_periods                IN     PA_NUM_1000_NUM,
     p_anchor_period_flag            IN     PA_VC_1000_150,
     p_from_anchor_position          IN     PA_NUM_1000_NUM,
     p_init_msg_flag                 IN     VARCHAR2,
     p_commit_flag                   IN     VARCHAR2,
     x_return_status                 OUT    NOCOPY VARCHAR2,
     x_msg_count                     OUT    NOCOPY NUMBER,
     x_msg_data                      OUT    NOCOPY VARCHAR2) IS

   l_module_name VARCHAR2(100) := 'pa.plsql.PA_FP_PERIOD_MASKS_UTILS.MAINTAIN_PERIOD_MASK_DTLS';
   CURSOR succ_pd IS
   SELECT from_anchor_position,num_of_periods FROM
   pa_fp_period_mask_tmp WHERE from_anchor_position > 0 ORDER BY from_anchor_position;
   CURSOR prec_pd IS
   SELECT from_anchor_position,num_of_periods FROM
   pa_fp_period_mask_tmp WHERE from_anchor_position < 0 ORDER BY from_anchor_position;
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
             PA_DEBUG.g_err_stage := 'Before inserting into temporary table';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
    FORALL i in p_num_of_periods.FIRST..p_num_of_periods.LAST
        INSERT INTO pa_fp_period_mask_tmp(NUM_OF_PERIODS,ANCHOR_PERIOD_FLAG,FROM_ANCHOR_POSITION)
                    VALUES ( p_num_of_periods(i),p_anchor_period_flag(i),p_from_anchor_position(i));
    IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'After inserting into temporary table';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
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
             PA_DEBUG.g_err_stage := 'Before succeeding period';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;
     FOR succ_pd_rec IN succ_pd LOOP
         l_tmp_end := l_tmp_end + succ_pd_rec.num_of_periods;
         UPDATE pa_fp_period_mask_tmp
         SET from_anchor_start  = l_tmp, from_anchor_end  = l_tmp_end
         WHERE from_anchor_position = succ_pd_rec.from_anchor_position;

         l_tmp := l_tmp + succ_pd_rec.num_of_periods;
      END LOOP;
      IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'After succeeding period';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
      l_tmp := 0;
      l_tmp_end := -1;
      IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'Before preceeding period';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
      FOR prec_pd_rec IN prec_pd LOOP
         l_tmp := l_tmp - prec_pd_rec.num_of_periods;
         UPDATE pa_fp_period_mask_tmp
         SET from_anchor_start = l_tmp, from_anchor_end = l_tmp_end
         WHERE from_anchor_position = prec_pd_rec.from_anchor_position;

         l_tmp_end := l_tmp_end -  prec_pd_rec.num_of_periods;
      END LOOP;

      IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'After preceeding period';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
      END IF;
     BEGIN
	IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'Before inserting additional records in the temporary table';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
	INSERT INTO pa_fp_period_mask_tmp(num_of_periods,
         anchor_period_flag,
         from_anchor_start,from_anchor_end,from_anchor_position)
	VALUES (0,'N',-99999,-99999,-99999);
	INSERT INTO pa_fp_period_mask_tmp(num_of_periods,
         anchor_period_flag,from_anchor_start,from_anchor_end,from_anchor_position)
	VALUES (0,'N',99999,99999,99999);
	IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'After inserting additional records in the temporary table';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        INSERT INTO pa_period_mask_details(PERIOD_MASK_ID,
                                 num_of_periods,
                                    anchor_period_flag,
                                          from_anchor_start,
                             from_anchor_end,
         from_anchor_position)
      (SELECT p_period_mask_id,
                        trunc(num_of_periods),
                     anchor_period_flag,
                                    from_anchor_start,
                            from_anchor_end,
                     from_anchor_position FROM pa_fp_period_mask_tmp);
      IF (SQL%NOTFOUND) THEN
          RAISE no_data_found;
      END IF;
      END;
      IF p_commit_flag = 'Y' THEN
          COMMIT;
      END IF;
      IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.RESET_CURR_FUNCTION;
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
 	    pa_debug.write_log(
		  x_module    => l_module_name,
		  x_msg	      => 'Unexpected Error'||substr(sqlerrm, 1, 240),
		  x_log_level => 5);
            PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END MAINTAIN_PERIOD_MASK_DTLS;

*/

FUNCTION IS_DELETE_ALLOWED
   (p_period_mask_id  IN pa_period_masks_b.period_mask_id%TYPE)
   RETURN VARCHAR2 is
  l_count NUMBER := 0;
BEGIN

  begin
      select 1
      into l_count
      from dual
      where exists(
      SELECT 1
      FROM  pa_proj_fp_options
      WHERE  cost_period_mask_id = p_period_mask_id);
      IF l_count > 0 THEN
         RETURN 'N';
      END IF;
  exception
  when no_data_found then
       l_count := 0;
  end;

  l_count := 0;

  begin
      select 1
      into l_count
      from dual
      where exists(
      SELECT 1
      FROM  pa_proj_fp_options
      WHERE  rev_period_mask_id = p_period_mask_id);
      IF l_count > 0 THEN
         RETURN 'N';
      END IF;
  exception
  when no_data_found then
       l_count := 0;
  end;

  l_count := 0;

  begin
      select 1
      into l_count
      from dual
      where exists(
      SELECT 1
      FROM  pa_proj_fp_options
      WHERE  all_period_mask_id = p_period_mask_id);
      IF l_count > 0 THEN
         RETURN 'N';
      END IF;
  exception
  when no_data_found then
       l_count := 0;
  end;

  RETURN 'Y';

EXCEPTION
WHEN OTHERS THEN
     RETURN 'N';
END IS_DELETE_ALLOWED;

END PA_FP_PERIOD_MASKS_UTILS;

/
