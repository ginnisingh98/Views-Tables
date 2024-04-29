--------------------------------------------------------
--  DDL for Package Body FEM_DIS_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIS_UTL_PKG" AS
/* $Header: fem_dis_utl.plb 120.1 2005/10/27 05:30:28 appldev noship $ */

c_conversion_type       CONSTANT VARCHAR2(20) := 'Spot';
e_no_end_date_def_err    EXCEPTION;

  FUNCTION Visual_Trace_URL(
    p_function_name IN VARCHAR2,
    p_other_params  IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS

    v_func_id NUMBER;
    v_session_id NUMBER;
    v_url VARCHAR2(256);

  BEGIN

    SELECT FUNCTION_ID
    INTO v_func_id
    FROM FND_FORM_FUNCTIONS
    WHERE FUNCTION_NAME = Visual_Trace_URL.p_function_name;


    IF FND_LOG.Level_Procedure >= FND_LOG.G_Current_Runtime_Level THEN
      FND_LOG.String(FND_LOG.Level_Procedure,
                     'fem.plsql.fem_dis_utl_pkg.visual_trace_url.start',
                     'Executing function: '|| p_function_name ||
                     ', other_params: ' || p_other_params);
    END IF;

    v_session_id := FND_PROFILE.Value('ICX_SESSION_ID');

    IF v_session_id IS NOT NULL THEN

       FND_SESSION_MANAGEMENT.InitializeSSWAGlobals(
         p_session_id => v_session_id,
         p_resp_appl_id => fnd_global.resp_appl_id,
         p_responsibility_id => fnd_global.resp_id,
         p_security_group_id => fnd_global.security_group_id,
         p_function_id => v_func_id
       );

    END IF;

    v_url := FND_RUN_FUNCTION.Get_Run_Function_URL(
      P_FUNCTION_ID => v_func_id,
      P_RESP_APPL_ID => fnd_global.resp_appl_id,
      P_RESP_ID => fnd_global.resp_id,
      P_SECURITY_GROUP_ID => fnd_global.security_group_id,
      P_PARAMETERS => p_other_params
    );

    RETURN(v_url);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(NULL);
  END;

PROCEDURE get_exchange_rate(
        p_from_cur IN VARCHAR2,
        p_to_cur IN VARCHAR2,
        p_cal_period IN NUMBER,
        p_from_val IN NUMBER,
        x_to_val OUT NOCOPY NUMBER,
        x_dtor OUT NOCOPY NUMBER,
        x_ntor OUT NOCOPY NUMBER
        )
IS
        l_end_date DATE := NULL;
        l_start_date DATE := NULL;
        l_conv_rate NUMBER := NULL;

BEGIN

        BEGIN
        --get the end date from cal period id
            SELECT A.date_assign_value
        INTO   l_end_date
            FROM   fem_cal_periods_attr A,
                   fem_dim_attributes_b B,
               fem_dim_attr_versions_b C
        WHERE  A.cal_period_id = p_cal_period
        AND    A.attribute_id = B.attribute_id
        AND    B.attribute_varchar_label = 'CAL_PERIOD_END_DATE'
        AND    C.attribute_id = A.attribute_id
            AND    C.version_id = A.version_id
        AND    C.default_version_flag = 'Y';

        --get the start date from cal period id
        SELECT A.date_assign_value
        INTO   l_start_date
            FROM   fem_cal_periods_attr A,
                   fem_dim_attributes_b B,
               fem_dim_attr_versions_b C
        WHERE  A.cal_period_id = p_cal_period
        AND    A.attribute_id = B.attribute_id
        AND    B.attribute_varchar_label = 'CAL_PERIOD_START_DATE'
        AND    C.attribute_id = A.attribute_id
            AND    C.version_id = A.version_id
        AND    C.default_version_flag = 'Y';

        EXCEPTION
            WHEN OTHERS THEN
                RAISE e_no_end_date_def_err;
    END;
        -- This api rounds the TO value to precision and minimum accountable unit of
        -- the TO currency
        IF(l_end_date IS NOT NULL) THEN

                GL_CURRENCY_API.convert_closest_amount(
                        x_from_currency => p_from_cur,
                        x_to_currency => p_to_cur,
                        x_conversion_date => l_end_date,
                        x_conversion_type => c_conversion_type,
                        x_user_rate => NULL,
                        x_amount => p_from_val,
                        x_max_roll_days => (l_end_date - l_start_date),
                        x_converted_amount => x_to_val,
                        x_denominator => x_dtor,
                        x_numerator => x_ntor,
                        x_rate => l_conv_rate
                );
    ELSE
        RAISE e_no_end_date_def_err;
        END IF;

END get_exchange_rate;

FUNCTION get_converted_amount(
   p_from_currency IN VARCHAR2,
   p_to_currency   IN VARCHAR2,
   p_cal_period_id IN NUMBER,
   p_from_value    IN NUMBER
)
RETURN NUMBER
IS
l_denominator   NUMBER;
l_numerator             NUMBER;
x_to_value      NUMBER;
BEGIN

-- Check if both currencies are identical
IF ( p_from_currency = p_to_currency ) THEN
        RETURN p_from_value;
ELSIF( p_from_currency IS NULL OR p_to_currency IS NULL ) THEN
    RAISE gl_currency_api.INVALID_CURRENCY;
END IF;

--Get the converted amount
get_exchange_rate(
        p_from_cur => p_from_currency,
    p_to_cur => p_to_currency,
    p_cal_period => p_cal_period_id,
    p_from_val => p_from_value,
    x_to_val => x_to_value,
    x_ntor => l_numerator,
    x_dtor => l_denominator
  );

RETURN x_to_value;

EXCEPTION
    WHEN VALUE_ERROR THEN
        --x_ret_code := FND_API.G_FALSE;
        x_to_value := NULL;
        RETURN x_to_value;

    WHEN gl_currency_api.INVALID_CURRENCY THEN
        --x_ret_code := FND_API.G_FALSE;
        x_to_value := NULL;
        RETURN x_to_value;

    WHEN gl_currency_api.NO_RATE THEN
           --x_ret_code := FND_API.G_FALSE;
           x_to_value := NULL;
           RETURN x_to_value;

    WHEN e_no_end_date_def_err THEN
       --x_ret_code := -1;
           x_to_value := NULL;
           RETURN x_to_value;

        WHEN OTHERS THEN
           --x_ret_code := FND_API.G_FALSE;
       x_to_value := NULL;
       RETURN x_to_value;

END get_converted_amount;

/****************************************************************************

                      Get Dim Attribute Value

This API is a wrapper over the FEM_DIM_ATTRIBUTES_UTIL_PKG and returns the
member value of an attribute assignment of either a dimension member or a
dimension member/value set combination. If an attribute version is not
specified, the default is used.

******************************************************************************/


FUNCTION Get_Dim_Attribute_Value(
   p_dimension_varchar_label     IN VARCHAR2,
   p_attribute_varchar_label     IN VARCHAR2,
   p_member_id                   IN NUMBER,
   p_value_set_id                IN NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_mbr_id   IN VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2
IS

x_return_status   VARCHAR2(100);
x_msg_count       NUMBER;
x_msg_data        VARCHAR2(1000);
l_attribute_value VARCHAR2(150);

BEGIN

l_attribute_value:=FEM_DIM_ATTRIBUTES_UTIL_PKG.Get_Dim_Attribute_Value (
   x_return_status                  => x_return_status,
   x_msg_count                      => x_msg_count,
   x_msg_data                       => x_msg_data,
   p_dimension_varchar_label        => p_dimension_varchar_label,
   p_attribute_varchar_label        => p_attribute_varchar_label,
   p_member_id                      => p_member_id,
   p_value_set_id                   => p_value_set_id,
   p_attr_version_display_code      => p_attr_version_display_code,
   p_return_attr_assign_mbr_id      => p_return_attr_assign_mbr_id
 );

RETURN l_attribute_value;

END Get_Dim_Attribute_Value;

/*******************************************************************************

                         Get_Relative_cal_period_name

Given a base calendar period ID and an offset count this API returns the period
name for the offset period. The API retrieves the Relative Cal Period ID info
 from the FEM_DIMENSION_UTIL_PKG.

*******************************************************************************/

FUNCTION Get_Relative_cal_period_name(p_base_cal_period_id NUMBER,
                                      p_offset NUMBER)
RETURN VARCHAR2 IS
   x_return_status        VARCHAR2(100);
   x_msg_count            NUMBER;
   x_msg_data             VARCHAR2(1000);
   l_prev_cal_period_name VARCHAR2(1000);
   l_prev_cal_period_id   NUMBER;

   CURSOR c_cal_period_name(p_period_id NUMBER ) IS
   SELECT cal_period_name INTO l_prev_cal_period_name
   FROM   fem_cal_periods_vl
   WHERE  cal_period_id =p_period_id;

BEGIN
l_prev_cal_period_id:= FEM_DIMENSION_UTIL_PKG.Relative_Cal_Period_ID (
   x_return_status      => x_return_status      ,
   x_msg_count          =>x_msg_count          ,
   x_msg_data           =>x_msg_data           ,
   p_per_num_offset     => p_offset,
   p_base_cal_period_id => p_base_cal_period_id
);

OPEN c_cal_period_name (l_prev_cal_period_id);
FETCH c_cal_period_name INTO l_prev_cal_period_name;
CLOSE c_cal_period_name;

RETURN l_prev_cal_period_name;

EXCEPTION when others THEN
   IF c_cal_period_name%isopen THEN
       CLOSE  c_cal_period_name;
   END IF;
   RETURN null;
END Get_Relative_cal_period_name;

END FEM_DIS_UTL_PKG;

/
