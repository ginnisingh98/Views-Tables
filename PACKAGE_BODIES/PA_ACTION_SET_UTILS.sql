--------------------------------------------------------
--  DDL for Package Body PA_ACTION_SET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTION_SET_UTILS" AS
/*$Header: PARASUTB.pls 120.1 2005/08/19 16:48:31 mwasowic noship $*/
--

FUNCTION get_action_set_id(p_action_set_type_code IN VARCHAR2,
                           p_object_type          IN VARCHAR2,
                           p_object_id            IN NUMBER) RETURN NUMBER
IS

l_action_set_id  NUMBER;

BEGIN

     SELECT action_set_id INTO l_action_set_id
       FROM pa_action_sets
      WHERE object_type = p_object_type
        AND object_id = p_object_id
        AND action_set_type_code = p_action_set_type_code
        AND status_code IN ('NOT_STARTED', 'STARTED', 'PAUSED', 'RESUMED', 'CLOSED');

      RETURN l_action_set_id;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RETURN NULL;

END;


FUNCTION get_action_set_lines(p_action_set_id     IN NUMBER)
   RETURN action_set_lines_tbl_type
IS

   l_action_set_lines_tbl   pa_action_set_utils.action_set_lines_tbl_type;

   TYPE number_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE varchar_tbl_type IS TABLE OF VARCHAR2(2000)
      INDEX BY BINARY_INTEGER;

   l_action_set_line_id_tbl        number_tbl_type;
   l_action_set_id_tbl             number_tbl_type;
   l_action_set_line_number_tbl    number_tbl_type;
   l_status_code_tbl               varchar_tbl_type;
   l_description_tbl               varchar_tbl_type;
   l_record_version_number_tbl     number_tbl_type;
   l_action_code_tbl               varchar_tbl_type;
   l_action_attribute1_tbl         varchar_tbl_type;
   l_action_attribute2_tbl         varchar_tbl_type;
   l_action_attribute3_tbl         varchar_tbl_type;
   l_action_attribute4_tbl         varchar_tbl_type;
   l_action_attribute5_tbl         varchar_tbl_type;
   l_action_attribute6_tbl         varchar_tbl_type;
   l_action_attribute7_tbl         varchar_tbl_type;
   l_action_attribute8_tbl         varchar_tbl_type;
   l_action_attribute9_tbl         varchar_tbl_type;
   l_action_attribute10_tbl        varchar_tbl_type;

   BEGIN

      SELECT action_set_line_id,
             action_set_id,
             action_set_line_number,
             status_code,
             description,
             record_version_number,
             action_code,
             action_attribute1,
             action_attribute2,
             action_attribute3,
             action_attribute4,
             action_attribute5,
             action_attribute6,
             action_attribute7,
             action_attribute8,
             action_attribute9,
             action_attribute10
   BULK COLLECT INTO
             l_action_set_line_id_tbl,
             l_action_set_id_tbl,
             l_action_set_line_number_tbl,
             l_status_code_tbl,
             l_description_tbl,
             l_record_version_number_tbl,
             l_action_code_tbl,
             l_action_attribute1_tbl,
             l_action_attribute2_tbl,
             l_action_attribute3_tbl,
             l_action_attribute4_tbl,
             l_action_attribute5_tbl,
             l_action_attribute6_tbl,
             l_action_attribute7_tbl,
             l_action_attribute8_tbl,
             l_action_attribute9_tbl,
             l_action_attribute10_tbl
        FROM pa_action_set_lines
       WHERE action_set_id = p_action_set_id;

   IF l_action_set_line_id_tbl.COUNT > 0 THEN

     FOR i IN l_action_set_line_id_tbl.FIRST .. l_action_set_line_id_tbl.LAST LOOP



        l_action_set_lines_tbl(i).action_set_line_id := l_action_set_line_id_tbl(i);
        l_action_set_lines_tbl(i).action_set_id := l_action_set_id_tbl(i);
        l_action_set_lines_tbl(i).action_set_line_number := l_action_set_line_number_tbl(i);
        l_action_set_lines_tbl(i).status_code := l_status_code_tbl(i);
        l_action_set_lines_tbl(i).description := l_description_tbl(i);
        l_action_set_lines_tbl(i).record_version_number := l_record_version_number_tbl(i);
        l_action_set_lines_tbl(i).action_code := l_action_code_tbl(i);
        l_action_set_lines_tbl(i).action_attribute1 := l_action_attribute1_tbl(i);
        l_action_set_lines_tbl(i).action_attribute2 := l_action_attribute2_tbl(i);
        l_action_set_lines_tbl(i).action_attribute3 := l_action_attribute3_tbl(i);
        l_action_set_lines_tbl(i).action_attribute4 := l_action_attribute4_tbl(i);
        l_action_set_lines_tbl(i).action_attribute5 := l_action_attribute5_tbl(i);
        l_action_set_lines_tbl(i).action_attribute6 := l_action_attribute6_tbl(i);
        l_action_set_lines_tbl(i).action_attribute7 := l_action_attribute7_tbl(i);
        l_action_set_lines_tbl(i).action_attribute8 := l_action_attribute8_tbl(i);
        l_action_set_lines_tbl(i).action_attribute9 := l_action_attribute9_tbl(i);
        l_action_set_lines_tbl(i).action_attribute10 := l_action_attribute10_tbl(i);

     END LOOP;

    END IF;

   RETURN l_action_set_lines_tbl;

END;


FUNCTION get_action_set_line (p_action_set_line_id     IN NUMBER)
   RETURN pa_action_set_lines%ROWTYPE
IS

   l_action_set_lines_rec   pa_action_set_lines%ROWTYPE;

   BEGIN

      SELECT action_set_line_id,
             action_set_id,
             action_set_line_number,
             status_code,
             description,
             record_version_number,
             action_code,
             action_attribute1,
             action_attribute2,
             action_attribute3,
             action_attribute4,
             action_attribute5,
             action_attribute6,
             action_attribute7,
             action_attribute8,
             action_attribute9,
             action_attribute10
   INTO
             l_action_set_lines_rec.action_set_line_id,
             l_action_set_lines_rec.action_set_id,
             l_action_set_lines_rec.action_set_line_number,
             l_action_set_lines_rec.status_code,
             l_action_set_lines_rec.description,
             l_action_set_lines_rec.record_version_number,
             l_action_set_lines_rec.action_code,
             l_action_set_lines_rec.action_attribute1,
             l_action_set_lines_rec.action_attribute2,
             l_action_set_lines_rec.action_attribute3,
             l_action_set_lines_rec.action_attribute4,
             l_action_set_lines_rec.action_attribute5,
             l_action_set_lines_rec.action_attribute6,
             l_action_set_lines_rec.action_attribute7,
             l_action_set_lines_rec.action_attribute8,
             l_action_set_lines_rec.action_attribute9,
             l_action_set_lines_rec.action_attribute10
        FROM pa_action_set_lines
       WHERE action_set_line_id = p_action_set_line_id;

     RETURN l_action_set_lines_rec;

END;

FUNCTION get_action_set_details (p_action_set_line_id     IN NUMBER)
   RETURN pa_action_sets%ROWTYPE
IS

   l_action_sets_rec   pa_action_sets%ROWTYPE;

   BEGIN

      SELECT sets.action_set_id,
             sets.action_set_name,
             sets.action_set_type_code,
             sets.object_type,
             sets.object_id,
             sets.start_date_active,
             sets.end_date_active,
             sets.description,
             sets.status_code,
             sets.actual_start_date,
             sets.action_set_template_flag,
             sets.source_action_set_id,
             sets.attribute_category,
             sets.attribute1,
             sets.attribute2,
             sets.attribute3,
             sets.attribute4,
             sets.attribute5,
             sets.attribute6,
             sets.attribute7,
             sets.attribute8,
             sets.attribute9,
             sets.attribute10,
             sets.attribute11,
             sets.attribute12,
             sets.attribute13,
             sets.attribute14,
             sets.attribute15
   INTO
             l_action_sets_rec.action_set_id,
             l_action_sets_rec.action_set_name,
             l_action_sets_rec.action_set_type_code,
             l_action_sets_rec.object_type,
             l_action_sets_rec.object_id,
             l_action_sets_rec.start_date_active,
             l_action_sets_rec.end_date_active,
             l_action_sets_rec.description,
             l_action_sets_rec.status_code,
             l_action_sets_rec.actual_start_date,
             l_action_sets_rec.action_set_template_flag,
             l_action_sets_rec.source_action_set_id,
             l_action_sets_rec.attribute_category,
             l_action_sets_rec.attribute1,
             l_action_sets_rec.attribute2,
             l_action_sets_rec.attribute3,
             l_action_sets_rec.attribute4,
             l_action_sets_rec.attribute5,
             l_action_sets_rec.attribute6,
             l_action_sets_rec.attribute7,
             l_action_sets_rec.attribute8,
             l_action_sets_rec.attribute9,
             l_action_sets_rec.attribute10,
             l_action_sets_rec.attribute11,
             l_action_sets_rec.attribute12,
             l_action_sets_rec.attribute13,
             l_action_sets_rec.attribute14,
             l_action_sets_rec.attribute15
        FROM pa_action_sets sets,
             pa_action_set_lines lines
       WHERE lines.action_set_line_id = p_action_set_line_id
         AND lines.action_set_id = sets.action_set_id;

     RETURN l_action_sets_rec;

END;

FUNCTION get_action_line_conditions (p_action_set_line_id     IN NUMBER)
  RETURN action_line_cond_tbl_type
IS

   l_action_line_cond_tbl   pa_action_set_utils.action_line_cond_tbl_type;

   TYPE number_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE varchar_tbl_type IS TABLE OF VARCHAR2(2000)
      INDEX BY BINARY_INTEGER;

   TYPE date_tbl_type IS TABLE OF DATE
      INDEX BY BINARY_INTEGER;

   l_action_set_line_id_tbl           number_tbl_type;
   l_action_line_cond_id_tbl          number_tbl_type;
   l_condition_date_tbl               date_tbl_type;
   l_condition_code_tbl               varchar_tbl_type;
   l_description_tbl                  varchar_tbl_type;
   l_condition_attribute1_tbl         varchar_tbl_type;
   l_condition_attribute2_tbl         varchar_tbl_type;
   l_condition_attribute3_tbl         varchar_tbl_type;
   l_condition_attribute4_tbl         varchar_tbl_type;
   l_condition_attribute5_tbl         varchar_tbl_type;
   l_condition_attribute6_tbl         varchar_tbl_type;
   l_condition_attribute7_tbl         varchar_tbl_type;
   l_condition_attribute8_tbl         varchar_tbl_type;
   l_condition_attribute9_tbl         varchar_tbl_type;
   l_condition_attribute10_tbl        varchar_tbl_type;

   BEGIN

      SELECT action_set_line_id,
             action_set_line_condition_id,
             description,
             condition_date,
             condition_code,
             condition_attribute1,
             condition_attribute2,
             condition_attribute3,
             condition_attribute4,
             condition_attribute5,
             condition_attribute6,
             condition_attribute7,
             condition_attribute8,
             condition_attribute9,
             condition_attribute10
   BULK COLLECT INTO
             l_action_set_line_id_tbl,
             l_action_line_cond_id_tbl,
             l_description_tbl,
             l_condition_date_tbl,
             l_condition_code_tbl,
             l_condition_attribute1_tbl,
             l_condition_attribute2_tbl,
             l_condition_attribute3_tbl,
             l_condition_attribute4_tbl,
             l_condition_attribute5_tbl,
             l_condition_attribute6_tbl,
             l_condition_attribute7_tbl,
             l_condition_attribute8_tbl,
             l_condition_attribute9_tbl,
             l_condition_attribute10_tbl
        FROM pa_action_set_line_cond
       WHERE action_set_line_id = p_action_set_line_id;

     FOR i IN l_action_line_cond_id_tbl.FIRST .. l_action_line_cond_id_tbl.LAST LOOP

        l_action_line_cond_tbl(i).action_set_line_id := l_action_set_line_id_tbl(i);
        l_action_line_cond_tbl(i).action_set_line_condition_id := l_action_line_cond_id_tbl(i);
        l_action_line_cond_tbl(i).description := l_description_tbl(i);
        l_action_line_cond_tbl(i).condition_date := l_condition_date_tbl(i);
        l_action_line_cond_tbl(i).condition_code := l_condition_code_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute1 := l_condition_attribute1_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute2 := l_condition_attribute2_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute3 := l_condition_attribute3_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute4 := l_condition_attribute4_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute5 := l_condition_attribute5_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute6 := l_condition_attribute6_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute7 := l_condition_attribute7_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute8 := l_condition_attribute8_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute9 := l_condition_attribute9_tbl(i);
        l_action_line_cond_tbl(i).condition_attribute10 := l_condition_attribute10_tbl(i);

     END LOOP;

     RETURN l_action_line_cond_tbl;

END;

FUNCTION get_active_audit_lines (p_action_set_line_id     IN NUMBER)
  RETURN audit_lines_tbl_type
IS

   l_active_audit_lines_tbl  audit_lines_tbl_type;

   TYPE number_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE varchar_tbl_type IS TABLE OF VARCHAR2(2000)
      INDEX BY BINARY_INTEGER;

   TYPE date_tbl_type IS TABLE OF DATE
      INDEX BY BINARY_INTEGER;

    l_action_set_line_id_tbl           number_tbl_type;
    l_object_type_tbl                  varchar_tbl_type;
    l_object_id_tbl                    number_tbl_type;
    l_action_set_type_code_tbl         varchar_tbl_type;
    l_status_code_tbl                  varchar_tbl_type;
    l_action_code_tbl                  varchar_tbl_type;
    l_active_flag_tbl                  varchar_tbl_type;
    l_reason_code_tbl                  varchar_tbl_type;
    l_audit_display_attribute_tbl      varchar_tbl_type;
    l_audit_attribute_tbl              varchar_tbl_type;
    l_action_date_tbl                  date_tbl_type;
    l_reversed_action_set_line_tbl     number_tbl_type;

   BEGIN

      SELECT action_set_line_id,
             object_type,
             object_id,
             action_set_type_code,
             status_code,
             reason_code,
             action_code,
             audit_display_attribute,
             audit_attribute,
             action_date,
             active_flag,
             reversed_action_set_line_id
   BULK COLLECT INTO
             l_action_set_line_id_tbl,
             l_object_type_tbl,
             l_object_id_tbl,
             l_action_set_type_code_tbl,
             l_status_code_tbl,
             l_reason_code_tbl,
             l_action_code_tbl,
             l_audit_display_attribute_tbl,
             l_audit_attribute_tbl,
             l_action_date_tbl,
             l_active_flag_tbl,
             l_reversed_action_set_line_tbl
        FROM pa_action_set_line_aud
       WHERE action_set_line_id = p_action_set_line_id
         AND active_flag = 'Y';


   IF l_reason_code_tbl.COUNT > 0 THEN
     FOR i IN l_reason_code_tbl.FIRST .. l_reason_code_tbl.LAST LOOP

        l_active_audit_lines_tbl(i).action_set_line_id := l_action_set_line_id_tbl(i);
        l_active_audit_lines_tbl(i).object_type := l_object_type_tbl(i);
        l_active_audit_lines_tbl(i).object_id := l_object_id_tbl(i);
        l_active_audit_lines_tbl(i).action_set_type_code := l_action_set_type_code_tbl(i);
        l_active_audit_lines_tbl(i).status_code := l_status_code_tbl(i);
        l_active_audit_lines_tbl(i).reason_code := l_reason_code_tbl(i);
        l_active_audit_lines_tbl(i).action_code := l_action_code_tbl(i);
        l_active_audit_lines_tbl(i).audit_display_attribute := l_audit_display_attribute_tbl(i);
        l_active_audit_lines_tbl(i).audit_attribute := l_audit_attribute_tbl(i);
        l_active_audit_lines_tbl(i).action_date := l_action_date_tbl(i);
        l_active_audit_lines_tbl(i).active_flag := l_active_flag_tbl(i);
        l_active_audit_lines_tbl(i).reversed_action_set_line_id := l_reversed_action_set_line_tbl(i);
      END LOOP;
   END IF;

   RETURN l_active_audit_lines_tbl;

END;


PROCEDURE add_message(p_app_short_name  IN      VARCHAR2,
                      p_msg_name        IN      VARCHAR2,
                      p_token1		IN	VARCHAR2 DEFAULT NULL,
		      p_value1		IN	VARCHAR2 DEFAULT NULL,
		      p_token2		IN	VARCHAR2 DEFAULT NULL,
		      p_value2		IN	VARCHAR2 DEFAULT NULL,
		      p_token3		IN	VARCHAR2 DEFAULT NULL,
		      p_value3		IN	VARCHAR2 DEFAULT NULL,
		      p_token4		IN	VARCHAR2 DEFAULT NULL,
                      p_value4		IN	VARCHAR2 DEFAULT NULL,
	              p_token5		IN	VARCHAR2 DEFAULT NULL,
	              p_value5		IN	VARCHAR2 DEFAULT NULL ) IS

BEGIN

      G_ERROR_EXISTS := 'Y';

      PA_UTILS.Add_Message (p_app_short_name => p_app_short_name
                           ,p_msg_name       => p_msg_name
                           ,p_token1         => p_token1
                           ,p_value1         => p_value1
                           ,p_token2         => p_token2
                           ,p_value2         => p_value2
                           ,p_token3         => p_token3
                           ,p_value3         => p_value3
                           ,p_token4         => p_token4
                           ,p_value4         => p_value4
                           ,p_token5         => p_token5
                           ,p_value5         => p_value5
 );


END;

FUNCTION is_name_unique_in_type(p_action_set_type_code  IN  VARCHAR2,
                                p_action_set_name       IN  VARCHAR2,
                                p_action_set_id         IN  NUMBER := NULL)
  RETURN VARCHAR2
IS

   l_name_unique   VARCHAR2(1);

   CURSOR check_name_unique_in_type IS
   SELECT 'X'
   FROM pa_action_sets
  WHERE action_set_name = p_action_set_name
    AND action_set_type_code = p_action_set_type_code
    AND action_set_template_flag = 'Y'
    AND ((action_set_id <> p_action_set_id AND p_action_set_id IS NOT NULL)
         OR p_action_set_id IS NULL);

BEGIN

  OPEN check_name_unique_in_type;

  FETCH check_name_unique_in_type into l_name_unique;

  IF check_name_unique_in_type%FOUND THEN

     RETURN 'N';

  ELSE

     RETURN 'Y';

  END IF;

  CLOSE check_name_unique_in_type;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END;


FUNCTION is_action_set_a_source(p_action_set_id  IN  NUMBER)
  RETURN VARCHAR2
IS

   l_is_source   VARCHAR2(1);

   CURSOR check_action_set_is_source IS
   SELECT 'X'
   FROM pa_action_sets
  WHERE source_action_set_id = p_action_set_id;

BEGIN

  OPEN check_action_set_is_source;

  FETCH check_action_set_is_source into l_is_source;

  IF check_action_set_is_source%FOUND THEN

     RETURN 'Y';

  ELSE

     RETURN 'N';

  END IF;

  CLOSE check_action_set_is_source;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END;

FUNCTION do_lines_exist(p_action_set_id  IN  NUMBER)
  RETURN VARCHAR2
IS

   l_lines_exist   VARCHAR2(1);

   CURSOR do_lines_exist IS
   SELECT 'X'
   FROM pa_action_set_lines
  WHERE action_set_id = p_action_set_id;

BEGIN

  OPEN do_lines_exist;

  FETCH do_lines_exist into l_lines_exist;

  IF do_lines_exist%FOUND THEN

     RETURN 'Y';

  ELSE

     RETURN 'N';

  END IF;

  CLOSE do_lines_exist;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END;

FUNCTION do_audit_lines_exist(p_action_set_line_id  IN  NUMBER)
  RETURN VARCHAR2
IS

   l_audit_lines_exist   VARCHAR2(1);

   CURSOR do_audit_lines_exist IS
   SELECT 'X'
     FROM pa_action_set_line_aud
    WHERE action_set_line_id = p_action_set_line_id;

BEGIN

  OPEN do_audit_lines_exist;

  FETCH do_audit_lines_exist into l_audit_lines_exist;

  IF do_audit_lines_exist%FOUND THEN

     RETURN 'Y';

  ELSE

     RETURN 'N';

  END IF;

  CLOSE do_audit_lines_exist;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

END;

FUNCTION get_last_performed_date(p_action_set_line_id  IN  NUMBER)
  RETURN DATE
IS

   l_action_date DATE;

BEGIN

   SELECT max(trunc(action_date)) INTO l_action_date
     FROM pa_action_set_line_aud
    WHERE action_set_line_id = p_action_set_line_id;

   RETURN l_action_date;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      RETURN NULL;

   WHEN OTHERS THEN
      RAISE;

END;

PROCEDURE Check_Action_Set_Name_Or_Id (p_action_set_id        IN pa_action_sets.action_set_id%TYPE := NULL
                                      ,p_action_set_name      IN pa_action_sets.action_set_name%TYPE
                                      ,p_action_set_type_code IN pa_action_set_types.action_set_type_code%TYPE
                                      ,p_check_id_flag        IN VARCHAR2
                                      ,p_date                 IN DATE := SYSDATE
                                      ,x_action_set_id       OUT NOCOPY pa_action_sets.action_set_id%TYPE --File.Sql.39 bug 4440895
                                      ,x_return_status       OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
                                      ,x_error_message_code  OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    pa_debug.init_err_stack ('pa_action_set_utils.Check_Action_Set_Name_Or_Id');

	IF p_action_set_id IS NOT NULL THEN
		IF p_check_id_flag = 'Y' THEN
			SELECT action_set_id
		        INTO   x_action_set_id
		        FROM   pa_action_sets
		        WHERE  action_set_id = p_action_set_id
            -- 2767129: Modified select stmt to use action_set_template_flag for
            -- performance improvement. This is OK because the action set LOV
            -- only displays template action sets.
                          AND  action_set_template_flag = 'Y'
            -- end of 2767129
                          AND  action_set_name = p_action_set_name
                          AND  action_set_type_code = p_action_set_type_code
                          AND  p_date between start_date_active AND nvl(end_date_active, p_date);
	        ELSE
			x_action_set_id := p_action_set_id;

		END IF;
        ELSE
		SELECT action_set_id
	        INTO   x_action_set_id
	        FROM   pa_action_sets
	        WHERE  action_set_name = p_action_set_name
                -- 2767129: Modified select stmt to use action_set_template_flag for
            -- performance improvement. This is OK because the action set LOV
            -- only displays template action sets.
                          AND  action_set_template_flag = 'Y'
            -- end of 2767129
                  AND  action_set_type_code = p_action_set_type_code
                  AND  p_date between start_date_active AND nvl(end_date_active, p_date);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_message_code := 'PA_ACTION_SET_INVALID';
        WHEN TOO_MANY_ROWS THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_message_code := 'PA_ACTION_SET_INVALID';
        WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

 END Check_Action_Set_Name_Or_Id;

 PROCEDURE get_line_information_messages(x_line_numbers_tbl  OUT NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
                                         x_line_messages_tbl OUT NOCOPY SYSTEM.pa_varchar2_2000_tbl_type) --File.Sql.39 bug 4440895
 IS

 BEGIN

 x_line_numbers_tbl  := pa_action_sets_pvt.g_line_number_msg_tbl;
 x_line_messages_tbl := pa_action_sets_pvt.g_info_msg_tbl;

 END;

END pa_action_set_utils;

/
