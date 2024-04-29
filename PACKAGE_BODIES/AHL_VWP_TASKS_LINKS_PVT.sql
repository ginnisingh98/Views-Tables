--------------------------------------------------------
--  DDL for Package Body AHL_VWP_TASKS_LINKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_TASKS_LINKS_PVT" AS
 /* $Header: AHLVTLNB.pls 120.0 2005/05/26 01:28:49 appldev noship $ */
G_PKG_NAME  VARCHAR2(30)  := 'AHL_VWP_TASKS_LINKS_PVT';

G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE DEFAULT_MISSING_ATTRIBS
(p_x_task_link_tbl              IN OUT NOCOPY AHL_VWP_TASKS_LINKS_PVT.TASK_LINK_TBL)
AS
BEGIN
        IF p_x_task_link_TBL.count >0
        THEN

                FOR i IN  p_x_task_link_TBL.FIRST.. p_x_task_link_TBL.LAST
                LOOP

                IF p_x_task_link_tbl(i).TASK_LINK_ID= FND_API.G_MISS_NUM
                THEN
                p_x_task_link_tbl(i).TASK_LINK_ID:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).OBJECT_VERSION_NUMBER= FND_API.G_MISS_NUM
                THEN
                p_x_task_link_tbl(i).OBJECT_VERSION_NUMBER:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).LAST_UPDATE_DATE=FND_API.G_MISS_DATE
                THEN
                p_x_task_link_tbl(i).LAST_UPDATE_DATE:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).LAST_UPDATED_BY= FND_API.G_MISS_NUM
                THEN
                p_x_task_link_tbl(i).LAST_UPDATED_BY:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).CREATION_DATE=FND_API.G_MISS_DATE
                THEN
                p_x_task_link_tbl(i).CREATION_DATE:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).CREATED_BY= FND_API.G_MISS_NUM
                THEN
                p_x_task_link_tbl(i).CREATED_BY:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).LAST_UPDATE_LOGIN= FND_API.G_MISS_NUM
                THEN
                p_x_task_link_tbl(i).LAST_UPDATE_LOGIN:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).VISIT_TASK_ID= FND_API.G_MISS_NUM
                THEN
                p_x_task_link_tbl(i).VISIT_TASK_ID:=NULL;
                END IF;
                IF p_x_task_link_tbl(i).PARENT_TASK_ID= FND_API.G_MISS_NUM
                THEN
                p_x_task_link_tbl(i).PARENT_TASK_ID:=NULL;
                END IF;

                IF  p_x_task_link_TBL(i).ATTRIBUTE_CATEGORY= FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE_CATEGORY:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE1=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE1:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE2=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE2:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE3=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE3:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE4 IS NULL OR p_x_task_link_TBL(i).ATTRIBUTE4=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE4:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE5=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE5:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE6=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE6:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE7=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE7:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE8=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE8:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE9=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE9:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE10=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE10:=NULL;
                END IF;

                IF  p_x_task_link_TBL(i).ATTRIBUTE11=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE11:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE12=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE12:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE13=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE13:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE14=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE14:=NULL;
                END IF;

                IF p_x_task_link_TBL(i).ATTRIBUTE15=FND_API.G_MISS_CHAR
                THEN
                        p_x_task_link_TBL(i).ATTRIBUTE15:=NULL;
                END IF;
                END LOOP;
        END IF;
END;

 PROCEDURE VALIDATE_VWP_LINKS
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_task_link_rec          IN     TASK_LINK_rEC
 )
as

-- Check For Unique Combination

  CURSOR CHECK_UNIQ(C_PARENT_TASK_ID NUMBER,C_visit_Task_id NUMBER)
      IS
  select count(*)
  from  AHL_TASK_LINKS
  where VISIT_TASK_ID=C_VISIT_TASK_ID
  and   PARENT_TASK_ID=C_PARENT_TASK_ID;

  -- Changes done for Post 11.5.10  by senthil.

-- Commented as per review comments
/*CURSOR  c_child_task(p_child_task_id IN NUMBER)
IS
select stage_num from ahl_vwp_stages_b where stage_id = (SELECT  stage_id
FROM    ahl_visit_tasks_vl
WHERE   visit_task_id = p_child_task_id);

l_child_stage_num  number;
*/

CURSOR  c_parent_or_child_task(p_parent_or_child_task_id IN NUMBER)
IS
select stage_num from ahl_vwp_stages_b where stage_id = (SELECT  stage_id
FROM    ahl_visit_tasks_vl
WHERE   visit_task_id = p_parent_or_child_task_id);

l_parent_stage_num  number;
l_child_stage_num  number;

--Commented as is never used
/*CURSOR c_job_status(p_visit_task_id IN NUMBER)
IS
SELECT status_code,
       confirm_failure_flag
FROM   ahl_workorders
WHERE  visit_task_id = p_visit_task_id;
*/

CURSOR  c_task_status(p_task_id IN NUMBER)
IS
select 'X'
FROM    ahl_visit_tasks_b
WHERE   visit_task_id = p_task_id
AND    status_code = 'RELEASED';

CURSOR  c_task_type_code(p_task_id IN NUMBER)
IS
select 'X'
FROM    ahl_visit_tasks_b
WHERE   visit_task_id = p_task_id
AND    task_type_code = 'SUMMARY';

-- As per latest Post 11.5.10 DLD if the task are in release status
-- user cannot create dependencies.
-- Commented by amagrawa as user can associate only task in  planning status to task hierarchy
/*CURSOR c_children_check_status(p_parent_visit_task_id IN NUMBER)
IS
SELECT 'X'
FROM   ahl_task_links lin,
       ahl_visit_tasks_b vt
WHERE  lin.visit_task_id = vt.visit_task_id
AND    vt.status_code = 'RELEASED'
START WITH  lin.parent_task_id = p_parent_visit_task_id
CONNECT BY PRIOR lin.visit_task_id = lin.parent_task_id;
*/
CURSOR c_task_number(p_task_id IN NUMBER)
IS
SELECT VISIT_TASK_NUMBER
FROM ahl_visit_tasks_b
where visit_task_id = p_task_id;

l_dummy VARCHAR2(1);
l_parent_task_number number;
l_child_task_number number;

 L_API_NAME           CONSTANT VARCHAR2(30) := 'VALIDATE_VWP_LINKS';
 L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
 l_counter2              NUMBER:=0;
 l_child_task_id          number;
 l_parent_task_id         number;

 BEGIN

        x_return_status:=FND_API.G_RET_STS_SUCCESS;


	 -- Changes done for Post 11.5.10  by senthil.
	IF p_task_link_rec.HIERARCHY_INDICATOR='AFTER'
	THEN
		l_parent_task_id := p_task_link_rec.visit_task_id;
		l_child_task_id  := p_task_link_rec.parent_task_id;
	ELSE
		l_parent_task_id := p_task_link_rec.parent_task_id;
		l_child_task_id  := p_task_link_rec.visit_task_id;
	END IF;

-- Added by amagrawa to check for a task in summary status
	OPEN c_task_type_code(p_task_link_rec.parent_task_id);
	FETCH c_task_type_code INTO l_dummy;
	IF c_task_type_code%FOUND THEN
	 --Added by amagrawa
		 open c_task_number(p_task_link_rec.parent_task_id);
         FETCH c_task_number into l_parent_task_number;
		 CLOSE c_task_number;
		--End of change by amagrawa
    	CLOSE c_task_type_code;
		FND_MESSAGE.SET_NAME('AHL','AHL_VWP_TASK_SUMMARY');
		FND_MESSAGE.SET_TOKEN('TASK_NUM',l_parent_task_number);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE c_task_type_code;

	OPEN c_task_status(l_parent_task_id);
	FETCH c_task_status INTO l_dummy;
	IF c_task_status%FOUND THEN
	 --Added by amagrawa
		 open c_task_number(l_parent_task_id);
			FETCH c_task_number into l_parent_task_number;
		 CLOSE c_task_number;
		--End of change by amagrawa
    	CLOSE c_task_status;
		FND_MESSAGE.SET_NAME('AHL','AHL_VWP_TASK_PARENT_REL');
		FND_MESSAGE.SET_TOKEN('TASK_NUM',l_parent_task_number);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE c_task_status;


	OPEN c_task_status(l_child_task_id);
	FETCH c_task_status INTO l_dummy;
	IF c_task_status%FOUND THEN
	   --Added by amagrawa
      open c_task_number(l_child_task_id);
      FETCH c_task_number into l_child_task_number;
      CLOSE c_task_number;
    --End of change by amagrawa
        CLOSE c_task_status;
		FND_MESSAGE.SET_NAME('AHL','AHL_VWP_TASK_CHILD_REL');
		FND_MESSAGE.SET_TOKEN('TASK_NUM',l_child_task_number);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE c_task_status;

-- Commented by amagrawa based on review commenst
/*	OPEN c_children_check_status(p_task_link_rec.PARENT_TASK_ID);
	FETCH c_children_check_status INTO l_dummy;
	IF c_children_check_status%FOUND THEN
	   --Added by amagrawa
    	open c_task_number(p_task_link_rec.PARENT_TASK_ID);
    	FETCH c_task_number into l_parent_task_number;
    	CLOSE c_task_number;
    --End of change by amagrawa
	  FND_MESSAGE.SET_NAME('AHL','AHL_VWP_TSK_PRECHILD_REL');
			FND_MESSAGE.SET_TOKEN('TASK_NUM',l_parent_task_number);
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE c_children_check_status;
*/

	OPEN c_parent_or_child_task(l_parent_task_id);
	FETCH c_parent_or_child_task INTO l_parent_stage_num;
	/*IF c_parent_task%NOTFOUND THEN
	  FND_MESSAGE.SET_NAME('AHL','AHL_VWP_PARENT_TASK_NULL');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
	*/
	CLOSE c_parent_or_child_task;


	OPEN c_parent_or_child_task(l_child_task_id);
	FETCH c_parent_or_child_task INTO l_child_stage_num;
	/*IF c_child_task%NOTFOUND THEN
	  FND_MESSAGE.SET_NAME('AHL','AHL_VWP_CONTEXT_TASK_NULL');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
	*/
	CLOSE c_parent_or_child_task;

	IF l_parent_stage_num IS NOT NULL
	   AND l_child_stage_num IS NOT NULL
	   AND l_child_stage_num < l_parent_stage_num
	THEN
	 --Added by amagrawa
    open c_task_number (l_child_task_id);
    FETCH c_task_number into l_child_task_number;
    CLOSE c_task_number;

	open c_task_number(l_parent_task_id);
    FETCH c_task_number into l_parent_task_number;
    CLOSE c_task_number;
    --End of change by amagrawa

	  FND_MESSAGE.SET_NAME('AHL','AHL_VWP_CHILD_STG_GT');
	  FND_MESSAGE.SET_TOKEN('CHILD_TASK_NUM',l_child_task_number);
	  FND_MESSAGE.SET_TOKEN('PARENT_TASK_NUM',l_parent_task_number);
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- End of Post 11.5.10 Changes.


        IF  p_task_link_rec.dml_operation<>'D'
        THEN

                IF (p_task_link_rec.task_link_id IS NULL OR p_task_link_rec.task_link_id=FND_API.G_MISS_NUM) AND p_task_link_rec.dml_operation<>'C'
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_VWP_VISIT_LINK_ID_NULL');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (p_task_link_rec.OBJECT_VERSION_NUMBER IS NULL OR p_task_link_rec.OBJECT_VERSION_NUMBER=FND_API.G_MISS_NUM)  and p_task_link_rec.dml_operation<>'C'
                THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_OBJECT_VERS_NUM_NULL');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;


-- Check for uniq ness of the  Route Sequences

                IF (p_task_link_rec.visit_Task_id IS NOT NULL AND p_task_link_rec.visit_Task_id<>FND_API.G_MISS_NUM
                AND p_task_link_rec.PARENT_TASK_ID IS NOT NULL AND p_task_link_rec.PARENT_TASK_ID<>FND_API.G_MISS_NUM)
                THEN
                      IF G_DEBUG='Y' THEN
						 AHL_DEBUG_PUB.debug(L_FULL_NAME|| 'Enter Validate 02','+VWP_HIERARCHY+');
				      END IF;
         -- Commented by amagrawa based on review comments
                   /*   IF p_task_link_rec.HIERARCHY_INDICATOR='AFTER'
                      THEN
                                OPEN  check_uniq(p_task_link_rec.visit_Task_id,p_task_link_rec.PARENT_TASK_ID);
                      ELSE
                                OPEN  check_uniq(p_task_link_rec.PARENT_TASK_ID,p_task_link_rec.visit_Task_id);
                      END IF;
                      */
                      -- Added by amagrawa based on review comments
                      OPEN  check_uniq(l_parent_task_id ,l_child_task_id);
                      FETCH check_uniq INTO l_counter2;

            	     IF G_DEBUG='Y' THEN
						 AHL_DEBUG_PUB.debug(L_FULL_NAME||'Count Records'||to_char(l_counter2),'+VWP_HIERARCHY+');
					 END IF;

                      IF  l_counter2>0
                      THEN
                          FND_MESSAGE.SET_NAME('AHL','AHL_VWP_TASK_LINK_DUP');
                          FND_MESSAGE.SET_TOKEN('RECORD',p_task_link_rec.visit_Task_number,false);
                          FND_MSG_PUB.ADD;
					      RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      CLOSE check_UNIQ;

                END IF;
        END IF;
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  L_API_NAME,
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                               p_data  => X_msg_data);
 END;


--Tranlate Value to id.

PROCEDURE TRANS_VALUE_ID
 (
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_task_link_rec           IN OUT NOCOPY TASK_LINK_REC
 )
as
CURSOR get_task_info(c_visit_task_id Number,C_PARENT_TASK_NUMBER VARCHAR2)
 IS
SELECT *
   FROM AHL_VISIT_TASKS_VL
   WHERE VISIT_TASK_NUMBER=C_PARENT_TASK_NUMBER
   AND SUMMARY_TASK_FLAG='N'
   AND VISIT_ID = (select visit_id
                   from AHL_VISIT_TASKS_B
                   where VISIT_TASK_ID = c_visit_task_id);

 l_task_det              get_task_info%rowtype;
 BEGIN

        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        IF p_x_task_link_rec.visit_task_number is  null  OR p_x_task_link_rec.visit_task_number=FND_API.G_MISS_CHAR
        THEN
                     FND_MESSAGE.SET_NAME('AHL','AHL_VWP_TASK_NUMBER_NULL');
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;

        ELSE
                 OPEN  get_task_info(p_x_task_link_rec.VISIT_TASK_ID,p_x_task_link_rec.visit_task_number);
                 FETCH get_task_info INTO l_task_det;

                 IF get_task_info%NOTFOUND
                 THEN
                     FND_MESSAGE.SET_NAME('AHL','AHL_VWP_CONTEXT_TSK_INV');
                     FND_MESSAGE.SET_TOKEN('RECORD',p_x_task_link_rec.visit_Task_number,false);
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;
                 ELSE
                             p_x_task_link_rec.parent_task_id:=l_task_det.visit_task_id;
-- Commented by amagrawa based on review comments.
--                             p_x_task_link_rec.visit_task_number:=l_task_det.visit_task_number;
                             p_x_task_link_rec.visit_task_name:=l_task_det.visit_task_name;
                 END IF;
                 CLOSE get_task_info;
        END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  'TRANS_VALUE_ID',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 END;


PROCEDURE  NON_CYCLIC_ENF
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 P_VISIT_TASK_ID             IN NUMBER,
 P_VISIT_TASK_NUMBER         IN VARCHAR2
)
AS
l_cyclic_loop           EXCEPTION;
PRAGMA                  EXCEPTION_INIT(l_cyclic_loop,-1436);
l_counter               NUMBER;
BEGIN
        x_return_status:=FND_API.G_RET_STS_SUCCESS;

        SELECT COUNT(*) INTO l_counter
        FROM  AHL_TASK_LINKS A
        START WITH VISIT_TASK_ID=P_VISIT_TASK_ID
        CONNECT BY PRIOR VISIT_TASK_ID =PARENT_TASK_ID;
EXCEPTION
WHEN l_cyclic_loop  THEN
        FND_MESSAGE.SET_NAME('AHL','AHL_VWP_VISIT_TASK_ID_CYC');
        FND_MESSAGE.SET_TOKEN('RECORD',P_VISIT_TASK_NUMBER ,false);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        => G_PKG_NAME,
                            p_procedure_name  => 'NON_CYCLIC_ENF',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                               p_data  => X_msg_data);
 END;

    -- Post 11.5.10 Changes by Senthil
PROCEDURE Create_Task_Links
(
P_task_link_rec  IN OUT NOCOPY TASK_LINK_REC
)

IS

-- Modified by amagrawa
CURSOR  CHECK_TASK_ID(C_TASK_NUMBER IN NUMBER, C_TASK_ID IN NUMBER)
IS
select VISIT_TASK_ID from AHL_VISIT_TASKS_B where visit_task_number = C_TASK_NUMBER and
visit_id = (select visit_id from ahl_visit_tasks_b where visit_task_id = C_TASK_ID );



l_flip_vtid NUMBER;
l_return_Status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_visit_task_id NUMBER;

BEGIN

   --     Select ahl_task_links_s.nextval into l_task_link_id from dual;
-- Validate the values entered by the user

      IF(P_task_link_rec.visit_task_number is NULL or length(trim(P_task_link_rec.visit_task_number)) = 0 )
      THEN
		FND_MESSAGE.SET_NAME('AHL','AHL_VWP_CONTEXT_TASK_NULL');
		FND_MSG_PUB.ADD;
      ELSE
		OPEN CHECK_TASK_ID(P_task_link_rec.visit_task_number,P_task_link_rec.visit_task_id);
		FETCH CHECK_TASK_ID INTO l_visit_task_id;
		     IF (CHECK_TASK_ID%FOUND) THEN
			   P_task_link_rec.parent_task_id := l_visit_task_id;
			ELSE
			   FND_MESSAGE.SET_NAME('AHL','AHL_VWP_CONTEXT_TSK_INV');
			   FND_MESSAGE.SET_TOKEN('RECORD',P_task_link_rec.visit_task_number,false);
			   FND_MSG_PUB.ADD;
	             END IF;
		     CLOSE Check_Task_ID;
       END IF;



	l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0
        THEN
                RAISE FND_API.G_EXC_ERROR;
	END IF;

-- Validate the Links

	VALIDATE_VWP_LINKS
	 (
	 x_return_status  =>l_return_Status,
	 x_msg_count      =>l_msg_count,
	 x_msg_data       =>l_msg_data,
	 p_task_link_rec  =>P_task_link_rec
	 );

       -- l_msg_count := FND_MSG_PUB.count_msg;
    -- Added by amagrawa based on review comments.
	    IF l_return_Status <>'S'
        THEN
            IF l_return_Status = FND_API.G_RET_STS_ERROR
            THEN
					    RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_Status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
			           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

     	END IF;

        IF P_task_link_rec.HIERARCHY_INDICATOR='AFTER'
        THEN
                      l_flip_vtid:=P_task_link_rec.VISIT_TASK_ID;
                      P_task_link_rec.VISIT_TASK_ID:=P_task_link_rec.PARENT_TASK_ID;
                      P_task_link_rec.PARENT_TASK_ID:=l_flip_vtid;
        END IF;

                      INSERT INTO AHL_TASK_LINKS(
                      TASK_LINK_ID,
                      OBJECT_VERSION_NUMBER,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN,
                      VISIT_TASK_ID,
                      PARENT_TASK_ID,
                      ATTRIBUTE_CATEGORY,
                      ATTRIBUTE1,
                      ATTRIBUTE2,
                      ATTRIBUTE3,
                      ATTRIBUTE4,
                      ATTRIBUTE5,
                      ATTRIBUTE6,
                      ATTRIBUTE7,
                      ATTRIBUTE8,
                      ATTRIBUTE9,
                      ATTRIBUTE10,
                      ATTRIBUTE11,
                      ATTRIBUTE12,
                      ATTRIBUTE13,
                      ATTRIBUTE14,
                      ATTRIBUTE15)
                      values
                      (
                      ahl_task_links_s.nextval,
                      1,
                      sysdate,
                      fnd_global.user_id,
                      sysdate,
                      fnd_global.user_id,
                      fnd_global.user_id,
                      P_task_link_rec.VISIT_TASK_ID,
                      P_task_link_rec.PARENT_TASK_ID,
                      P_task_link_rec.ATTRIBUTE_CATEGORY,
                      P_task_link_rec.ATTRIBUTE1,
                      P_task_link_rec.ATTRIBUTE2,
                      P_task_link_rec.ATTRIBUTE3,
                      P_task_link_rec.ATTRIBUTE4,
                      P_task_link_rec.ATTRIBUTE5,
                      P_task_link_rec.ATTRIBUTE6,
                      P_task_link_rec.ATTRIBUTE7,
                      P_task_link_rec.ATTRIBUTE8,
                      P_task_link_rec.ATTRIBUTE9,
                      P_task_link_rec.ATTRIBUTE10,
                      P_task_link_rec.ATTRIBUTE11,
                      P_task_link_rec.ATTRIBUTE12,
                      P_task_link_rec.ATTRIBUTE13,
                      P_task_link_rec.ATTRIBUTE14,
                      P_task_link_rec.ATTRIBUTE15);


         NON_CYCLIC_ENF
         (
         x_return_status             =>l_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_visit_Task_id              =>P_task_link_rec.visit_Task_id,
         p_visit_Task_number          =>P_task_link_rec.visit_Task_number
         );

 -- Added by amagrawa based on review comments.
	    IF l_return_Status <>'S'
        THEN
            IF l_return_Status = FND_API.G_RET_STS_ERROR
            THEN
					    RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_Status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
			           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

     	END IF;

      -- Added cxcheng POST11510--------------
      --Now adjust the times derivation for the child task
     AHL_VWP_TIMES_PVT.Adjust_Task_Times(p_api_version => 1.0,
                                    p_init_msg_list => Fnd_Api.G_FALSE,
                                    p_commit        => Fnd_Api.G_FALSE,
                                    p_validation_level      => Fnd_Api.G_VALID_LEVEL_FULL,
                                    x_return_status      => l_return_status,
                                    x_msg_count          => l_msg_count,
                                    x_msg_data           => l_msg_data,
                                    p_task_id            => P_task_link_rec.visit_task_id);


     	 -- Added by amagrawa based on review comments.
       IF l_return_Status <>'S'
        THEN
            IF l_return_Status = FND_API.G_RET_STS_ERROR
            THEN
					    RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_Status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
			           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

     	END IF;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0
        THEN
                RAISE FND_API.G_EXC_ERROR;
    	END IF;


END Create_Task_Links;

         -- End of Post 11.5.10 Changes by Senthil

PROCEDURE DELETE_TASK_LINKS
 ( p_task_link_id              IN NUMBER,
   p_object_version_number     IN NUMBER)
as
--
cursor child_task_csr (p_task_link_id IN NUMBER) IS
SELECT  visit_task_id
FROM   ahl_task_links
WHERE  task_link_id = p_task_link_id;
--
l_return_Status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_child_task_id NUMBER;
--
BEGIN
       --Find the child task link
        OPEN child_task_csr(p_task_link_id);
	FETCH child_task_csr INTO l_child_task_id;
	CLOSE child_task_csr;

	DELETE AHL_TASK_LINKS
        WHERE  TASK_LINK_ID=p_task_link_id
	AND OBJECT_VERSION_NUMBER=p_object_version_number;
	IF SQL%ROWCOUNT=0
	THEN
	   FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
	   FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;


    -- Added cxcheng POST11510--------------
    --Now adjust the times derivation for the child task. Parent doesn't matter
     AHL_VWP_TIMES_PVT.Adjust_Task_Times(p_api_version => 1.0,
                                    p_init_msg_list => Fnd_Api.G_FALSE,
                                    p_commit        => Fnd_Api.G_FALSE,
                                    p_validation_level      => Fnd_Api.G_VALID_LEVEL_FULL,
                                    x_return_status      => l_return_status,
                                    x_msg_count          => l_msg_count,
                                    x_msg_data           => l_msg_data,
                                    p_task_id            => l_child_task_id);

      -- Added by amagrawa based on review comments.
       IF l_return_Status <>'S'
        THEN
            IF l_return_Status = FND_API.G_RET_STS_ERROR
            THEN
					    RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_Status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
			           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

     	END IF;

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0
        THEN
                RAISE FND_API.G_EXC_ERROR;
    	END IF;

END DELETE_TASK_LINKS;

PROCEDURE PROCESS_TASK_LINKS
 (
 p_api_version               IN     NUMBER	:= 1.0,
 p_init_msg_list             IN     VARCHAR2	:= FND_API.G_TRUE,
 p_commit                    IN     VARCHAR2	:= FND_API.G_FALSE ,
 p_validation_level          IN     NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
 p_default                   IN     VARCHAR2	:= FND_API.G_FALSE,
 p_module_type               IN     VARCHAR2	:= NULL,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_task_link_tbl           IN OUT NOCOPY TASK_LINK_TBL
 )
as
 -- for finding the status of a task. Added in 11.5.10
 -- amagrawa Modified the cursor declaration based on review comments.
 CURSOR task_status_csr(p_task_id IN NUMBER) IS
 	SELECT STATUS_CODE
 	FROM AHL_VISIT_TASKS_B
 	WHERE VISIT_TASK_ID=p_task_id;
-- 	AND VISIT_TASK_NUMBER= p_task_no ;

 -- Cursor find all details about visit
 CURSOR c_Visit (p_task_id IN NUMBER) IS
      SELECT Any_Task_Chg_Flag,visit_id FROM Ahl_Visits_VL
      WHERE  VISIT_ID = (
      			 SELECT visit_id FROM AHL_VISIT_TASKS_B
      			 WHERE visit_task_id = p_task_id
      			);

 l_visit_csr_rec    c_Visit%ROWTYPE;

 -- Cursor to find visit_task_id from task_link_id
 CURSOR c_task_link (p_task_link_id IN NUMBER) IS
      SELECT visit_task_id FROM AHL_TASK_LINKS
      WHERE task_link_id = p_task_link_id;


 l_api_name     CONSTANT VARCHAR2(30) := 'PROCESS_TASK_LINKS';
 -- Added by amagrawa
 L_FULL_NAME    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_commit                VARCHAR2(1):= FND_API.G_FALSE;
 l_TASK_LINK_tbl         TASK_LINK_TBL:=p_x_task_link_tbl;
 L_TASK_LINK_REC         TASK_LINK_REC;
 l_status_code 		 VARCHAR2(30);
 l_task_id	 	 NUMBER;
 l_counter NUMBER:=0;

   l_planned_order_flag VARCHAR2(1);

   l_visit_end_date DATE;

 BEGIN

       SAVEPOINT PROCESS_TASK_LINKS;

    -- Standard call to check for call compatibility.

       IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
       END IF;


        IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.enable_debug;
    	 END IF;

    -- Debug info.
-- Commented by amagrawa based on review comments
--       IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
          IF G_DEBUG='Y' THEN
	 		 AHL_DEBUG_PUB.debug( L_FULL_NAME||':Enter VWP_HIERARCHY');
    	 END IF;
--       END IF;

    -- AHL_DEBUG_PUB.enable_debug;


    -- Initialize API return status to success

       x_return_status := FND_API.G_RET_STS_SUCCESS;


   --Start of API Body

     if p_x_task_link_tbl.count >0
     then

     FOR i IN  P_X_TASK_LINK_TBL.FIRST.. P_X_TASK_LINK_TBL.LAST
     LOOP

     IF P_X_TASK_LINK_TBL(I).DML_operation<>'D'
     THEN

        l_TASK_LINK_rec.object_version_number   :=l_TASK_LINK_tbl(i).object_version_number;
        l_TASK_LINK_rec.visit_task_id           :=l_TASK_LINK_tbl(i).visit_task_id;
-- Commented by amagrawa based on review comments.
 --       l_TASK_LINK_rec.parent_task_id          :=l_TASK_LINK_tbl(i).parent_task_id;
        l_TASK_LINK_rec.hierarchy_indicator     :=l_TASK_LINK_tbl(i).hierarchy_indicator;
        l_TASK_LINK_rec.visit_task_nUMBER       :=l_TASK_LINK_tbl(i).visit_task_number;
        l_TASK_LINK_rec.visit_task_id           :=l_TASK_LINK_tbl(i).visit_task_id;
        l_TASK_LINK_rec.dml_operation           :=l_TASK_LINK_tbl(i).DML_OPERATION;

         TRANS_VALUE_ID
         (
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         P_X_TASK_LINK_rec           =>   l_TASK_LINK_rec);

         -- Added by amagrawa based on review comments.
	    IF x_return_Status <>'S'
        THEN
            IF x_return_Status = FND_API.G_RET_STS_ERROR
            THEN
					    RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_Status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
			           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
     	END IF;

         l_TASK_LINK_tbl(i).parent_task_id:=l_TASK_LINK_rec.parent_task_id;
         l_TASK_LINK_tbl(i).visit_task_name:=l_TASK_LINK_rec.visit_task_name;
-- Commented by amagrawa based on review comments.
 --        l_TASK_LINK_tbl(i).visit_task_number:=l_TASK_LINK_rec.visit_task_number;
     END IF;

     END LOOP;
     end if;

-- Commented by amagrawa based on review comments.
    /*    l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
        IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.debug( L_FULL_NAME||' After  Translate','+VWP_HIERARCHY+');
	 END IF;

        IF P_X_TASK_LINK_TBL.COUNT >0
        THEN


        DEFAULT_MISSING_ATTRIBS
        (
        p_x_TASK_LINK_TBL             =>L_TASK_LINK_tbl
        );

        END IF;

     -- Calling for Validation

     if p_x_task_link_tbl.count >0
     then
        l_counter:= p_x_task_link_tbl.first;
        l_task_id := p_x_task_link_tbl(l_counter).visit_task_id;

        IF l_task_id IS NULL and (p_x_task_link_tbl(l_counter).DML_OPERATION) = 'D' THEN
         	OPEN c_task_link(p_x_task_link_tbl(l_counter).task_link_id);
         	FETCH c_task_link INTO l_task_id;
         	CLOSE c_task_link;
        END IF;

        IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.debug( L_FULL_NAME||' Task Hierarchy l_task_id -> '||l_task_id);
	END IF;

     FOR i IN  l_TASK_LINK_TBL.FIRST.. l_TASK_LINK_TBL.LAST
     LOOP
       OPEN task_status_csr(l_TASK_LINK_tbl(i).parent_task_id);
       FETCH task_status_csr INTO l_status_code;
       CLOSE task_status_csr;

       IF l_status_code <>'PLANNING' THEN

       	  FND_MESSAGE.SET_NAME('AHL','AHL_VWP_INV_TASK_STATUS');
          FND_MESSAGE.SET_TOKEN('RECORD',l_TASK_LINK_tbl(i).visit_task_number ,false);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

       ELSE
        l_TASK_LINK_rec.object_version_number   :=l_TASK_LINK_tbl(i).object_version_number;
        l_TASK_LINK_rec.visit_task_id           :=l_TASK_LINK_tbl(i).visit_task_id;
        l_TASK_LINK_rec.parent_task_id          :=l_TASK_LINK_tbl(i).parent_task_id;
        l_TASK_LINK_rec.hierarchy_indicator     :=l_TASK_LINK_tbl(i).hierarchy_indicator;
        l_TASK_LINK_rec.visit_task_nUMBER       :=l_TASK_LINK_tbl(i).visit_task_number;
        l_TASK_LINK_rec.visit_task_id           :=l_TASK_LINK_tbl(i).visit_task_id;
        l_TASK_LINK_rec.dml_operation           :=l_TASK_LINK_tbl(i).DML_OPERATION;


--       IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL )
--       THEN
/*        IF l_TASK_LINK_TBL(i).DML_OPERATION<>'D'
       THEN

         VALIDATE_VWP_LINKS
         (
         x_return_status             =>x_return_Status,
         x_msg_count                 =>l_msg_count,
         x_msg_data                  =>l_msg_data,
         p_task_link_rec             =>l_TASK_LINK_rec);

        END IF;
*/



       IF l_TASK_LINK_TBL(i).DML_OPERATION='D'
       THEN

           -- Post 11.5.10 Changes by Senthil
		DELETE_TASK_LINKS
		 (
		 p_task_link_id      => l_task_link_tbl(i).task_link_id,
		 p_object_version_number   => l_task_link_tbl(i).object_version_number
		 );

/*		DELETE AHL_TASK_LINKS WHERE  TASK_LINK_ID=l_task_link_tbl(i).task_link_id
                AND OBJECT_VERSION_NUMBER=l_task_link_tbl(i).OBJECT_VERSION_NUMBER;
                IF SQL%ROWCOUNT=0
                THEN
                   FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                   FND_MSG_PUB.ADD;
                END IF;
                */

             -- End of Post 11.5.10 Changes by Senthil
        ELSIF P_X_TASK_LINK_tbl(i).DML_operation='C'
        THEN
        -- Post 11.5.10 Changes by Senthil
           Create_Task_Links ( p_task_link_rec  =>P_X_TASK_LINK_tbl(i));
         -- End of Post 11.5.10 Changes by Senthil
        END IF;
      END IF;
     END LOOP;


     OPEN C_VISIT(l_task_id);
     fetch c_visit into l_visit_csr_rec;
     IF C_VISIT%FOUND THEN
	    IF p_module_type = 'JSP' and P_X_TASK_LINK_tbl.count > 0 THEN

          l_visit_end_date:= AHL_VWP_TIMES_PVT.get_visit_end_time(l_visit_csr_rec.visit_id);

	  IF l_visit_end_date IS NOT NULL THEN

		AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
		  (p_api_version            => p_api_version,
		   p_init_msg_list          => Fnd_Api.G_FALSE,
		   p_commit                 => Fnd_Api.G_FALSE,
		   p_visit_id               => l_visit_csr_rec.visit_id,
		   p_visit_task_id          => NULL,
		   p_org_id                 => NULL,
		   p_start_date             => NULL,
		   p_operation_flag         => 'U',
		   x_planned_order_flag     => l_planned_order_flag ,
			x_return_status           => l_return_status,
			x_msg_count               => l_msg_count,
			x_msg_data                => l_msg_data);



		IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
			X_msg_count := l_msg_count;
			X_return_status := Fnd_Api.G_RET_STS_ERROR;
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

	     END IF;

	  END IF;

         IF l_visit_csr_rec.Any_Task_Chg_Flag='N'
	     THEN
			 AHL_VWP_RULES_PVT.update_visit_task_flag(
				 p_visit_id         =>l_visit_csr_rec.visit_id,
				 p_flag             =>'Y',
				 x_return_status    =>x_return_status);
	   	  END IF;
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        		CLOSE C_VISIT;
			  	RAISE FND_API.G_EXC_ERROR;
		  END IF;
     END IF;
     CLOSE C_VISIT;

     END IF;
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
           X_msg_count := l_msg_count;
           X_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;


         IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
         END IF;
    -- Debug info

   IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.debug( 'End of Private api  PROCESS_TASK_LINKS','+visit_Task_id+');
	 END IF;

    -- Check if API is called in debug mode. If yes, disable debug.

   IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.disable_debug;
	 END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO PROCESS_TASK_LINKS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO PROCESS_TASK_LINKS;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO PROCESS_TASK_LINKS;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_VWP_TASKS_LINKS_PVT',
                            p_procedure_name  =>  'PROCESS_TASK_LINKS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;

END AHL_VWP_TASKS_LINKS_PVT;

/
