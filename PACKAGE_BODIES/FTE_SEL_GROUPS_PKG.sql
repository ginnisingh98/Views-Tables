--------------------------------------------------------
--  DDL for Package Body FTE_SEL_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_SEL_GROUPS_PKG" AS
/* $Header: FTESELGB.pls 120.4 2005/08/18 12:09:12 parkhj noship $ */

  TYPE rule_rest_rec IS RECORD (
      rule_attribute_id NUMBER,
      rule_id NUMBER,
      attribute_name VARCHAR2(30),
      attribute_value_from VARCHAR2(240),
      attribute_value_to VARCHAR2(240),
      attribute_value_from_number NUMBER,
      attribute_value_to_number NUMBER,
      data_type VARCHAR2(1));

  TYPE rule_rest_tab IS TABLE OF rule_rest_rec INDEX BY BINARY_INTEGER;

  TYPE rule_rec IS RECORD (
      rule_id NUMBER,
      rest_start NUMBER,
      rest_end NUMBER);

  TYPE rule_tab IS TABLE OF rule_rec INDEX BY BINARY_INTEGER;

  /*------------------------------------------------------------------------
   * Found_Date_Overlap
   * - Check whether the group's start/end date overlaps with
   *   other groups assigned to the assignee
   *------------------------------------------------------------------------*/

  FUNCTION Found_Date_Overlap(p_group_id       IN  NUMBER,
                              p_start_date     IN  DATE,
                              p_end_date       IN  DATE,
                              p_assignee_type  IN  VARCHAR2,
                              p_assignee_id    IN  NUMBER) RETURN BOOLEAN IS

  CURSOR c_assign IS
  SELECT start_date, end_date
  FROM   fte_sel_group_assignments ga,
	 fte_sel_groups gr
  WHERE  gr.group_id = ga.group_id AND
	 gr.group_id <> p_group_id AND
	 ga.customer_id = p_assignee_id AND
         p_assignee_type = 'CUST'
  UNION ALL
  SELECT start_date, end_date
  FROM   fte_sel_group_assignments ga,
	 fte_sel_groups gr
  WHERE  gr.group_id = ga.group_id AND
	 gr.group_id <> p_group_id AND
	 ga.customer_site_id = p_assignee_id AND
         p_assignee_type = 'CUST_SITE'
  UNION ALL
  SELECT start_date, end_date
  FROM   fte_sel_group_assignments ga,
	 fte_sel_groups gr
  WHERE  gr.group_id = ga.group_id AND
	 gr.group_id <> p_group_id AND
	 ga.organization_id = p_assignee_id AND
	 p_assignee_type = 'ORG'
  UNION ALL
  SELECT start_date, end_date
  FROM   fte_sel_group_assignments ga,
	 fte_sel_groups gr
  WHERE  gr.group_id = ga.group_id AND
	 gr.group_id <> p_group_id AND
	 ga.organization_id is null AND
         ga.customer_id is null AND
         ga.customer_site_id is null AND
	 p_assignee_type = 'ENT';

  BEGIN
    FOR r_assign IN c_assign LOOP

      if (NOT((p_end_date is not null and r_assign.start_date is not null and
               p_end_date < r_assign.start_date) OR
              (p_start_date is not null and r_assign.end_date is not null and
               p_start_date > r_assign.end_date)))
      then
        return TRUE;
      end if;
    END LOOP;

    return false;
  END Found_Date_Overlap;

  /*------------------------------------------------------------------------
   * Validate_Shipmethod
   * - check whether the shipmethod is valid
   *------------------------------------------------------------------------*/

  PROCEDURE Validate_Shipmethod(
		  p_carrier_id          IN          NUMBER,
		  p_service_level       IN          VARCHAR2,
                  p_mode                IN          VARCHAR2,
	          x_return_status       OUT NOCOPY  VARCHAR2,
	          x_msg_data            OUT NOCOPY  VARCHAR2) IS

  CURSOR c_shipmethod IS
  SELECT carrier_id
  FROM   wsh_carrier_services
  WHERE  carrier_id = p_carrier_id AND
         service_level = p_service_level AND
         mode_of_transport = p_mode;

  l_carrier_id NUMBER;

  BEGIN

    x_return_status := 'S';
    x_msg_data := '';

    OPEN c_shipmethod;
    FETCH c_shipmethod INTO l_carrier_id;
    CLOSE c_shipmethod;

    IF (l_carrier_id IS NULL) THEN
      x_return_status := 'E';
      x_msg_data := 'FTE_SEL_INVALID_SHIPMETHOD';
    END IF;

  EXCEPTION
    when others then
      x_return_status := 'E';
      x_msg_data := 'Error in Delete_Results';


  END Validate_Shipmethod;

  /*------------------------------------------------------------------------
   * Validate_Group
   * - check whether the group is valid
   *   1) unique Name
   *   2) End date should be greater than or equal to Start date
   *   3) Start/End date should not overlap with previously assigned groups
   *------------------------------------------------------------------------*/

  PROCEDURE Validate_Group(
		  p_group_id            IN          NUMBER,
		  p_name                IN          VARCHAR2,
                  p_start_date          IN          DATE,
                  p_end_date            IN          DATE,
                  p_assignee_type       IN          VARCHAR2,
                  p_assignee_id         IN          NUMBER,
                  p_mode                IN          VARCHAR2,
	          x_return_status       OUT NOCOPY  VARCHAR2,
	          x_msg_count           OUT NOCOPY  NUMBER,
	          x_msg_data            OUT NOCOPY  VARCHAR2) IS

  CURSOR c_unique_name IS
  SELECT name
  FROM   fte_sel_groups
  WHERE  name = p_name AND
	 group_id <> p_group_id;

  CURSOR c_assignee IS
  SELECT organization_id, customer_id, customer_site_id
  FROM   fte_sel_group_assignments
  WHERE  group_id = p_group_id;

  l_name          VARCHAR2(30);
  l_overlap       BOOLEAN;
  l_assignee_type VARCHAR2(10);
  l_assignee_id   NUMBER;

  BEGIN

    x_return_status := 'S';
    x_msg_count := 0;

    OPEN c_unique_name;
    FETCH c_unique_name INTO l_name;
    CLOSE c_unique_name;

    IF (l_name IS NOT NULL) THEN
      x_return_status := 'E';
      x_msg_count := x_msg_count + 1;
      x_msg_data := x_msg_data || '|FTE_SEL_INVALID_GROUP_NAME';
    END IF;

    if (p_start_date is not null and p_end_date is not null and
        p_start_date > p_end_date)
    then
      x_return_status := 'E';
      x_msg_count := x_msg_count + 1;
      x_msg_data := x_msg_data || '|FTE_COMP_DATE_ERROR';
    end if;

    if (p_mode <> 'UPDATE')
    then
      l_overlap := found_date_overlap(p_group_id => p_group_id,
                                    p_start_date => p_start_date,
                                    p_end_date => p_end_date,
                                    p_assignee_type => p_assignee_type,
                                    p_assignee_id => p_assignee_id);

      if (l_overlap)
      then
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        x_msg_data := x_msg_data || '|FTE_SEL_GRP_OVERLAP';
      end if;
    else -- p_mode = 'UPDATE'
      /* CREATE/COPY has only one asignee
         but UPDATE might have more than the current assignee
         or might not be assigned at all through Search By Rule - Update
         get all the assignees that this group is assigned to
         for each assignee, validate whether the Start/End date overlaps
       */
      FOR r_assignee IN c_assignee LOOP
        IF (r_assignee.customer_id is not null) then
          l_assignee_type := 'CUST';
          l_assignee_id := r_assignee.customer_id;
        ELSIF (r_assignee.customer_site_id is not null) then
          l_assignee_type := 'CUST_SITE';
          l_assignee_id := r_assignee.customer_site_id;
        ELSIF (r_assignee.organization_id is not null) then
          l_assignee_type := 'ORG';
          l_assignee_id := r_assignee.organization_id;
        ELSE
          l_assignee_type := 'ENT';
          l_assignee_id := null;
        END IF;

        l_overlap := found_date_overlap(p_group_id => p_group_id,
                                    p_start_date => p_start_date,
                                    p_end_date => p_end_date,
                                    p_assignee_type => l_assignee_type,
                                    p_assignee_id => l_assignee_id);

        if (l_overlap)
        then
          x_return_status := 'E';
          x_msg_count := x_msg_count + 1;
          if (p_assignee_id is null OR p_assignee_id = l_assignee_id) then
            x_msg_data := x_msg_data || '|FTE_SEL_GRP_OVERLAP';
          elsif (p_assignee_id is not null) then
            x_msg_data := x_msg_data || '|FTE_SEL_GRP_OVERLAP_OTHER_A';
          end if;
          EXIT;
        end if;

      END LOOP;

    end if;

  END Validate_Group;

  /*------------------------------------------------------------------------
   * Validate_Assignment
   * - check whether p_group_name is assignable to the given eitity
   *   1) start/end dates : currently active or future active
   *   2) Customer site : not assigned to Organization/Enterprise or itself
   *      Customer : not assigned to Organization/Enterprise or itself
   *      Organization : not assigned to Customer/Customer Site or itself
   *      Enterprise : not assigned to Customer/Customer Site or itself
   *   3) should not overlap with any existing rule
   *------------------------------------------------------------------------*/

  PROCEDURE Validate_Assignment(
                            p_group_name     IN          VARCHAR2,
                            p_assignee_type  IN          VARCHAR2,
                            p_assignee_id    IN          NUMBER,
                            x_group_id       OUT NOCOPY  NUMBER,
                            x_return_status  OUT NOCOPY  VARCHAR2,
                            x_msg_count      OUT NOCOPY  NUMBER,
                            x_msg_data       OUT NOCOPY  VARCHAR2) IS

  CURSOR c_valid_assign IS
  SELECT group_id, start_date, end_date
    FROM fte_sel_groups
   WHERE name = p_group_name and
         object_id = 1 and
         nvl(end_date, sysdate) >= sysdate and
         p_assignee_type = 'CUST' and
         group_id NOT IN (select group_id from fte_sel_group_assignments
                           where customer_id = p_assignee_id or -- already
                                 organization_id is not null or -- ORG
                                 organization_id is null and    -- ENT
                                 customer_id is null and
                                 customer_site_id is null)
  UNION ALL
  SELECT group_id, start_date, end_date
    FROM fte_sel_groups
   WHERE name = p_group_name and
         object_id = 1 and
         nvl(end_date, sysdate) >= sysdate and
         p_assignee_type = 'CUST_SITE' and
         group_id NOT IN (select group_id from fte_sel_group_assignments
                           where customer_site_id = p_assignee_id or -- already
                                 organization_id is not null or      -- ORG
                                 organization_id is null and         -- ENT
                                 customer_id is null and
                                 customer_site_id is null)
  UNION ALL
  SELECT group_id, start_date, end_date
    FROM fte_sel_groups
   WHERE name = p_group_name and
         object_id = 1 and
         nvl(end_date, sysdate) >= sysdate and
         p_assignee_type = 'ORG' and
         group_id NOT IN (select group_id from fte_sel_group_assignments
                           where organization_id = p_assignee_id or -- already
                                 customer_id is not null or         -- CUST
                                 customer_site_id is not null)      -- CUST_SITE
  UNION ALL
  SELECT group_id, start_date, end_date
    FROM fte_sel_groups
   WHERE name = p_group_name and
         object_id = 1 and
         nvl(end_date, sysdate) >= sysdate and
         p_assignee_type = 'ENT' and
         group_id NOT IN (select group_id from fte_sel_group_assignments
                           where customer_id is not null or        -- CUST
                                 customer_site_id is not null or   -- CUST_SITE
                                 organization_id is null and       -- already
                                 customer_id is null and
                                 customer_site_id is null);
  l_overlap    BOOLEAN;
  l_group_id   NUMBER;
  l_start_date DATE;
  l_end_date   DATE;

  BEGIN
    OPEN c_valid_assign;
    FETCH c_valid_assign INTO l_group_id, l_start_date, l_end_date;
    CLOSE c_valid_assign;

    if (l_group_id is not null)
    then
      l_overlap := found_date_overlap(p_group_id      => l_group_id,
                                      p_start_date    => l_start_date,
                                      p_end_date      => l_end_date,
                                      p_assignee_type => p_assignee_type,
                                      p_assignee_id   => p_assignee_id);

      if (l_overlap)
      then
        x_return_status := 'E';
        x_msg_count := x_msg_count + 1;
        x_msg_data := 'FTE_SEL_ASSGN_GRP_OVERLAP';
      else
        x_return_status := 'S';
        x_group_id := l_group_id;
      end if;

    else
      x_return_status := 'E';
      x_msg_count := 1;
      x_msg_data := 'FTE_SEL_SR_ASSGN_SEL_INV_NAME';
    end if;

  END Validate_Assignment;

  /*------------------------------------------------------------------------
   * Delete_Results
   *   1) Delete data from FTE_SEL_RESULTS
   *------------------------------------------------------------------------*/

  PROCEDURE Delete_Results( p_group_id       IN          NUMBER,
                            x_return_status  OUT NOCOPY  VARCHAR2,
                            x_msg_count      OUT NOCOPY  NUMBER,
                            x_msg_data       OUT NOCOPY  VARCHAR2) IS

  BEGIN

    DELETE FROM FTE_SEL_RESULTS
     WHERE result_id in (select result_id
                           from fte_sel_rules r, fte_sel_result_assignments ra
                          where r.rule_id = ra.rule_id
                            and r.group_id = p_group_id);

    x_return_status := 'S';

  EXCEPTION
    when others then
      x_return_status := 'E';
      x_msg_data := 'Error in Delete_Results';

  END Delete_Results;

  /*------------------------------------------------------------------------
   * Save_Results
   *   1) Insert data into FTE_SEL_RESULTS
   *      based on what are in FTE_SEL_RESULT_ASSIGNMENTS
   *   2) Call FTE_ACS_RULE_UTIL_PKG.SET_RANGE_OVERLAP_FLAG
   *      to set the range_overlap_flag of each rule attribute
   *------------------------------------------------------------------------*/

  PROCEDURE Save_Results(   p_group_id       IN          NUMBER,
                            x_return_status  OUT NOCOPY  VARCHAR2,
                            x_msg_count      OUT NOCOPY  NUMBER,
                            x_msg_data       OUT NOCOPY  VARCHAR2) IS

  BEGIN

    INSERT INTO FTE_SEL_RESULTS(RESULT_ID, NAME, CREATION_DATE,
                                CREATED_BY, LAST_UPDATE_DATE,
                                LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
           SELECT result_id, to_char(result_id), sysdate,
                  -1, sysdate, -1, -1
             from fte_sel_rules r, fte_sel_result_assignments ra
            where r.rule_id = ra.rule_id
              and r.group_id = p_group_id;

    FTE_ACS_RULE_UTIL_PKG.SET_RANGE_OVERLAP_FLAG(p_group_id);

    x_return_status := 'S';

  EXCEPTION
    when others then
      x_return_status := 'E';
      x_msg_data := 'Error in Save_Results';

  END Save_Results;


  --
  -- Procedure: Copy Group
  --
  -- Purpose:   Copies group and all associated children
  --
  --
  -- CHANGE RECORD:
  -- --------------
  -- DATE        BUG      BY        DESCRIPTION
  -- ----------  -------  --------  -----------------------------------------------------
  -- 04/16/2002  2320575  ABLUNDEL  Took out the inner loop for c_get_rule_restrictions
  --                                as it was only getting the first rule restriction in
  --                                the table for a rule, noe it gets all for a rule
  --
  -- -------------------------------------------------------------------------------------
PROCEDURE COPY_GROUP(p_group_id       IN  NUMBER,
                     x_group_id       OUT NOCOPY NUMBER,
                     x_return_status  OUT NOCOPY VARCHAR2,
                     x_msg_count      OUT NOCOPY NUMBER,
                     x_msg_data       OUT NOCOPY VARCHAR2) IS


cursor c_get_next_group_id IS
select fte_sel_groups_s.nextval
from   dual;

l_new_group_id NUMBER;

cursor c_get_group_attributes(x_group_id NUMBER) IS
select group_attribute_id,
       attribute_id,
       attribute_default_value,
       attribute_uom_code,
       attribute_name
from   fte_sel_group_attributes
where  group_id = x_group_id;


cursor c_get_rules(xxx_group_id NUMBER) IS
select FTE_SEL_RULES_S.NEXTVAL,
       rule_id,
       name,
       precedence,
       sequence_number
from   fte_sel_rules
where  group_id = xxx_group_id;

cursor c_get_rule_restrictions(x_rule_id NUMBER) IS
select rule_attribute_id,
       rule_id,
       attribute_name,
       attribute_value_from,
       attribute_value_to,
       attribute_value_from_number,
       attribute_value_to_number,
       data_type,
       grouping_number
from   fte_sel_rule_restrictions
where  rule_id = x_rule_id;

cursor c_get_results(x_result_id NUMBER) IS
select FTE_SEL_RESULTS_S.NEXTVAL,
       FTE_SEL_RESULT_ASSIGNMENTS_S.NEXTVAL,
       result_id,
       name,
       description,
       enabled_flag,
       rank
from   fte_sel_results
where  result_id = x_result_id;

cursor c_get_result_assignments(xx_rule_id NUMBER) IS
select result_assignment_id,
       rule_id,
       result_id
from   fte_sel_result_assignments
where  rule_id = xx_rule_id;

cursor c_get_result_attributes(xx_result_id NUMBER) IS
select FTE_SEL_RESULT_ATTRIBUTES_S.NEXTVAL,
       result_attribute_id,
       result_id,
       attribute_code,
       attribute_value
from   fte_sel_result_Attributes
where  result_id = xx_result_id;

TYPE TableNumbers    is TABLE of NUMBER        INDEX BY BINARY_INTEGER; -- table number type
TYPE TableVarchar30  is TABLE of VARCHAR2(30)  INDEX BY BINARY_INTEGER; -- table varchar(30)
TYPE TableVarchar3   is TABLE of VARCHAR2(3)   INDEX BY BINARY_INTEGER; -- table varchar(3)
TYPE TableVarchar240 is TABLE of VARCHAR2(240) INDEX BY BINARY_INTEGER; -- table varchar(240)
TYPE TableVarchar10  is TABLE of VARCHAR2(10)  INDEX BY BINARY_INTEGER; -- table varchar(10)
TYPE TableVarchar1   is TABLE of VARCHAR2(1)   INDEX BY BINARY_INTEGER; -- table varchar(1)

t_group_attribute_id           TableNumbers;
t_attribute_id                 TableNumbers;
t_attribute_default_value      TableVarchar240;
t_attribute_uom_code           TableVarchar10;
t_attribute_name               TableVarchar30;

t_rule_id                      TableNumbers;
t_new_rule_id                  TableNumbers;
t_rule_name                    TableVarchar30;
t_rule_precedence              TableNumbers;
t_rule_sequence_number         TableNumbers;

t_resass_result_assignment_id  TableNumbers;
t_resass_rule_id               TableNumbers;
t_resass_result_id             TableNumbers;

t_new_result_assignment_id     TableNumbers;
tt_resass_result_assignment_id TableNumbers;
tt_resass_rule_id              TableNumbers;
tt_resass_result_id            TableNumbers;
tt_new_result_assignment_id    TableNumbers;

t_new_result_id                TableNumbers;
t_result_result_id             TableNumbers;
t_result_name                  TableVarchar30;
t_result_description           TableVarchar240;
t_result_enabled_flag          TableVarchar1;
t_result_rank                  TableNumbers;

tt_new_result_id               TableNumbers;
tt_result_result_id            TableNumbers;
tt_result_name                 TableVarchar30;
tt_result_description          TableVarchar240;
tt_result_enabled_flag         TableVarchar1;
tt_result_rank                 TableNumbers;

t_rest_rule_attribute_id       TableNumbers;
t_rest_rule_id                 TableNumbers;
t_rest_attribute_name          TableVarchar30;
t_rest_attribute_value_from    TableVarchar240;
t_rest_attribute_value_to      TableVarchar240;
t_rest_attribute_value_from_n  TableNumbers;
t_rest_attribute_value_to_n    TableNumbers;
t_rest_data_type               TableVarchar1;
t_rest_grouping_number         TableNumbers;

tt_rest_rule_attribute_id      TableNumbers;
tt_rest_rule_id                TableNumbers;
tt_rest_attribute_name         TableVarchar30;
tt_rest_attribute_value_from   TableVarchar240;
tt_rest_attribute_value_to     TableVarchar240;
tt_rest_attribute_value_from_n TableNumbers;
tt_rest_attribute_value_to_n   TableNumbers;
tt_rest_data_type              TableVarchar1;
tt_rest_grouping_number        TableNumbers;

t_new_result_attribute_id      TableNumbers;
t_resattr_attribute_id         TableNumbers;
t_resattr_result_id            TableNumbers;
t_resattr_attribute_code       TableVarchar30;
t_resattr_attribute_value      TableVarchar240;

tt_new_result_attribute_id     TableNumbers;
tt_resattr_attribute_id        TableNumbers;
tt_resattr_result_id           TableNumbers;
tt_resattr_attribute_code      TableVarchar30;
tt_resattr_attribute_value     TableVarchar240;


n                              NUMBER := 0;
q                              NUMBER := 0;
t                              NUMBER := 0;
y                              NUMBER := 0;

l_t_new_group_id               VARCHAR2(30);  -- char version of l_new_group_id
l_error_code                   NUMBER;
l_error_text                   VARCHAR2(4000);

BEGIN

   --
   -- Copy group:
   -- 1) FTE_SEL_GROUPS
   -- 2) FTE_SEL_GROUP_ATTRIBUTES
   -- 3) FTE_SEL_RULES
   -- 4) FTE_SEL_RULE_RESTRICTIONS
   -- 5) FTE_SEL_RESULTS
   --    5a) FTE_SEL_RESULT_ASSIGNMENTS
   --    5b) FTE_SEL_RESULT_ATTRIBUTES
   --



     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


     --
     -- Get the new group id
     --
     OPEN c_get_next_group_id;
        FETCH c_get_next_group_id INTO l_new_group_id;
     IF (c_get_next_group_id%ISOPEN) THEN
        CLOSE c_get_next_group_id;
     END IF;

     IF ((l_new_group_id <= 0) OR
         (l_new_group_id is null)) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        RETURN;
     END IF;

     l_t_new_group_id := to_char(l_new_group_id);


     --
     -- 1) FTE_SEL_GROUPS
     --
     BEGIN
        SAVEPOINT insert_fte_sel_groups;

        INSERT INTO fte_sel_groups(GROUP_ID,
                                   NAME,
                                   DESCRIPTION,
                                   OBJECT_ID,
                                   START_DATE,
                                   END_DATE,
                                   CREATION_DATE,
                                   CREATED_BY,
                                   LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY,
                                   LAST_UPDATE_LOGIN,
                                   ASSIGNED_FLAG,
                                   GROUP_STATUS_FLAG)
                                  (SELECT l_new_group_id,
                                   l_t_new_group_id,
                                   'Copy of '||name,
                                   object_id,
                                   start_date,
                                   end_date,
                                   sysdate,
                                   -1,
                                   sysdate,
                                   -1,
                                   -1,
                                   'N',
                                   group_status_flag
                                   FROM fte_sel_groups
                                   WHERE group_id = p_group_id);


-- substr(name,1,decode(instr(name, '('),0,30,instr(name,'('))-2)||' (Copy# '||l_new_group_id||')',

     EXCEPTION
        WHEN OTHERS THEN
           ROLLBACK TO insert_fte_sel_groups;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           RETURN;
     END;


     x_group_id := l_new_group_id;



     --
     -- 2) FTE_SEL_GROUP_ATTRIBUTES
     --

     t_group_attribute_id.DELETE;
     t_attribute_id.DELETE;
     t_attribute_default_value.DELETE;
     t_attribute_uom_code.DELETE;
     t_attribute_name.DELETE;

     --
     -- Peform a bulk fetch of group attributes
     --
     OPEN c_get_group_attributes(p_group_id);
        LOOP
           FETCH c_get_group_attributes BULK COLLECT INTO
              t_group_attribute_id,
              t_attribute_id,
              t_attribute_default_value,
              t_attribute_uom_code,
              t_attribute_name;


           EXIT WHEN c_get_group_attributes%NOTFOUND OR c_get_group_attributes%NOTFOUND IS NULL;
        END LOOP;
     IF (c_get_group_attributes%ISOPEN) THEN
        CLOSE c_get_group_attributes;
     END IF;


     --
     -- Copy the attributes
     --
     IF (t_group_attribute_id.COUNT > 0) THEN

        FORALL j in t_group_attribute_id.FIRST..t_group_attribute_id.LAST
           INSERT INTO fte_sel_group_attributes (
	    GROUP_ATTRIBUTE_ID,
	    ATTRIBUTE_ID,
	    ATTRIBUTE_DEFAULT_VALUE,
	    ATTRIBUTE_UOM_CODE,
	    GROUP_ID,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    ATTRIBUTE_NAME)
	    VALUES
            (FTE_SEL_GROUP_ATTRIBUTES_S.NEXTVAL,
             t_attribute_id(j),
             t_attribute_default_value(j),
             t_attribute_uom_code(j),
             l_new_group_id,
             sysdate,
             -1,
             sysdate,
             -1,
             -1,
             t_attribute_name(j));
     END IF;



     --
     -- 3) FTE_SEL_RULES
     --
     t_rule_id.DELETE;
     t_rule_name.DELETE;
     t_rule_precedence.DELETE;
     t_rule_sequence_number.DELETE;

     --
     -- Peform a bulk fetch of rules
     --

     OPEN c_get_rules(p_group_id);
        LOOP
           FETCH c_get_rules BULK COLLECT INTO
              t_new_rule_id,
              t_rule_id,
              t_rule_name,
              t_rule_precedence,
              t_rule_sequence_number;

           EXIT WHEN c_get_rules%NOTFOUND OR c_get_rules%NOTFOUND IS NULL;

        END LOOP;
     IF (c_get_rules%ISOPEN) THEN
        CLOSE c_get_rules;
     END IF;


     --
     -- Copy the rules
     --
     IF (t_rule_id.COUNT > 0) THEN

        FORALL k in t_rule_id.FIRST..t_rule_id.LAST
           INSERT INTO fte_sel_rules(
             RULE_ID,
             NAME,
             GROUP_ID,
             PRECEDENCE,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             SEQUENCE_NUMBER)
            VALUES (t_new_rule_id(k),
             to_char(t_new_rule_id(k)),
             l_new_group_id,
             t_rule_precedence(k),
             sysdate,
             -1,
             sysdate,
             -1,
             -1,
             t_rule_sequence_number(k));


-- substr(t_rule_name(k),1,decode(instr(t_rule_name(k), '('),0,30,instr(t_rule_name(k),'('))-2)||' (Copy# '||t_new_rule_id(k)||')',


     END IF;



     --
     -- 4) FTE_SEL_RULE_RESTRICTIONS
     --
     t_rest_rule_attribute_id.DELETE;
     t_rest_rule_id.DELETE;
     t_rest_attribute_name.DELETE;
     t_rest_attribute_value_from.DELETE;
     t_rest_attribute_value_to.DELETE;
     t_rest_attribute_value_from_n.DELETE;
     t_rest_attribute_value_to_n.DELETE;
     t_rest_data_type.DELETE;
     t_rest_grouping_number.DELETE;

     n := 0;

     FOR l IN t_rule_id.FIRST..t_rule_id.LAST LOOP
        OPEN c_get_rule_restrictions(t_rule_id(l));
          --
          -- BUG: 2320575 LOOP
          -- removed loop
          --
              FETCH c_get_rule_restrictions BULK COLLECT INTO
                  t_rest_rule_attribute_id,
                  t_rest_rule_id,
                  t_rest_attribute_name,
                  t_rest_attribute_value_from,
                  t_rest_attribute_value_to,
                  t_rest_attribute_value_from_n,
                  t_rest_attribute_value_to_n,
                  t_rest_data_type,
                  t_rest_grouping_number;

           --
           -- Should have all the rule restrictions now for a rule
           --
           --
           -- Copy the rules
           --
           IF (t_rest_rule_attribute_id.COUNT > 0) THEN
              FORALL o in t_rest_rule_attribute_id.FIRST..t_rest_rule_attribute_id.LAST
                 INSERT INTO fte_sel_rule_restrictions(
                  RULE_ATTRIBUTE_ID,
                  RULE_ID,
                  ATTRIBUTE_NAME,
                  ATTRIBUTE_VALUE_FROM,
                  ATTRIBUTE_VALUE_TO,
                  ATTRIBUTE_VALUE_FROM_NUMBER,
                  ATTRIBUTE_VALUE_TO_NUMBER,
                  DATA_TYPE,
                  GROUPING_NUMBER,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN,
                  GROUP_ID)
                 VALUES (FTE_SEL_RULE_RESTRICTIONS_S.NEXTVAL,
                  t_new_rule_id(l),
                  t_rest_attribute_name(o),
                  t_rest_attribute_value_from(o),
                  t_rest_attribute_value_to(o),
                  t_rest_attribute_value_from_n(o),
                  t_rest_attribute_value_to_n(o),
                  t_rest_data_type(o),
                  t_rest_grouping_number(o),
                  sysdate,
                  -1,
                  sysdate,
                  -1,
                  -1,
                  l_new_group_id);
           END IF;

        IF (c_get_rule_restrictions%ISOPEN) THEN
           CLOSE c_get_rule_restrictions;
        END IF;
     END LOOP;

     --
     -- 5) FTE_SEL_RESULTS
     --
     t_new_result_assignment_id.DELETE;
     t_resass_result_assignment_id.DELETE;
     t_resass_rule_id.DELETE;
     t_resass_result_id.DELETE;

     tt_new_result_assignment_id.DELETE;
     tt_resass_result_assignment_id.DELETE;
     tt_resass_rule_id.DELETE;
     tt_resass_result_id.DELETE;

     t_new_result_id.DELETE;
     t_result_result_id.DELETE;
     t_result_name.DELETE;
     t_result_description.DELETE;
     t_result_enabled_flag.DELETE;
     t_result_rank.DELETE;
     tt_new_result_id.DELETE;
     tt_result_result_id.DELETE;
     tt_result_name.DELETE;
     tt_result_description.DELETE;
     tt_result_enabled_flag.DELETE;
     tt_result_rank.DELETE;

     q := 0;
     --
     -- First we have to query the assignments table by rule_id to get the result_id
     --
     FOR p IN t_rule_id.FIRST..t_rule_id.LAST LOOP
        OPEN c_get_result_assignments(t_rule_id(p));
           LOOP
              FETCH c_get_result_assignments BULK COLLECT INTO
                 t_resass_result_assignment_id,
                 t_resass_rule_id,
                 t_resass_result_id;


              q := 0;

              IF (t_resass_result_assignment_id.COUNT > 0 ) THEN
                 FOR r in t_resass_result_assignment_id.FIRST..t_resass_result_assignment_id.LAST LOOP
                    q  := q + 1;
                    tt_resass_result_assignment_id(q) := t_resass_result_assignment_id(r);
                    tt_resass_rule_id(q)              := t_rule_id(p);
                    tt_resass_result_id(q)            := t_resass_result_id(r);
                 END LOOP;
              END IF;

           EXIT WHEN c_get_result_assignments%NOTFOUND or c_get_result_assignments%NOTFOUND IS NULL;
           END LOOP;


           --
           -- Should have all the assignments for a rule
           -- (query the result)
           --
           FOR s IN tt_resass_result_id.FIRST.. tt_resass_result_id.LAST LOOP


              OPEN c_get_results(tt_resass_result_id(s));
                 LOOP
                    FETCH c_get_results BULK COLLECT INTO
                       t_new_result_id,
                       t_new_result_assignment_id,
                       t_result_result_id,
                       t_result_name,
                       t_result_description,
                       t_result_enabled_flag,
                       t_result_rank;


                    IF (t_result_result_id.COUNT > 0 ) THEN
                        t := 0;
                       FOR u in t_result_result_id.FIRST..t_result_result_id.LAST LOOP
                          t  := t + 1;
                          tt_new_result_id(t)       := t_new_result_id(u);
                          tt_new_result_assignment_id(t) := t_new_result_assignment_id(u);
                          tt_result_result_id(t)    := t_result_result_id(u);
                          tt_result_name(t)         := t_result_name(u);
                          tt_result_description(t)  := t_result_description(u);
                          tt_result_enabled_flag(t) := t_result_enabled_flag(u);
                          tt_result_rank(t)         := t_result_rank(u);

                       END LOOP;
                    END IF;

                 EXIT WHEN c_get_results%NOTFOUND or c_get_results%NOTFOUND IS NULL;
                 END LOOP;  -- [BULK FETCH]
                 --
                 -- now we have the results for the rule
                 --
                 --
                 -- Copy the results
                 --
                 IF (tt_result_result_id.COUNT > 0) THEN
/*
   do not create data in FTE_SEL_RESULTS yet
   it'll be handled by Save_Results as the final step of copy flow

                    FORALL v in tt_result_result_id.FIRST..tt_result_result_id.LAST
                       INSERT INTO fte_sel_results (
                        RESULT_ID,
                        NAME,
                        DESCRIPTION,
                        ENABLED_FLAG,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        RANK)
                       VALUES (tt_new_result_id(v),
                        to_char(tt_new_result_id(v)),
                        tt_result_description(v),
                        tt_result_enabled_flag(v),
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                        tt_result_rank(v));
*/


                    --
                    -- copy the asssignments
                    --
                    IF (tt_result_result_id.COUNT > 0) THEN
                       FORALL w in tt_result_result_id.FIRST..tt_result_result_id.LAST
                          INSERT INTO fte_sel_result_assignments (
                           RESULT_ASSIGNMENT_ID,
                           RULE_ID,
                           RESULT_ID,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_LOGIN)
                          VALUES (tt_new_result_assignment_id(w),
                           t_new_rule_id(p),
                           tt_new_result_id(w),
                           sysdate,
                           -1,
                           sysdate,
                           -1,
                           -1);
                    END IF;


                    y := 0;
                    --
                    -- Query the result attributes
                    --
                    t_new_result_attribute_id.DELETE;
                    t_resattr_attribute_id.DELETE;
                    t_resattr_result_id.DELETE;
                    t_resattr_attribute_code.DELETE;
                    t_resattr_attribute_value.DELETE;
                    tt_new_result_attribute_id.DELETE;
                    tt_resattr_attribute_id.DELETE;
                    tt_resattr_result_id.DELETE;
                    tt_resattr_attribute_code.DELETE;
                    tt_resattr_attribute_value.DELETE;

                    FOR x IN tt_result_result_id.FIRST.. tt_result_result_id.LAST LOOP
                       OPEN c_get_result_attributes(tt_result_result_id(x));
                          LOOP
                             FETCH c_get_result_attributes BULK COLLECT INTO
                                t_new_result_attribute_id,
                                t_resattr_attribute_id,
                                t_resattr_result_id,
                                t_resattr_attribute_code,
                                t_resattr_attribute_value;

                             IF (t_resattr_attribute_id.COUNT > 0 ) THEN
                                FOR z in t_resattr_attribute_id.FIRST..t_resattr_attribute_id.LAST LOOP
                                   y  := y + 1;
                                   tt_new_result_attribute_id(y) := t_new_result_attribute_id(z);
                                   tt_resattr_attribute_id(y)    := t_resattr_attribute_id(z);
                                   tt_resattr_result_id(y)       := t_resattr_result_id(z);
                                   tt_resattr_attribute_code(y)  := t_resattr_attribute_code(z);
                                   tt_resattr_attribute_value(y) := t_resattr_attribute_value(z);
                                END LOOP;
                             END IF;
                          EXIT WHEN c_get_result_attributes%NOTFOUND or c_get_result_attributes%NOTFOUND IS NULL;
                          END LOOP;  -- [BULK FETCH]

                          -- Copy the result attributes
                          --
                          IF (tt_resattr_attribute_id.COUNT > 0) THEN
                             FORALL aa in tt_resattr_attribute_id.FIRST..tt_resattr_attribute_id.LAST
                                INSERT INTO fte_sel_result_attributes (
                                    RESULT_ATTRIBUTE_ID,
                                    RESULT_ID,
                                    ATTRIBUTE_CODE,
                                    ATTRIBUTE_VALUE,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN)
                                   VALUES (tt_new_result_attribute_id(aa),
                                    tt_new_result_id(x),
                                    tt_resattr_attribute_code(aa),
                                    tt_resattr_attribute_value(aa),
                                    sysdate,
                                    -1,
                                    sysdate,
                                    -1,
                                    -1);

                                 tt_new_result_attribute_id.DELETE;
                                 tt_resattr_attribute_id.DELETE;
                                 tt_resattr_result_id.DELETE;
                                 tt_resattr_attribute_code.DELETE;
                                 tt_resattr_attribute_value.DELETE;
                          END IF;


                       IF (c_get_result_attributes%ISOPEN) THEN
                          CLOSE c_get_result_attributes;
                       END IF;
                    END LOOP;


                    t_new_result_id.DELETE;
                    t_result_result_id.DELETE;
                    t_result_name.DELETE;
                    t_result_description.DELETE;
                    t_result_enabled_flag.DELETE;
                    t_result_rank.DELETE;
                    tt_new_result_id.DELETE;
                    tt_result_result_id.DELETE;
                    tt_result_name.DELETE;
                    tt_result_description.DELETE;
                    tt_result_enabled_flag.DELETE;
                    tt_result_rank.DELETE;
                    tt_new_result_assignment_id.DELETE;
                    t_new_result_assignment_id.DELETE;
                 END IF;
              CLOSE c_get_results;
           END LOOP;


           t_resass_result_assignment_id.DELETE;
           t_resass_rule_id.DELETE;
           t_resass_result_id.DELETE;
           tt_resass_result_assignment_id.DELETE;
           tt_resass_rule_id.DELETE;
           tt_resass_result_id.DELETE;

        CLOSE c_get_result_assignments;
     END LOOP;

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     RETURN;

EXCEPTION
   WHEN OTHERS THEN
      x_group_id := null;
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;
      WSH_UTIL_CORE.Println('The unexpected error from FTE_SEL_GROUPS_PKG.COPY_GROUP is ' ||l_error_text);
      WSH_UTIL_CORE.default_handler('FTE_SEL_GROUPS_PKG.COPY_GROUP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      RETURN;

END COPY_GROUP;

  --
  -- Function: Is_Valid_Region
  --
  -- Purpose:  Check if the Rule consists of Regions defined in the current language
  --
  --
  FUNCTION Is_Valid_Region(
                  p_group_id            IN      NUMBER
                ) RETURN VARCHAR2 IS


  CURSOR get_region_cursor IS
  SELECT attribute_value_from_number
    FROM fte_sel_rule_restrictions
   WHERE group_id = p_group_id
     AND attribute_name like '%REGION_ID';

  all_valid VARCHAR2(1);
  x_region_id NUMBER;

  BEGIN
    all_valid := 'Y';
    FOR region_cur IN get_region_cursor LOOP

      BEGIN
        SELECT region_id INTO x_region_id
          FROM wsh_regions_v
         WHERE region_id = region_cur.attribute_value_from_number;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          all_valid := 'N';
          exit;
        WHEN OTHERS THEN
          null;
      END;
    END LOOP;

    RETURN all_valid;

  END Is_Valid_Region;

END FTE_SEL_GROUPS_PKG;

/
