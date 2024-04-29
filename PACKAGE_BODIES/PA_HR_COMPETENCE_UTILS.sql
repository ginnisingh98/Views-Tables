--------------------------------------------------------
--  DDL for Package Body PA_HR_COMPETENCE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_COMPETENCE_UTILS" AS
-- $Header: PACOMUTB.pls 120.1 2005/08/19 16:20:35 mwasowic noship $

--
--  PROCEDURE
--              Check_Rating_Level_Or_Id
--  PURPOSE
--              This procedure does the following
--              If Rating Level (Step Value) is passed converts it to the id
--		If Rating Level id is passed,
--		based on the check_id_flag validates it
--  HISTORY
--   27-JUN-2000      R. Krishnamurthy       Created
--

procedure Check_Rating_Level_Or_Id
    ( p_competence_id    IN per_competences.competence_id%TYPE
    ,p_rating_level_id   IN per_rating_levels.rating_level_id%TYPE
    ,p_rating_level      IN per_rating_levels.step_value%TYPE
    ,p_check_id_flag IN VARCHAR2
    ,x_rating_level_id  OUT NOCOPY per_rating_levels.rating_level_id%TYPE --File.Sql.39 bug 4440895
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

    l_current_id NUMBER := NULL;
    l_num_ids NUMBER := 0;
    l_id_found_flag VARCHAR(1) := 'N';

    CURSOR r_ids IS
        SELECT rating_level_id
        FROM per_competence_levels_v
        WHERE competence_id = p_competence_id
        AND step_value = p_rating_level;
BEGIN
      pa_debug.init_err_stack ('pa_competence_utils.check_rating_level_or_id');
      IF (p_rating_level_id is not null) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT rating_level_id
          INTO x_rating_level_id
          FROM per_competence_levels_v
          WHERE competence_id = p_competence_id
          AND rating_level_id = p_rating_level_id;
        ELSIF (p_check_id_flag = 'N') THEN
            x_rating_level_id := p_rating_level_id;
        ELSIF (p_check_id_flag = 'A') THEN
            IF (p_rating_level IS NULL) THEN
            -- Return a null ID since the level is null.
                x_rating_level_id := NULL;
            ELSE
                -- Find the ID which matches the level passed
                OPEN r_ids;
                LOOP
                   FETCH r_ids INTO l_current_id;
                   EXIT WHEN r_ids%NOTFOUND;
                   IF (l_current_id = p_rating_level_id) THEN
                      l_id_found_flag := 'Y';
                      x_rating_level_id := p_rating_level_id;
                   END IF;
                END LOOP;
                l_num_ids := r_ids%ROWCOUNT;
                CLOSE r_ids;

                IF (l_num_ids = 0) THEN
                   -- No IDs for level
                   RAISE NO_DATA_FOUND;
                ELSIF (l_num_ids = 1) THEN
                   -- Since there is only one ID for the level use it.
                   x_rating_level_id := l_current_id;
                ELSIF (l_id_found_flag = 'N') THEN
                   -- More than one ID for the level and none of the IDs matched
                   -- the ID passed in.
                   RAISE TOO_MANY_ROWS;
                END IF;
             END IF;
        END IF;
      ELSE -- Find ID since it was not passed.
        IF (p_rating_level IS NOT NULL) THEN
            SELECT rating_level_id
            INTO x_rating_level_id
            FROM per_competence_levels_v
            WHERE competence_id = p_competence_id
            AND step_value = p_rating_level;
        ELSE
            x_rating_level_id := NULL;
        END IF;
      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
        pa_debug.reset_err_stack;
  EXCEPTION
       WHEN no_data_found THEN
         x_rating_level_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_RATING_INVALID_AMBIGOUS';
       WHEN too_many_rows THEN
         x_rating_level_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_RATING_INVALID_AMBIGOUS';
       WHEN OTHERS THEN
         x_rating_level_id := NULL;
         fnd_msg_pub.add_exc_msg
          (p_pkg_name => 'PA_COMPETENCE_UTILS',
           p_procedure_name => pa_debug.g_err_stack );
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_Rating_Level_Or_Id;

PROCEDURE Check_CompName_Or_Id
          ( p_competence_id      IN per_competences.competence_id%TYPE
           ,p_competence_alias   IN per_competences.competence_alias%TYPE
           ,p_competence_name    IN per_competences.name%TYPE := null
           ,p_check_id_flag      IN VARCHAR2
           ,x_competence_id     OUT NOCOPY per_competences.competence_id%TYPE --File.Sql.39 bug 4440895
           ,x_return_status     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_error_msg_code    OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

    l_current_id NUMBER := NULL;
    l_num_ids NUMBER := 0;
    l_id_found_flag VARCHAR(1) := 'N';

    CURSOR c_ids IS
        SELECT competence_id
        FROM per_competences
        WHERE name = p_competence_name;
BEGIN
     pa_debug.init_err_stack ('pa_competence_utils.check_compName_or_id');
     IF p_competence_id IS NOT NULL THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT competence_id
          INTO  x_competence_id
          FROM  per_competences
          WHERE competence_id = p_competence_id;
        ELSIF (p_check_id_flag = 'N') THEN
            x_competence_id := p_competence_id;
        ELSIF (p_check_id_flag = 'A') THEN
            IF (p_competence_name IS NULL) THEN
                -- Return a null ID since the name is null.
                x_competence_id := NULL;
            ELSE
               -- Find the ID which matches the Name passed
                OPEN c_ids;
                LOOP
                   FETCH c_ids INTO l_current_id;
                   EXIT WHEN c_ids%NOTFOUND;
                   IF (l_current_id = p_competence_id) THEN
                      l_id_found_flag := 'Y';
                      x_competence_id := p_competence_id;
                   END IF;
                END LOOP;
                l_num_ids := c_ids%ROWCOUNT;
                CLOSE c_ids;

                IF (l_num_ids = 0) THEN
                   -- No IDs for name
                   RAISE NO_DATA_FOUND;
                ELSIF (l_num_ids = 1) THEN
                   -- Since there is only one ID for the name use it.
                   x_competence_id := l_current_id;
                ELSIF (l_id_found_flag = 'N') THEN
                   -- More than one ID for the name and none of the IDs matched
                   -- the ID passed in.
                   RAISE TOO_MANY_ROWS;
                END IF;
             END IF;
        END IF;
      ELSIF (p_competence_alias is not null) THEN
          SELECT competence_id
          INTO x_competence_id
          FROM per_competences
          WHERE competence_alias = p_competence_alias;
      ELSE
         IF (p_competence_name IS NOT NULL) THEN
            SELECT competence_id
            INTO x_competence_id
            FROM per_competences
            WHERE name = p_competence_name;
         ELSE
            x_competence_id := NULL;
         END IF;
      END IF;
      x_return_status:= FND_API.G_RET_STS_SUCCESS;
      pa_debug.reset_err_stack;
EXCEPTION
       WHEN no_data_found THEN
         x_competence_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_COMP_INVALID_AMBIGOUS';
       WHEN too_many_rows THEN
         x_competence_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_COMP_INVALID_AMBIGOUS';
       WHEN OTHERS THEN
         x_competence_id := NULL;
         fnd_msg_pub.add_exc_msg
          (p_pkg_name => 'PA_COMPETENCE_UTILS',
           p_procedure_name => pa_debug.g_err_stack );
           x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Check_CompName_Or_Id ;

PROCEDURE Get_KFF_Structure_Num
    (p_competency_structure_type IN VARCHAR2
     ,p_business_group_id       IN NUMBER
     ,x_kff_structure_num      OUT NOCOPY fnd_id_flex_structures_vl.id_flex_num%TYPE --File.Sql.39 bug 4440895
     ,x_return_status	       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_error_message_code      OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895
BEGIN
   NULL;
END Get_KFF_Structure_Num ;

PROCEDURE Get_KFF_SegmentInfo
 ( p_kff_structure_num    IN fnd_id_flex_structures_vl.id_flex_num%TYPE
  ,x_segment_name1   OUT NOCOPY fnd_id_flex_segments_vl.segment_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_prompt1 OUT NOCOPY fnd_id_flex_segments_vl.form_left_prompt%TYPE --File.Sql.39 bug 4440895
  ,x_column_name1    OUT NOCOPY fnd_id_flex_segments_vl.application_column_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_number1 OUT NOCOPY fnd_id_flex_segments_vl.segment_num%TYPE --File.Sql.39 bug 4440895
  ,x_value_set_id1   OUT NOCOPY fnd_id_flex_segments_vl.flex_value_set_id%TYPE --File.Sql.39 bug 4440895
  ,x_segment_name2   OUT NOCOPY fnd_id_flex_segments_vl.segment_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_prompt2 OUT NOCOPY fnd_id_flex_segments_vl.form_left_prompt%TYPE --File.Sql.39 bug 4440895
  ,x_column_name2    OUT NOCOPY fnd_id_flex_segments_vl.application_column_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_number2 OUT NOCOPY fnd_id_flex_segments_vl.segment_num%TYPE --File.Sql.39 bug 4440895
  ,x_value_set_id2   OUT NOCOPY fnd_id_flex_segments_vl.flex_value_set_id%TYPE --File.Sql.39 bug 4440895
  ,x_segment_name3   OUT NOCOPY fnd_id_flex_segments_vl.segment_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_prompt3 OUT NOCOPY fnd_id_flex_segments_vl.form_left_prompt%TYPE --File.Sql.39 bug 4440895
  ,x_column_name3    OUT NOCOPY fnd_id_flex_segments_vl.application_column_name%TYPE --File.Sql.39 bug 4440895
  ,x_segment_number3 OUT NOCOPY fnd_id_flex_segments_vl.segment_num%TYPE --File.Sql.39 bug 4440895
  ,x_value_set_id3   OUT NOCOPY fnd_id_flex_segments_vl.flex_value_set_id%TYPE --File.Sql.39 bug 4440895
  ,x_error_message_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status	 OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

BEGIN
   NULL;
END Get_KFF_SegmentInfo ;

-- Get Competencies : This procedure returns the competencies defined
-- for a given object. Currently , the following object names are
-- supported . PROJECT_ROLE, OPEN_ASSIGNMENT , JOB
-- PROJECT_ROLE and OPEN_ASSIGNMENT are fetched with the object_id
-- while for JOB, the record is fetched with the job_id
-- No other values for object_name are supported currently
PROCEDURE get_competencies
   ( p_object_name	    IN	per_competence_elements.object_name%TYPE
    ,p_object_id	    IN	per_competence_elements.object_id%TYPE
    ,x_competency_tbl	    OUT	NOCOPY competency_tbl_typ /* Added NOCOPY for bug#2674619 */
    ,x_no_of_competencies   OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_error_message_code   OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_return_status	    OUT	NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
CURSOR l_comp_csr IS
SELECT
       pce.object_id,
       pce.competence_id,
       pce.proficiency_level_id rating_level_id,
       pce.competence_element_id,
       pce.rowid,
       pce.mandatory,
       pc.name      ,
       pc.competence_alias     ,
       Decode(pc.business_group_id ,NULL, 'Y','N') global_flag,
       pce.object_version_number
FROM
	per_competence_elements pce,
	per_competences pc
WHERE  pce.object_name = p_object_name
AND    pce.object_id   = p_object_id
AND    pce.competence_id = pc.competence_id;

CURSOR l_job_comp_csr IS
SELECT
       pce.object_id,
       pce.competence_id,
       pce.proficiency_level_id rating_level_id,
       pce.competence_element_id,
       pce.rowid,
       pce.mandatory,
       pc.name      ,
       pc.competence_alias     ,
       Decode(pc.business_group_id ,NULL, 'Y','N') global_flag,
       pce.object_version_number
FROM   per_competence_elements pce,
       per_competences pc
WHERE  job_id = p_object_id
AND    pce.competence_id = pc.competence_id;
l_index NUMBER := 0;
l_competence_exists  VARCHAR2(1);
l_comp_csr_rec l_comp_csr%ROWTYPE;
l_competency_tbl competency_tbl_typ;
BEGIN
   pa_debug.init_err_stack ('pa_competence_utils.get_competencies');
   x_return_status:= FND_API.G_RET_STS_SUCCESS;
   IF p_object_name IN ('OPEN_ASSIGNMENT','PROJECT_ROLE') THEN
     OPEN l_comp_csr; LOOP
     FETCH l_comp_csr INTO l_comp_csr_rec;
     EXIT WHEN l_comp_csr%NOTFOUND;
     l_index := l_index + 1;
     x_competency_tbl(l_index).object_id := p_object_id ;
     x_competency_tbl(l_index).competence_id := l_comp_csr_rec.competence_id;
     x_competency_tbl(l_index).rating_level_id :=
       l_comp_csr_rec.rating_level_id;
     x_competency_tbl(l_index).competence_element_id :=
       l_comp_csr_rec.competence_element_id;
     x_competency_tbl(l_index).row_id := l_comp_csr_rec.rowid;
     x_competency_tbl(l_index).mandatory := l_comp_csr_rec.mandatory;
     x_competency_tbl(l_index).competence_name     := l_comp_csr_rec.name ;
     x_competency_tbl(l_index).competence_alias    :=
			l_comp_csr_rec.competence_alias ;
     x_competency_tbl(l_index).global_flag := l_comp_csr_rec.global_flag;
     x_competency_tbl(l_index).object_version_number :=
                 l_comp_csr_rec.object_version_number;
       END LOOP;
     CLOSE l_comp_csr;
   ELSIF
    p_object_name = 'JOB' THEN
    OPEN l_job_comp_csr;
    LOOP
      FETCH l_job_comp_csr INTO l_comp_csr_rec;
      EXIT WHEN l_job_comp_csr%NOTFOUND;
      l_competence_exists := 'N';
      IF l_competency_tbl.EXISTS(1) THEN
        FOR i IN 1..l_competency_tbl.COUNT LOOP
        IF l_competency_tbl(i).competence_id = l_comp_csr_rec.competence_id THEN
           l_competence_exists := 'Y';
           EXIT;
        END IF;
       END LOOP;
      END IF; -- If competency tbl EXISTS
      IF l_competence_exists = 'N' THEN
        l_index := l_index + 1;
        l_competency_tbl(l_index).object_id := p_object_id;
        l_competency_tbl(l_index).competence_id := l_comp_csr_rec.competence_id;
        l_competency_tbl(l_index).rating_level_id :=
        l_comp_csr_rec.rating_level_id;
        l_competency_tbl(l_index).competence_element_id :=
        l_comp_csr_rec.competence_element_id;
        l_competency_tbl(l_index).row_id := l_comp_csr_rec.rowid;
        l_competency_tbl(l_index).mandatory := l_comp_csr_rec.mandatory;
        l_competency_tbl(l_index).competence_name  := l_comp_csr_rec.name ;
        l_competency_tbl(l_index).competence_alias :=
			l_comp_csr_rec.competence_alias ;
        l_competency_tbl(l_index).global_flag := l_comp_csr_rec.global_flag;
        l_competency_tbl(l_index).object_version_number :=
                 l_comp_csr_rec.object_version_number;
      END IF; --end if l_competence_exists
    END LOOP; -- End loop for the cursor
      CLOSE l_job_comp_csr;
      x_competency_tbl := l_competency_tbl;
    END IF;  -- End if p_object_name = 'JOB'
      x_no_of_competencies := l_index;
      pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_COMPETENCE_UTILS',
       p_procedure_name => pa_debug.g_err_stack );
       x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
END get_competencies;

-- Get Person Competencies : This procedure returns the competencies
-- defined for a person
PROCEDURE get_person_competencies
   ( p_person_id            IN   NUMBER
    ,x_competency_tbl       OUT  NOCOPY competency_tbl_typ /* Added NOCOPY for bug#2674619 */
    ,x_no_of_competencies   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_error_message_code   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_return_status        OUT  NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

CURSOR l_comp_csr IS
SELECT
       pce.person_id,
       pce.competence_id,
       pce.proficiency_level_id rating_level_id,
       pce.competence_element_id,
       pce.rowid,
       pce.mandatory,
       pc.name      ,
       pc.competence_alias     ,
       Decode(pc.business_group_id ,NULL, 'Y','N') global_flag,
       pce.object_version_number
FROM
	per_competence_elements pce,
	per_competences pc
WHERE  pce.person_id   = p_person_id
AND    pce.competence_id = pc.competence_id;

l_index NUMBER := 0;
l_competence_exists  VARCHAR2(1);
l_comp_csr_rec l_comp_csr%ROWTYPE;
l_competency_tbl competency_tbl_typ;
BEGIN

   pa_debug.init_err_stack ('pa_competence_utils.get_person_competencies');

   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   OPEN l_comp_csr;
   LOOP

      FETCH l_comp_csr INTO l_comp_csr_rec;
      EXIT WHEN l_comp_csr%NOTFOUND;

      l_index := l_index + 1;

      x_competency_tbl(l_index).object_id := p_person_id;
      x_competency_tbl(l_index).competence_id := l_comp_csr_rec.competence_id;
      x_competency_tbl(l_index).rating_level_id :=
          l_comp_csr_rec.rating_level_id;
      x_competency_tbl(l_index).competence_element_id :=
          l_comp_csr_rec.competence_element_id;
      x_competency_tbl(l_index).row_id := l_comp_csr_rec.rowid;
      x_competency_tbl(l_index).mandatory := l_comp_csr_rec.mandatory;
      x_competency_tbl(l_index).competence_name     := l_comp_csr_rec.name ;
      x_competency_tbl(l_index).competence_alias    :=
          l_comp_csr_rec.competence_alias ;
      x_competency_tbl(l_index).global_flag := l_comp_csr_rec.global_flag;
      x_competency_tbl(l_index).object_version_number :=
          l_comp_csr_rec.object_version_number;

   END LOOP;
   CLOSE l_comp_csr;

   x_no_of_competencies := l_index;

   pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_COMPETENCE_UTILS',
       p_procedure_name => pa_debug.g_err_stack );
       x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
END get_person_competencies;

FUNCTION check_competence_exists
   ( p_object_name	IN	per_competence_elements.object_name%TYPE
    ,p_object_id	IN	per_competence_elements.object_id%TYPE
    ,p_competence_id    IN per_competences.competence_id%TYPE )
    RETURN VARCHAR2  IS
l_dummy VARCHAR2(1);
BEGIN
    SELECT 'x' INTO l_dummy
    FROM per_competence_elements
    WHERE object_id = p_object_id
    AND   object_name = p_object_name
    AND   competence_id = p_competence_id ;
    RETURN 'Y';
EXCEPTION
       WHEN no_data_found THEN
	    RETURN 'N';
      -- Too many rows should not occur in normal cases; Still
      -- we will return 'Y' if that happens
       WHEN too_many_rows THEN
            RETURN 'Y';
       WHEN OTHERS THEN
       RAISE;
END check_competence_exists;

FUNCTION Get_Res_Competences
   (p_person_id         IN      pa_resources_denorm.person_id%TYPE)
   RETURN VARCHAR2  IS

TYPE number_tbl     IS TABLE OF NUMBER(15);
TYPE varchar240_tbl IS TABLE OF VARCHAR(240);
TYPE varchar30_tbl  IS TABLE OF VARCHAR(30);
l_competences_list VARCHAR2(4500) := ''; /* Bug 3439566: Changed the size of the variable from 2000 to 4500 */
l_competence_name  varchar240_tbl;
l_competence_alias varchar30_tbl;
l_competence_level number_tbl;

BEGIN
    SELECT comp.name,
           comp.competence_alias,
           rl.step_value
    BULK COLLECT INTO
           l_competence_name,
           l_competence_alias,
           l_competence_level
    FROM  PER_COMPETENCE_ELEMENTS comp_ele,
          PER_COMPETENCES comp,
          PER_RATING_LEVELS rl
    WHERE comp_ele.competence_id        = comp.competence_id
    AND   comp_ele.person_id            = p_person_id
    AND   comp_ele.proficiency_level_id = rl.rating_level_id (+);

    IF l_competence_name.count > 0 THEN
       FOR i in l_competence_name.FIRST .. l_competence_name.LAST LOOP
           IF l_competence_alias(i) IS NOT NULL THEN
                  l_competences_list := l_competences_list || l_competence_level(i) || l_competence_alias(i);
                  /* Code addition for Bug 3439566 starts */
                  If length(l_competences_list) > 4000 then
                    exit;
                  end if;
                  /* Code addition for Bug 3439566 ends */
           ELSE
                  l_competences_list := l_competences_list || l_competence_level(i) || l_competence_name(i);
                  /* Code addition for Bug 3439566 starts */
                  If length(l_competences_list) > 4000 then
                    exit;
                  end if;
                  /* Code addition for Bug 3439566 ends */
           END IF;

           IF i <> l_competence_name.count THEN
              l_competences_list := l_competences_list || ',';
           END IF;
       END LOOP;
    END IF;

    RETURN substrb(l_competences_list,1,4000); /* Bug 3439566: Added substrb */
EXCEPTION
    WHEN OTHERS THEN
         RAISE;

END Get_Res_Competences;

FUNCTION Get_Res_Competences_Count
   (p_person_id         IN      pa_resources_denorm.person_id%TYPE)
   RETURN NUMBER  IS
l_count NUMBER;
BEGIN
    SELECT count(*)
    INTO   l_count
    FROM   PER_COMPETENCE_ELEMENTS
    WHERE  person_id = p_person_id;

    RETURN l_count;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN 0;
       WHEN OTHERS THEN
            RAISE;
END Get_Res_Competences_Count;

FUNCTION Get_Res_Comp_Last_Updated
   (p_person_id         IN      pa_resources_denorm.person_id%TYPE)
   RETURN DATE  IS
l_date DATE;
BEGIN
    SELECT MAX(last_update_date)
    INTO   l_date
    FROM   PER_COMPETENCE_ELEMENTS
    WHERE  person_id = p_person_id;

    RETURN l_date;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN null;
       WHEN OTHERS THEN
            RAISE;
END Get_Res_Comp_Last_Updated;

FUNCTION Get_Req_Competences
   (p_assignment_id         IN      pa_project_assignments.assignment_id%TYPE)
   RETURN VARCHAR2  IS

TYPE number_tbl     IS TABLE OF NUMBER(15);
TYPE varchar240_tbl IS TABLE OF VARCHAR(240);
TYPE varchar30_tbl  IS TABLE OF VARCHAR(30);
l_competences_list VARCHAR2(4500) := '';  /* Bug 3439566: Changed the size of the variable from 2000 to 4500 */
l_competence_name  varchar240_tbl;
l_competence_alias varchar30_tbl;
l_competence_level number_tbl;

BEGIN
    SELECT competence_alias,
           competence_name,
           rating_level_value
    BULK COLLECT INTO
           l_competence_alias,
           l_competence_name,
           l_competence_level
    FROM   pa_open_asgmt_competences_v
    WHERE  assignment_id = p_assignment_id;

    IF l_competence_name.count > 0 THEN
       FOR i in l_competence_name.FIRST .. l_competence_name.LAST LOOP
           IF l_competence_alias(i) IS NOT NULL THEN
                  l_competences_list := l_competences_list || l_competence_level(i) || l_competence_alias(i);
                  /* Code addition for Bug 3439566 starts */
                  If length(l_competences_list) > 4000 then
                    exit;
                  end if;
                  /* Code addition for Bug 3439566 ends */
           ELSE
                  l_competences_list := l_competences_list || l_competence_level(i) || l_competence_name(i);
                  /* Code addition for Bug 3439566 starts */
                  If length(l_competences_list) > 4000 then
                    exit;
                  end if;
                  /* Code addition for Bug 3439566 ends */
           END IF;

           IF i <> l_competence_name.count THEN
              l_competences_list := l_competences_list || ',';
           END IF;
       END LOOP;
    END IF;

    RETURN substrb(l_competences_list,1,4000); /* Bug 3439566: Added substrb */
EXCEPTION
    WHEN OTHERS THEN
         RAISE;

END Get_Req_Competences;

end pa_hr_competence_utils ;

/
