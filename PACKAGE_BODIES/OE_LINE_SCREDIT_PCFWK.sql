--------------------------------------------------------
--  DDL for Package Body OE_LINE_SCREDIT_PCFWK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_SCREDIT_PCFWK" AS
/* $Header: OEXKLSCB.pls 120.0 2005/06/01 00:23:04 appldev noship $ */

-- Globals
-------------------------------------------
 g_application_id     constant number := 660;
 g_entity_id          constant number := 7;
 g_entity_short_name  constant varchar2(15) := 'LINE_SCREDIT';
-------------------------------------------
PROCEDURE Validate_Constraint
 (
    p_constraint_id                in  number
,x_condition_count out nocopy number

,x_valid_condition_group out nocopy number

,x_result out nocopy number

 )
 IS

 --Cursors
 CURSOR C_R
 IS SELECT
       condition_id,
       group_number,
       modifier_flag,
       validation_application_id,
       validation_entity_short_name,
       validation_tmplt_short_name,
       record_set_short_name,
       scope_op,
       validation_pkg,
       validation_proc
 FROM  oe_pc_conditions_v
 WHERE constraint_id = p_constraint_id
 ORDER BY group_number;


 TYPE ConstraintRule_Rec_Type IS RECORD
 (
     condition_id                   number,
     group_number                   number,
     modifier_flag	                varchar2(1),
     validation_application_id      number,
     validation_entity_short_name   varchar2(15),
     validation_tmplt_short_name    varchar2(8),
     record_set_short_name          varchar2(8),
     scope_op	                      varchar2(3),
     validation_pkg	                varchar2(30),
     validation_proc	          varchar2(30)
 );

 l_constraintRuleRec  ConstraintRule_Rec_Type;
 l_dsqlCursor		  integer;
 l_dynamicSqlString	  varchar2(2000);
 l_rule_count	        number;
 l_ConstrainedStatus  number;
 l_dummy              integer;
 i                    number;
 l_tempResult         boolean;
 l_result_01          number;
 l_currGrpNumber      number;
 l_currGrpResult      boolean;
BEGIN

   l_ConstrainedStatus := OE_PC_GLOBALS.NO;
   l_rule_count := 0;
   i := 0;
   l_currGrpNumber := -1;
   l_currGrpResult := FALSE;

   OPEN C_R;
   LOOP  -- validatate constraining conditions
      -- fetch all the validation procedure_names assigned to the constraint and
	    -- build the dynamic sql string
      FETCH C_R into
		  	l_constraintRuleRec.condition_id,
		  	l_constraintRuleRec.group_number,
		  	l_constraintRuleRec.modifier_flag,
		  	l_constraintRuleRec.validation_application_id,
		  	l_constraintRuleRec.validation_entity_short_name,
		  	l_constraintRuleRec.validation_tmplt_short_name,
		  	l_constraintRuleRec.record_set_short_name,
		  	l_constraintRuleRec.scope_op,
		  	l_constraintRuleRec.validation_pkg,
		  	l_constraintRuleRec.validation_proc;

      -- EXIT from loop
      IF (C_R%NOTFOUND) THEN
         IF (l_currGrpNumber <> -1 AND l_currGrpResult = TRUE) THEN
            l_ConstrainedStatus := OE_PC_GLOBALS.YES;
         END IF;
         EXIT;  -- exit the loop
      END IF;

      IF (l_currGrpNumber <> l_constraintRuleRec.group_number) THEN

         -- we are entering the new group of conditions..
         -- groups are ORd together, so if the previous group was evaluated
         -- to TRUE (OE_PC_GLOBALS.YES) then no need to evaluvate this group.
         IF (l_currGrpResult = TRUE) THEN
            l_ConstrainedStatus := OE_PC_GLOBALS.YES;
            EXIT;  -- exit the loop
         END IF;

         -- previous group did not evaluvate to TRUE, so lets pursue this new group
         l_currGrpNumber := l_constraintRuleRec.group_number;
         l_currGrpResult := FALSE;
         i := 0;
      END IF;
      -- we have a got a record, increment the count by 1
      l_rule_count := l_rule_count+1;

      -- pkg.function(p1, p2, ...)
      l_dynamicSqlString := ' begin ';
      l_dynamicSqlString := l_dynamicSqlString || l_constraintRuleRec.validation_pkg ||'.';
      l_dynamicSqlString := l_dynamicSqlString || l_constraintRuleRec.validation_proc;

      -- IN Parameters
      l_dynamicSqlString := l_dynamicSqlString || '( ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_application_id, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_entity_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_validation_entity_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_validation_tmplt_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_record_set_short_name, ';
      l_dynamicSqlString := l_dynamicSqlString || ':t_scope, ';

      -- OUT Parameters
      l_dynamicSqlString := l_dynamicSqlString || ':t_result );';
      l_dynamicSqlString := l_dynamicSqlString || ' end; ';

      -- EXECUTE THE DYNAMIC SQL
	 EXECUTE IMMEDIATE l_dynamicSqlString USING IN g_application_id,
                              IN g_entity_short_name,
                              IN l_constraintRuleRec.validation_entity_short_name,
                              IN l_constraintRuleRec.validation_tmplt_short_name,
                              IN l_constraintRuleRec.record_set_short_name,
                              IN l_constraintRuleRec.scope_op,
                              OUT l_result_01;


      IF (l_result_01 = 0) THEN
         l_tempResult := FALSE;
      ELSE
         l_tempResult := TRUE;
      END IF;
      -- apply the modifier on the result
      if(l_constraintRuleRec.modifier_flag = OE_PC_GLOBALS.YES_FLAG) then
         l_tempResult := NOT(l_tempResult);
      end if;

      IF (i = 0) THEN
         l_currGrpResult := l_tempResult;
      ELSE
         l_currGrpResult := l_currGrpResult AND l_tempResult;
      END IF;

      -- increment the index
      i := i+1;
   END LOOP;  -- end validatate validators
   CLOSE C_R;
   -- did we validate any constraint rules?. if there is none then the
   -- constraint is valid and we will return YES
   IF (l_rule_count = 0) THEN
      x_condition_count := 0;
      x_valid_condition_group := -1;
      x_result    := OE_PC_GLOBALS.YES;
   ELSE
      x_condition_count := l_rule_count;
      x_valid_condition_group := l_currGrpNumber;
      x_result    := l_ConstrainedStatus;
   END IF;
 -------------------------------------------
 EXCEPTION
    WHEN OTHERS THEN
       x_result := OE_PC_GLOBALS.ERROR;
END Validate_Constraint;
-------------------------------------------
-------------------------------------------
FUNCTION Is_Op_Constrained
 (
   p_responsibility_id              in number
   ,p_operation                    in varchar2
   ,p_column_name                  in varchar2 default NULL
   ,p_record                       in OE_AK_LINE_SCREDITS_V%ROWTYPE
   ,p_check_all_cols_constraint    in varchar2 default 'Y'
   ,p_is_caller_defaulting         in varchar2 default 'N'
,x_constraint_id out nocopy number

,x_constraining_conditions_grp out nocopy number

,x_on_operation_action out nocopy number

 )
 RETURN NUMBER

 IS

 --Cursors
 -------------------------------------------
    CURSOR C_C
    IS
    SELECT DISTINCT
      c.constraint_id, c.entity_id
      ,c.on_operation_action
     FROM  oe_pc_constraints c,
           oe_pc_assignments a
     WHERE (a.responsibility_id = p_responsibility_id OR a.responsibility_id IS NULL)
     AND   a.constraint_id = c.constraint_id
     AND   c.entity_id     = G_ENTITY_ID
     AND   c.constrained_operation = p_operation
     -- if caller is defaulting then DO NOT CHECK those constraints
     -- that have honored_by_def_flag = 'N'
     AND   decode(honored_by_def_flag,'N',decode(p_is_caller_defaulting,'Y','N','Y'),
                nvl(honored_by_def_flag,'Y')) = 'Y'
     AND   decode(c.column_name, '',decode(p_check_all_cols_constraint,'Y',
             nvl(p_column_name,'#NULL'),'#NULL'),c.column_name) = nvl(p_column_name,'#NULL')
     AND   NOT EXISTS (
            SELECT 'EXISTS'
            FROM OE_PC_EXCLUSIONS e
            WHERE e.responsibility_id = p_responsibility_id
            AND   e.assignment_id     = a.assignment_id
            );
-- Cursor to select all update constraints that are applicable to insert
-- operations as well.
    CURSOR C_CREATE_OP
    IS
    SELECT DISTINCT
      c.constraint_id, c.entity_id
      ,c.on_operation_action
     FROM  oe_pc_constraints c,
           oe_pc_assignments a
     WHERE (a.responsibility_id = p_responsibility_id OR a.responsibility_id IS NULL)
     AND   a.constraint_id = c.constraint_id
     AND   c.entity_id     = G_ENTITY_ID
     AND ( ( c.constrained_operation = OE_PC_GLOBALS.CREATE_OP
             AND p_column_name IS NULL )
           OR ( c.constrained_operation = OE_PC_GLOBALS.UPDATE_OP
               AND   c.check_on_insert_flag = 'Y'
               AND   nvl(c.column_name, '#NULL') = NVL(p_column_name,'#NULL') )
         )
     -- if caller is defaulting then DO NOT CHECK those constraints
     -- that have honored_by_def_flag = 'N'
     AND   decode(honored_by_def_flag,'N',decode(p_is_caller_defaulting,'Y','N','Y'),
                nvl(honored_by_def_flag,'Y')) = 'Y'
     AND   NOT EXISTS (
            SELECT 'EXISTS'
            FROM OE_PC_EXCLUSIONS e
            WHERE e.responsibility_id = p_responsibility_id
            AND   e.assignment_id     = a.assignment_id
            );

 --Local Variables
 -------------------------------------------
    l_validation_result   	number;
    l_condition_count     	number;
    l_valid_condition_group   	number;
 BEGIN

    g_record   := p_record;
    l_validation_result   := OE_PC_GLOBALS.NO;

  IF p_operation = OE_PC_GLOBALS.CREATE_OP THEN

    FOR c_rec in C_CREATE_OP LOOP
        Validate_Constraint (
              p_constraint_id           => c_rec.constraint_id
              ,x_condition_count       => l_condition_count
              ,x_valid_condition_group => l_valid_condition_group
              ,x_result                => l_validation_result
              );
       IF (l_condition_count = 0
                OR l_validation_result = OE_PC_GLOBALS.YES) then
          x_constraint_id           := c_rec.constraint_id;
          x_on_operation_action     := c_rec.on_operation_action;
          x_constraining_conditions_grp   := l_valid_condition_group;
                EXIT;
       END IF;
    END LOOP;

  ELSE

    FOR c_rec in C_C LOOP
        Validate_Constraint (
              p_constraint_id           => c_rec.constraint_id
              ,x_condition_count       => l_condition_count
              ,x_valid_condition_group => l_valid_condition_group
              ,x_result                => l_validation_result
              );
       IF (l_condition_count = 0
                OR l_validation_result = OE_PC_GLOBALS.YES) then
          x_constraint_id           := c_rec.constraint_id;
          x_on_operation_action     := c_rec.on_operation_action;
          x_constraining_conditions_grp   := l_valid_condition_group;
          EXIT;
       END IF;
    END LOOP;

  END IF;

    return l_validation_result;

 EXCEPTION
    WHEN OTHERS THEN
       RETURN OE_PC_GLOBALS.ERROR;
END Is_Op_Constrained;

-------------------------------------------
END OE_LINE_SCREDIT_PCFWK;

/
