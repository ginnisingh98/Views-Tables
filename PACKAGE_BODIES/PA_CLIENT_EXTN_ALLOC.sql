--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_ALLOC" AS
/* $Header: PAPALCCB.pls 120.2 2005/08/09 16:23:55 dlanka noship $ */


/*Example of source_extn

PROCEDURE source_extn(p_alloc_rule_id   IN NUMBER
                      ,x_source_proj_task_tbl  OUT NOCOPY  ALLOC_SOURCE_TABTYPE
                      ,x_status OUT  NOCOPY NUMBER
                      ,x_error_message  OUT NOCOPY  VARCHAR2     )
IS
BEGIN
 If p_alloc_rule_id = 782 then
   x_source_proj_task_tbl(1).project_id:=1718;
   x_source_proj_task_tbl(1).task_id:=2791;
   x_status:=0;
 END IF;
EXCEPTION
  WHEN OTHERS THEN
	x_status := 1;
        x_error_message :='Your error message';
END source_extn;*/

PROCEDURE source_extn(p_alloc_rule_id   IN NUMBER
                      ,x_source_proj_task_tbl  OUT  NOCOPY ALLOC_SOURCE_TABTYPE
                      ,x_status OUT NOCOPY  NUMBER
                      ,x_error_message  OUT  NOCOPY VARCHAR2)
IS
-- Declare your local variables here.
BEGIN
 -- Initialize output parameters.
 -- Define your business rules.
 -- Attention:The index for the x_source_proj_task_tbl should be numbered
 -- sequentially starting from 1. The process will fail if it is not numbered sequentially.
x_status:=0;

EXCEPTION
  WHEN OTHERS THEN
    -- Define your exception handler here.
    -- To raise an ORACLE error, assign SQLCODE to x_status.
    -- To raise an application error, assign a positive number to x_status.
    -- You can define your own error message and assign it to x_error_message.
      null;
END source_extn;


/* Example of offset_extn
PROCEDURE offset_extn( p_alloc_rule_id IN NUMBER
                     , p_offset_amount IN NUMBER
                     , x_offset_proj_task_tbl OUT NOCOPY  ALLOC_OFFSET_TABTYPE
                     , x_status OUT  NOCOPY NUMBER
                     , x_error_message  OUT  NOCOPY VARCHAR2  )
IS
BEGIN
IF p_alloc_rule_id = 782 THEN
   x_offset_proj_task_tbl(1).project_id:=1725;
   x_offset_proj_task_tbl(1).task_id:=2819;
   x_offset_proj_task_tbl(1).offset_amount:=-100;
   x_offset_proj_task_tbl(2).project_id:=1725;
   x_offset_proj_task_tbl(2).task_id:=2820;
   x_offset_proj_task_tbl(2).offset_amount:=-100;
   x_offset_proj_task_tbl(3).project_id:=1725;
   x_offset_proj_task_tbl(3).task_id:=2821;
   x_offset_proj_task_tbl(3).offset_amount:=-100;
   x_offset_proj_task_tbl(4).project_id:=1725;
   x_offset_proj_task_tbl(4).task_id:=2822;
   x_offset_proj_task_tbl(4).offset_amount:=p_offset_amount+100+100+100;
END IF;
x_status:=0;
EXCEPTION
  WHEN OTHERS THEN
   x_status:=1;
   x_error_message :='Your error message';
END offset_extn; */

PROCEDURE offset_extn( p_alloc_rule_id IN NUMBER
                     , p_offset_amount IN NUMBER
                     , x_offset_proj_task_tbl OUT  NOCOPY ALLOC_OFFSET_TABTYPE
                     , x_status OUT  NOCOPY NUMBER
                     , x_error_message  OUT  NOCOPY VARCHAR2)
IS
 -- Declare your local variables here.
BEGIN
 -- Initialize output parameters.
 -- Define your business rules.
 -- Attention:The index for the x_offset_proj_task_tbl should be numbered
 -- sequentially starting from 1. The process will fail if it is not numbered sequentially.
 x_status:=0;

EXCEPTION
  WHEN OTHERS THEN
    -- Define your exception handler here.
    -- To raise an ORACLE error, assign SQLCODE to x_status.
    -- To raise an application error, assign a positive number to x_status.
    -- You can define your own error message and assign it to x_error_message.
	null;
END offset_extn;


/* Example of offset_task_extn
PROCEDURE offset_task_extn( p_alloc_rule_id     IN  NUMBER
                          , p_offset_project_id IN  NUMBER
                          , x_offset_task_id    OUT  NOCOPY NUMBER
                          , x_status            OUT  NOCOPY NUMBER
                          , x_error_message     OUT  NOCOPY VARCHAR2  ) IS
BEGIN
If p_alloc_rule_id = 782 then
  If  p_offset_project_id=1718 then
     x_offset_task_id :=2816;
  End if;
  If p_offset_project_id=1726 then
     x_offset_task_id :=2823;
  end if;
end if;
x_status:=0;

EXCEPTION
  WHEN OTHERS THEN
	x_status :=1;
        x_error_message :='Your error message';
END offset_task_extn; */

PROCEDURE offset_task_extn( p_alloc_rule_id     IN  NUMBER
                          , p_offset_project_id IN  NUMBER
                          , x_offset_task_id    OUT  NOCOPY NUMBER
			  , x_status            OUT  NOCOPY NUMBER
	                  , x_error_message     OUT  NOCOPY VARCHAR2 )
IS
 -- Declare your local variables here.
BEGIN
   -- Initialize output parameters.
   -- Define your business rules.
   x_status:=0;
EXCEPTION
  WHEN OTHERS THEN
  -- Define your exception handler here.
  -- To raise an ORACLE error, assign SQLCODE to x_status.
  -- To raise an application error, assign a positive number to x_status.
  -- You can define your own error message and assign it to x_error_message.
	null;
END offset_task_extn;

/*Example of target_extn
PROCEDURE target_extn(p_alloc_rule_id        IN NUMBER
                      ,x_target_proj_task_tbl OUT  NOCOPY ALLOC_TARGET_TABTYPE
                      ,x_status            OUT  NOCOPY NUMBER
                      ,x_error_message    OUT  NOCOPY VARCHAR2  )
IS
BEGIN
If p_alloc_rule_id=782 then
   x_target_proj_task_tbl(1).project_id:=1728;
   x_target_proj_task_tbl(1).percent:=40;
   x_target_proj_task_tbl(2).project_id:=1726;
   x_target_proj_task_tbl(2).percent:=60;
   x_target_proj_task_tbl(3).project_id:=1726;
   x_target_proj_task_tbl(3).task_id:=2823;
   x_target_proj_task_tbl(3).exclude_flag:='Y';
end if;
   x_status:=0;
EXCEPTION
  WHEN OTHERS THEN
	x_status :=1;
        x_error_message :='Your error message';
END target_extn;*/

PROCEDURE target_extn(p_alloc_rule_id        IN NUMBER
                      ,x_target_proj_task_tbl OUT  NOCOPY ALLOC_TARGET_TABTYPE
                      ,x_status            OUT  NOCOPY NUMBER
                      ,x_error_message    OUT  NOCOPY VARCHAR2  )
IS
 -- Declare your local variables here.
BEGIN
 -- Initialize output parameters.
 -- Define your business rules.
  -- Attention:The index for the x_target_proj_task_tbl should be numbered
 -- sequentially starting from 1. The process will fail if it is not numbered sequentially.

 x_status:=0;

EXCEPTION
  WHEN OTHERS THEN
  -- Define your exception handler here.
  -- To raise an ORACLE error, assign SQLCODE to x_status.
  -- To raise an application error, assign a positive number to x_status.
  -- You can define your own error message and assign it to x_error_message.
  null;
END target_extn;

/*Example of basis_extn
PROCEDURE basis_extn(p_alloc_rule_id   IN  NUMBER
                    , p_project_id     IN  NUMBER
                    , p_task_id        IN  NUMBER
                    , x_basis_amount   OUT  NOCOPY NUMBER
                    , x_status         OUT  NOCOPY NUMBER
                    , x_error_message    OUT  NOCOPY VARCHAR2  ) IS
BEGIN
if p_alloc_rule_id=782 then
  if p_project_id=1726 and p_task_id=2823 then
     x_basis_amount:=10;
  end if;
  if p_project_id=1726 and p_task_id=2824 then
     x_basis_amount:=20;
  end if;
  if p_project_id=1726 and p_task_id=2825 then
     x_basis_amount:=30;
  end if;
  if p_project_id=1728 and p_task_id=2831 then
     x_basis_amount:=10;
  end if;
  if p_project_id=1728 and p_task_id=2834 then
     x_basis_amount:=20;
  end if;
end if;
x_status:=0;
EXCEPTION
  WHEN OTHERS THEN
	x_status :=1;
        x_error_message :='Your error message';
END basis_extn;*/

PROCEDURE basis_extn(p_alloc_rule_id   IN  NUMBER
                    , p_project_id     IN  NUMBER
                    , p_task_id        IN  NUMBER
                    , x_basis_amount   OUT  NOCOPY NUMBER
                    , x_status         OUT NOCOPY  NUMBER
                    , x_error_message    OUT  NOCOPY VARCHAR2  )
IS
    -- Declare your local variables here.
BEGIN
  -- Initialize output parameters.
  -- Define your business rules.
   x_status:=0;
EXCEPTION
  WHEN OTHERS THEN
  -- Define your exception handler here.
  -- To raise an ORACLE error, assign SQLCODE to x_status.
  -- To raise an application error, assign a positive number to x_status.
  -- You can define your own error message and assign it to x_error_message.
	null;
END basis_extn;

/*Example of  txn_dff_extn

PROCEDURE txn_dff_extn( p_alloc_rule_id    IN NUMBER
                       ,p_run_id           IN NUMBER
                       ,p_txn_type         IN VARCHAR2
                       ,p_project_id       IN VARCHAR2
                       ,P_task_id          IN VARCHAR2
                       ,p_expnd_org        IN VARCHAR2
                       ,p_expnd_type_class IN VARCHAR2
                       ,p_expnd_type       IN VARCHAR2
                       ,x_attribute_category OUT  NOCOPY VARCHAR2
                       ,x_attribute1         OUT  NOCOPY VARCHAR2
                       ,x_attribute2         OUT  NOCOPY VARCHAR2
                       ,x_attribute3         OUT  NOCOPY VARCHAR2
                       ,x_attribute4         OUT  NOCOPY VARCHAR2
                       ,x_attribute5         OUT  NOCOPY VARCHAR2
                       ,x_attribute6         OUT  NOCOPY VARCHAR2
                       ,x_attribute7         OUT  NOCOPY VARCHAR2
                       ,x_attribute8         OUT  NOCOPY VARCHAR2
                       ,x_attribute9         OUT  NOCOPY VARCHAR2
                       ,x_attribute10        OUT  NOCOPY VARCHAR2
                       ,x_status             OUT  NOCOPY NUMBER
                       ,x_error_message     OUT  NOCOPY VARCHAR2)
IS
BEGIN
IF p_alloc_rule_id =241
  and p_txn_type ='T'
  and p_expnd_org='Consulting'
  and p_expnd_type_class='PJ'
  and p_expnd_type ='Allocation'
  and p_project_id:=1008  THEN
  x_attribute_category:='test_txn_dff';
  x_attribute1  :='ATTR01';
end if;
x_status:=0;
--NULL;
EXCEPTION
  WHEN OTHERS THEN
  x_status :=1;
  x_error_message :='Your error message';

END txn_dff_extn ;*/

PROCEDURE txn_dff_extn( p_alloc_rule_id    IN NUMBER
                       ,p_run_id           IN NUMBER
                       ,p_txn_type         IN VARCHAR2
                       ,p_project_id       IN VARCHAR2
                       ,P_task_id          IN VARCHAR2
                       ,p_expnd_org        IN VARCHAR2
                       ,p_expnd_type_class IN VARCHAR2
                       ,p_expnd_type       IN VARCHAR2
                       ,x_attribute_category OUT  NOCOPY VARCHAR2
                       ,x_attribute1         OUT  NOCOPY VARCHAR2
                       ,x_attribute2         OUT  NOCOPY VARCHAR2
                       ,x_attribute3         OUT  NOCOPY VARCHAR2
                       ,x_attribute4         OUT  NOCOPY VARCHAR2
                       ,x_attribute5         OUT  NOCOPY VARCHAR2
                       ,x_attribute6         OUT  NOCOPY VARCHAR2
                       ,x_attribute7         OUT  NOCOPY VARCHAR2
                       ,x_attribute8         OUT  NOCOPY VARCHAR2
                       ,x_attribute9         OUT  NOCOPY VARCHAR2
                       ,x_attribute10        OUT  NOCOPY VARCHAR2
                       ,x_status             OUT  NOCOPY NUMBER
                       ,x_error_message     OUT  NOCOPY VARCHAR2)
IS
 -- Declare your local variables here.
BEGIN
 -- Initialize output parameters.
 -- Define your business rules.
 x_status:=0;
EXCEPTION
  WHEN OTHERS THEN
     -- Define your exception handler here.
     -- To raise an ORACLE error, assign SQLCODE to x_status.
     -- To raise an application error, assign a positive number to x_status.
     -- You can define your own error message and assign it to x_error_message.
	null;
END txn_dff_extn ;



/* Example of check_dependency
PROCEDURE check_dependency(p_alloc_rule_id IN NUMBER
                          , x_status       OUT  NOCOPY NUMBER
                          , x_error_message  OUT  NOCOPY VARCHAR2
                          )
IS
 Cursor check_dependency IS
             Select 'X'
               From Dual
              Where Exists
                    ( Select run_id
                        From pa_alloc_runs
                       Where rule_id=p_alloc_rule_id
                         And run_period='MAR-97'
                         And run_status='RS' ) ;
 X_check    Varchar2(1);

BEGIN
  Open check_dependency;
  Fetch check_dependency Into X_Check ;
  If check_dependency%Found Then
     x_status:=0;
     close check_dependency;
  Else
     close check_dependency;
     Raise No_Data_Found;
  End If;

EXCEPTION
  WHEN  No_Data_Found THEN
    x_status:=100;
    x_error_message:='Can't generate allocation transaction because the depended run hasn't been completed';
    return;
  WHEN OTHERS THEN
      X_Status := SQLCODE ;
      return;
END check_dependency ;*/

PROCEDURE check_dependency(p_alloc_rule_id IN NUMBER
                          , x_status       OUT  NOCOPY NUMBER
                          , x_error_message  OUT  NOCOPY VARCHAR2
                          )
IS
  -- Declare your local variables here.
BEGIN
 -- Initialize output parameters.
 -- Define your business rules.
 x_status:=0;

EXCEPTION
   WHEN OTHERS THEN
     -- Define your exception handler here.
     -- To raise an ORACLE error, assign SQLCODE to x_status.
     -- To raise an application error, assign a positive number to x_status.
     -- You can define your own error message and assign it to x_error_message.
     NULL ;
END check_dependency ;

END PA_CLIENT_EXTN_ALLOC;

/
