--------------------------------------------------------
--  DDL for Package Body JTF_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ASSIGN_PUB" AS
/* $Header: jtfamprb.pls 120.12.12010000.3 2009/09/16 12:42:13 ramchint ship $ */

-- ********************************************************************************

-- Start of Comments
--
--      Package Name    : JTF_ASSIGN_PUB
--      Purpose         : Joint Task Force Core Foundation Assignment Manager
--                        Public APIs. This package is for finding the
--                        a resource based on the customer preferences
--                        or territory preferences and the availability of
--                        the resource in the specified time frame.
--      Procedures      : (See below for specification)
--      Notes           : This package is publicly available for use
--      History         : 11/02/99 ** VVUYYURU ** Vijay Vuyyuru ** created
--                        Created the procedure for Tasks
--
--                      : 12/02/99 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the procedure for Service Requests
--
--                      : 01/02/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the procedure for Opportunities
--
--                      : 01/12/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the procedure for Leads
--
--                      : 02/02/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the procedure for Defect Management System
--
--                      : 03/20/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added Dynamic SQL for the cs_contacts_v
--
--                      : 03/23/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added Dynamic SQL for the cs_incidents_all_vl
--
--                      : 04/05/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added Functions to get the default values of
--                        FND_API variables
--
--                      : 04/14/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the procedure for Escalations
--
--                      : 07/20/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the new procedure for Leads
--                        Replaced the old procedure for Leads
--
--                      : 10/16/00 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the new record definition for Defects
--                        Changed the specification and body with the
--                        enhanced DEFECTS code
--
--                      : 01/09/01 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the code to fetch Installed Base
--                        Preferred Engineers
--
--                      : 02/02/01 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the code to sort the OUT pl/sql table
--                        data using the Resource Location.
--                        Implemented for TASKS
--
--                      : 03/21/01 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added the code to resolve the Calendar NOT working
--                        due to the Uneven Record Numbers which are given in case
--                        of NO SHIFT from Calendar which in turn causes error in
--                        the Resource Location Sorting.
--
--                      : 04/16/01 ** VVUYYURU ** Vijay Vuyyuru **
--                        Territory changed some record definitions!
--                        Hence made relevant code changes for TASKS, SR, SR-TASK
--
--                      : 01/14/02 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added two more parameters to the main API and SR API
--                        p_contract_id and p_customer_product_id
--                        This is to ensure that the SR need not be saved
--                        to fetch the IB and Contracts Preferred Resources
--
--                      : 02/11/02 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added Contract Coverage Type to SR / SR-TASK API
--
--                      : 05/06/02 ** VVUYYURU ** Vijay Vuyyuru **
--                        Added separate procedures for Contracts and IB
--                        Modularized the process for Preferred Engineers.
--                      : 12/22/05 ** MPADHIAR ** Manas padhiary **
--                        Removed Comment to Show error message Bug # 2919389
--
-- End of Comments

-- *******************************************************************************






-- *******************************************************************************

-- Start of comments

-- Functions       : These functions are to get the FND_API default values.

-- End of comments

-- *******************************************************************************

  g_contracts_tbl                       JTF_ASSIGN_PUB.AssignResources_tbl_type ;
  g_ib_tbl                              JTF_ASSIGN_PUB.AssignResources_tbl_type ;
  g_excluded_resource_tbl               JTF_ASSIGN_PUB.excluded_tbl_type ;
  g_continuous_work                     VARCHAR2(10);


  FUNCTION am_miss_num RETURN NUMBER IS

  BEGIN
    RETURN (FND_API.g_miss_num);
  END am_miss_num;


  FUNCTION am_miss_char RETURN VARCHAR2 IS

  BEGIN
    RETURN (FND_API.g_miss_char);
  END am_miss_char;


  FUNCTION am_miss_date RETURN DATE IS

  BEGIN
    RETURN (FND_API.g_miss_date);
  END am_miss_date;


  FUNCTION am_false RETURN VARCHAR2 IS

  BEGIN
    RETURN (FND_API.g_false);
  END am_false;


  FUNCTION am_true RETURN VARCHAR2 IS

  BEGIN
    RETURN (FND_API.g_true);
  END am_true;


  FUNCTION am_valid_level_full RETURN VARCHAR2 IS

  BEGIN
    RETURN (FND_API.g_valid_level_full);
  END am_valid_level_full;





-- *******************************************************************************

-- Start of comments

-- Function       : This function is to get the changed Resource Type.
--                  It appends/removes the string "RS_"

-- End of comments

-- *******************************************************************************



  FUNCTION resource_type_change(p_res_type VARCHAR2) RETURN VARCHAR2 IS
    l_res_type VARCHAR2(30);

  BEGIN

    IF (p_res_type = 'RS_EMPLOYEE') THEN
      l_res_type := 'EMPLOYEE';
    ELSIF (p_res_type = 'RS_PARTY') THEN
      l_res_type := 'PARTY';
    ELSIF (p_res_type = 'RS_PARTNER') THEN
      l_res_type := 'PARTNER';
    ELSIF (p_res_type = 'RS_SUPPLIER') THEN
      l_res_type := 'SUPPLIER_CONTACT';
    ELSIF (p_res_type = 'RS_SUPPLIER_CONTACT') THEN
      l_res_type := 'SUPPLIER_CONTACT';
    ELSIF (p_res_type = 'RS_OTHER') THEN
      l_res_type := 'OTHER';
    ELSIF (p_res_type = 'RS_TBH') THEN
      l_res_type := 'TBH';
    ELSIF (p_res_type = 'EMPLOYEE') THEN
      l_res_type := 'RS_EMPLOYEE';
    ELSIF (p_res_type = 'PARTY') THEN
      l_res_type := 'RS_PARTY';
    ELSIF (p_res_type = 'PARTNER') THEN
      l_res_type := 'RS_PARTNER';
    ELSIF (p_res_type = 'SUPPLIER_CONTACT') THEN
      l_res_type := 'RS_SUPPLIER_CONTACT';
    ELSIF (p_res_type = 'OTHER') THEN
      l_res_type := 'RS_OTHER';
    ELSIF (p_res_type = 'TBH') THEN
      l_res_type := 'RS_TBH';
    END IF;

    RETURN(l_res_type);
  END resource_type_change;





-- *******************************************************************************

-- Start of comments

-- Function       : This procedure is to get back the Record of Tables
--                  into the normal Table of Records.

-- End of comments

-- *******************************************************************************



  /* Procedure to write back data from Tables to Table Type variable */

  PROCEDURE table_copy_in
    (
      l_engineer_id                 IN  JTF_NUMBER_TABLE,
      l_resource_type               IN  JTF_VARCHAR2_TABLE_100,
      l_primary_flag                IN  JTF_VARCHAR2_TABLE_100,
      l_resource_class              IN  JTF_VARCHAR2_TABLE_100,
      l_con_preferred_engineers_tbl OUT NOCOPY JTF_ASSIGN_PUB.prfeng_tbl_type
    )
  IS

    l_ddindx BINARY_INTEGER;
    l_indx   BINARY_INTEGER;

  BEGIN
    IF l_engineer_id IS NOT NULL AND
       l_engineer_id.count > 0 THEN
      IF l_engineer_id.count > 0 THEN
        l_indx := l_engineer_id.first;
        l_ddindx := 0;
        WHILE true LOOP
          l_con_preferred_engineers_tbl(l_ddindx).engineer_id    := l_engineer_id(l_indx);
          l_con_preferred_engineers_tbl(l_ddindx).resource_type  := l_resource_type(l_indx);
          l_con_preferred_engineers_tbl(l_ddindx).primary_flag   := nvl(l_primary_flag(l_indx), 'N');
          l_con_preferred_engineers_tbl(l_ddindx).resource_class := nvl(l_resource_class(l_indx), 'R');
                                                                    -- resource class is R for Preferred
                                                                    -- P for Primary and
                                                                    -- E for Excluded
          l_ddindx := l_ddindx+1;
          IF l_engineer_id.last = l_indx THEN
            exit;
          END IF;
          l_indx := l_engineer_id.next(l_indx);
        END LOOP;
      END IF;
    END IF;
  END table_copy_in;


-- procedure to copy resources from one table to another
PROCEDURE table_copy(p_from_table     IN JTF_ASSIGN_PUB.AssignResources_tbl_type,
                     x_to_table       IN OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type)
IS

i number := 0;
k number := 0;
BEGIN

   if( x_to_table.count <= 0)
   then
      i := 0;
   else
    i := x_to_table.last + 1;
   end if;

   IF(p_from_table.count > 0)
   THEN
      k := p_from_table.first;

      While(k <= p_from_table.last)
      loop
          x_to_table(i) := p_from_table(k);
          i := i + 1;
          k := k + 1;
      end loop;
   END IF;

END table_copy;


-- procedure to remove excluded resources
PROCEDURE remove_excluded(x_res_tbl     IN OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
                          x_exc_res     IN OUT NOCOPY JTF_ASSIGN_PUB.excluded_tbl_type)
IS

i number := 0;
k number := 0;
l_count  number := 0;
l_exclude varchar2(1) := 'N';
l_resource_tbl JTF_ASSIGN_PUB.AssignResources_tbl_type;
BEGIN
   l_resource_tbl.delete;
   if(x_exc_res.count > 0 and x_res_tbl.count > 0)
   then
      for  i in x_res_tbl.first..x_res_tbl.last
      loop
         l_exclude := 'N';
         for k in x_exc_res.first..x_exc_res.last
         loop
            if(x_exc_res(k).resource_id = x_res_tbl(i).resource_id and
                                    x_exc_res(k).resource_type = x_res_tbl(i).resource_type)
            then
               l_exclude := 'Y';
               exit;
            end if;
         end loop; -- end of loop for x_exc_res
        if(l_exclude = 'N')
         then
            l_resource_tbl(l_count) := x_res_tbl(i);
            l_count := l_count + 1;
         end if; -- end if l_exclude check
      end loop; -- end of loop for x_res_tbl
     x_res_tbl.delete;
     x_res_tbl := l_resource_tbl;
   end if; -- end of count check for both tables

END remove_excluded;



-- *******************************************************************************

-- Start of comments

-- Function       : This procedure is to sort the pl/sql table of resources
--                  based on the Resource Location.

-- End of comments

-- *******************************************************************************



  PROCEDURE quick_sort_resource_loc
    (
      p_left   INTEGER,
      p_right  INTEGER,
      p_list   IN OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type
    )
  IS

    i       INTEGER;
    j       INTEGER;
    l_left  INTEGER := p_left;
    l_right INTEGER := p_right;
    l_current_node JTF_ASSIGN_PUB.AssignResources_rec_type;
    l_dummy_node   JTF_ASSIGN_PUB.AssignResources_rec_type;

  BEGIN

    IF (l_right > l_left) THEN
      l_current_node := p_list(l_right);
      i := l_left -1;
      j := l_right;
      LOOP
        LOOP
          i := i +1;
          --dbms_output.put_line('Entered LOOP 1');
          --dbms_output.put_line('i is : '||to_char(i));
          IF (p_list(i).location < l_current_node.location) THEN
            null;
          ELSE
            exit;
          END IF;

          IF (i >= p_list.count) THEN
            exit;
          END IF;
        END LOOP;

        LOOP
          j := j -1;
          --dbms_output.put_line('Entered LOOP 2');
          --dbms_output.put_line('j is : '||to_char(j));
          IF (p_list(j).location > l_current_node.location) THEN
            null;
          ELSE
            exit;
          END IF;

          IF (j <= 0) THEN
            exit;
          END IF;

        END LOOP;

        IF (i >= j) THEN
          exit;
        END IF;

        l_dummy_node  := p_list(i);
        p_list(i)     := p_list(j);
        p_list(j)     := l_dummy_node;
      END LOOP;

      l_dummy_node    := p_list(i);
      p_list(i)       := p_list(l_right);
      p_list(l_right) := l_dummy_node;

      quick_sort_resource_loc(l_left, i-1,     p_list);
      quick_sort_resource_loc(i+1,    l_right, p_list);

    END IF;
  END quick_sort_resource_loc;


 -- *******************************************************************************

-- Start of comments

-- bug/Enhancement : 6453896
-- Function        : This procedure was added to sort territories dependend on
--		     Territory Ranking returned by Territories product.
--		     It is used in Get_ASSIGN_RESOURCES procedure. This procedure
--		     will sort only when rank is returned by Territories.
-- Added by	   : sdwived2
--
-- End of comments

-- *******************************************************************************


  PROCEDURE quick_sort_terr_rank
    ( p_left   INTEGER,
      p_right  INTEGER,
      p_list   IN OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type
    )
  IS

    i       INTEGER;
    j       INTEGER;
    l_left  INTEGER := p_left;
    l_right INTEGER := p_right;
    l_current_node JTF_ASSIGN_PUB.AssignResources_rec_type;
    l_dummy_node   JTF_ASSIGN_PUB.AssignResources_rec_type;

  BEGIN

    IF (l_right > l_left) THEN
      l_current_node := p_list(l_right);
      i := l_left -1;
      j := l_right;
      LOOP
        LOOP
          i := i +1;
          dbms_output.put_line('Entered LOOP 1');
          dbms_output.put_line('i is : '||to_char(i));
          dbms_output.put_line('i current node : '||l_current_node.terr_rank);
          IF (p_list(i).terr_rank > l_current_node.terr_rank) THEN
            null;
          ELSE
            exit;
          END IF;

          IF (i >= p_list.count) THEN
            exit;
          END IF;
        END LOOP;

        LOOP
          j := j -1;
          dbms_output.put_line('Entered LOOP 2');
          dbms_output.put_line('j is : '||to_char(j));
          dbms_output.put_line('j current node : '||l_current_node.terr_rank);
          IF (j <= 0) THEN
            dbms_output.put_line('when j <=0');
            exit;
          END IF;
          IF (p_list(j).terr_rank < l_current_node.terr_rank)  THEN
            dbms_output.put_line('Inside if');
            null;
          ELSE
           dbms_output.put_line('Inside else before exit');
            exit;
          END IF;



        END LOOP;

        IF (i >= j) THEN
          dbms_output.put_line('when i >=j');
          exit;
        END IF;
        dbms_output.put_line('inside j loop before ');
        dbms_output.put_line('inside j loop before '||p_list(i).terr_rank);
        dbms_output.put_line('inside j loop before '||p_list(j).terr_rank);
        l_dummy_node  := p_list(i);
        p_list(i)     := p_list(j);
        p_list(j)     := l_dummy_node;
        dbms_output.put_line('inside j loop after '||p_list(i).terr_rank);
        dbms_output.put_line('inside j loop after '||p_list(j).terr_rank);
      END LOOP;

      l_dummy_node    := p_list(i);
      p_list(i)       := p_list(l_right);
      p_list(l_right) := l_dummy_node;
        dbms_output.put_line('  after i  '||p_list(i).terr_rank);
        dbms_output.put_line(' after l_right  '||p_list(l_right).terr_rank);
        dbms_output.put_line('Values passed are  left '||l_left);
        dbms_output.put_line('Values passed are  right '||to_char(i-1));

      quick_sort_terr_rank(l_left, i-1,     p_list);
      quick_sort_terr_rank(i+1,    l_right, p_list);

    END IF;
  END quick_sort_terr_rank;

/**************** Start of addition by SBARAT on 11/01/2005 for Enh 4112155**************/

-- *******************************************************************************

-- Start of comments

-- Function       : This procedure is to assign values of component/subcomponent fields
--                  to Territory's record type dynamically, so that there will not be
--                  any compilation error if reqd patch of Territory not applied in env.

-- End of comments

-- *******************************************************************************


  PROCEDURE Terr_Qual_Dyn_Assign
     (
       p_sr_assign_rec       IN     JTF_ASSIGN_PUB.JTF_Serv_Req_rec_type,
       p_sr_task_assign_rec  IN     JTF_ASSIGN_PUB.JTF_Srv_Task_rec_type
     )
  IS

  BEGIN

  EXECUTE IMMEDIATE
  '
  BEGIN

  JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type.SQUAL_NUM23:=:1;
  JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type.SQUAL_NUM24:=:2;

  JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type.SQUAL_NUM23:=:3;
  JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type.SQUAL_NUM24:=:4;

  END;
  '
  USING
    IN  p_sr_assign_rec.ITEM_COMPONENT,
    IN  p_sr_assign_rec.ITEM_SUBCOMPONENT,
    IN  p_sr_task_assign_rec.ITEM_COMPONENT,
    IN  p_sr_task_assign_rec.ITEM_SUBCOMPONENT;

  EXCEPTION
        When OTHERS Then
          NULL;

  END Terr_Qual_Dyn_Assign;



-- *******************************************************************************

-- Start of comments

-- Function       : This procedure is to check dynamically whether a value passed to
--                  component,subcomponent fields. Used dynamic SQL to overcome AM's
--                  build dependancy on Territory for these fields.

-- End of comments

-- *******************************************************************************


  PROCEDURE Terr_Qual_Dyn_Check
     (
      p_sr_comp_sub        OUT  NOCOPY  Varchar2,
      p_sr_task_comp_sub   OUT  NOCOPY  Varchar2)
  IS

  BEGIN

  EXECUTE IMMEDIATE
  '
  BEGIN
  If (JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type.SQUAL_NUM23 IS NOT NULL)
     Or (JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type.SQUAL_NUM24 IS NOT NULL)
  Then
  :1:=''P'';
  End If;

  If (JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type.SQUAL_NUM23 IS NOT NULL)
     Or (JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type.SQUAL_NUM24 IS NOT NULL)
  Then
  :2:=''P'';
  End If;
  End;
  '
  USING
    OUT p_sr_comp_sub,
    OUT p_sr_task_comp_sub;

  EXCEPTION
       When OTHERS Then
            NULL;
  END Terr_Qual_Dyn_Check;

/**************** End of addition by SBARAT on 11/01/2005 for Enh 4112155**************/


-- *******************************************************************************

-- Start of comments

-- Function       : This procedure is to fetch the Resources in a particular
--                  group based on the ID of the Group which has been passed.

-- End of comments

-- *******************************************************************************



  PROCEDURE get_group_resource(p_group_id              IN NUMBER,
                               x_assign_resources_tbl  IN OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type)
  IS

    CURSOR check_mem_cur
           (
             l_group_id    NUMBER,
             l_resource_id NUMBER
           ) IS
      SELECT 'Y'
        FROM  jtf_rs_group_members mem
       WHERE  mem.group_id    = l_group_id
         AND  mem.resource_id = l_resource_id
         AND  nvl(mem.delete_flag , 'N') <> 'Y';

    l_found   VARCHAR2(1) := 'N';
    l_count   NUMBER      := 0;
    i         NUMBER      := 0;
    l_assign_resource_tbl JTF_ASSIGN_PUB.AssignResources_tbl_type;


  BEGIN
    --FOR i IN 1..x_assign_resources_tbl.COUNT
    -- changed loop criterion for bug 3284857. on 1st Dec 2003
   IF(x_assign_resources_tbl.COUNT > 0)
   THEN
    FOR i IN x_assign_resources_tbl.FIRST..x_assign_resources_tbl.LAST
    LOOP

      IF (x_assign_resources_tbl(i).resource_type not in ('RS_TEAM', 'RS_GROUP')) THEN

        l_found := 'N';
        OPEN check_mem_cur(p_group_id,
                           x_assign_resources_tbl(i).resource_id);
        FETCH check_mem_cur into l_found;
        CLOSE check_mem_cur;

        IF (l_found = 'Y') THEN

          l_count := l_count + 1;
          l_assign_resource_tbl(l_count).resource_id           := x_assign_resources_tbl(i).resource_id;
          l_assign_resource_tbl(l_count).resource_type         := x_assign_resources_tbl(i).resource_type;
          l_assign_resource_tbl(l_count).terr_rsc_id           := x_assign_resources_tbl(i).terr_rsc_id;
          l_assign_resource_tbl(l_count).role                  := x_assign_resources_tbl(i).role ;
          l_assign_resource_tbl(l_count).start_date            := x_assign_resources_tbl(i).start_date;
          l_assign_resource_tbl(l_count).end_date              := x_assign_resources_tbl(i).end_date;
          l_assign_resource_tbl(l_count).shift_construct_id    := x_assign_resources_tbl(i).shift_construct_id;
          l_assign_resource_tbl(l_count).terr_id               := x_assign_resources_tbl(i).terr_id ;
          l_assign_resource_tbl(l_count).terr_name             := x_assign_resources_tbl(i).terr_name;
	  -- ================code added for bug 6453896=============
	  l_assign_resource_tbl(l_count).terr_rank             := x_assign_resources_tbl(i).terr_rank;
	  -- ================End for addition of code===============
          l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
          l_assign_resource_tbl(l_count).primary_flag          := x_assign_resources_tbl(i).primary_flag;
          l_assign_resource_tbl(l_count).travel_time           := x_assign_resources_tbl(i).travel_time;
          l_assign_resource_tbl(l_count).travel_uom            := x_assign_resources_tbl(i).travel_uom;
          l_assign_resource_tbl(l_count).preference_type       := x_assign_resources_tbl(i).preference_type;
          l_assign_resource_tbl(l_count).full_access_flag      := x_assign_resources_tbl(i).full_access_flag;
          l_assign_resource_tbl(l_count).group_id              := x_assign_resources_tbl(i).group_id;
          l_assign_resource_tbl(l_count).location              := x_assign_resources_tbl(i).location;
          l_assign_resource_tbl(l_count).trans_object_id       := x_assign_resources_tbl(i).trans_object_id;
          l_assign_resource_tbl(l_count).support_site_id       := x_assign_resources_tbl(i).support_site_id;
          l_assign_resource_tbl(l_count).support_site_name     := x_assign_resources_tbl(i).support_site_name;
          l_assign_resource_tbl(l_count).web_availability_flag := x_assign_resources_tbl(i).web_availability_flag;
          l_assign_resource_tbl(l_count).skill_level           := x_assign_resources_tbl(i).skill_level;
          l_assign_resource_tbl(l_count).skill_name            := x_assign_resources_tbl(i).skill_name;
          l_assign_resource_tbl(l_count).resource_source       := x_assign_resources_tbl(i).resource_source;

        END IF;

      /******************** Start of addition by SBARAT on 04/05/2006 for bug# 5205277********************/
      ELSE

          l_count := l_count + 1;
          l_assign_resource_tbl(l_count).resource_id           := x_assign_resources_tbl(i).resource_id;
          l_assign_resource_tbl(l_count).resource_type         := x_assign_resources_tbl(i).resource_type;
          l_assign_resource_tbl(l_count).terr_rsc_id           := x_assign_resources_tbl(i).terr_rsc_id;
          l_assign_resource_tbl(l_count).role                  := x_assign_resources_tbl(i).role ;
          l_assign_resource_tbl(l_count).start_date            := x_assign_resources_tbl(i).start_date;
          l_assign_resource_tbl(l_count).end_date              := x_assign_resources_tbl(i).end_date;
          l_assign_resource_tbl(l_count).shift_construct_id    := x_assign_resources_tbl(i).shift_construct_id;
          l_assign_resource_tbl(l_count).terr_id               := x_assign_resources_tbl(i).terr_id ;
          l_assign_resource_tbl(l_count).terr_name             := x_assign_resources_tbl(i).terr_name;
	  -- ================code added for bug 6453896=============
	  l_assign_resource_tbl(l_count).terr_rank             := x_assign_resources_tbl(i).terr_rank;
	  -- ================End for addition of code===============
          l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
          l_assign_resource_tbl(l_count).primary_flag          := x_assign_resources_tbl(i).primary_flag;
          l_assign_resource_tbl(l_count).travel_time           := x_assign_resources_tbl(i).travel_time;
          l_assign_resource_tbl(l_count).travel_uom            := x_assign_resources_tbl(i).travel_uom;
          l_assign_resource_tbl(l_count).preference_type       := x_assign_resources_tbl(i).preference_type;
          l_assign_resource_tbl(l_count).full_access_flag      := x_assign_resources_tbl(i).full_access_flag;
          l_assign_resource_tbl(l_count).group_id              := x_assign_resources_tbl(i).group_id;
          l_assign_resource_tbl(l_count).location              := x_assign_resources_tbl(i).location;
          l_assign_resource_tbl(l_count).trans_object_id       := x_assign_resources_tbl(i).trans_object_id;
          l_assign_resource_tbl(l_count).support_site_id       := x_assign_resources_tbl(i).support_site_id;
          l_assign_resource_tbl(l_count).support_site_name     := x_assign_resources_tbl(i).support_site_name;
          l_assign_resource_tbl(l_count).web_availability_flag := x_assign_resources_tbl(i).web_availability_flag;
          l_assign_resource_tbl(l_count).skill_level           := x_assign_resources_tbl(i).skill_level;
          l_assign_resource_tbl(l_count).skill_name            := x_assign_resources_tbl(i).skill_name;
          l_assign_resource_tbl(l_count).resource_source       := x_assign_resources_tbl(i).resource_source;

      END IF;
      /******************** End of addition by SBARAT on 04/05/2006 for bug# 5205277********************/

    END LOOP;

    x_assign_resources_tbl.delete;
    x_assign_resources_tbl := l_assign_resource_tbl;
   end if; -- end of count check
  END get_group_resource;





-- *******************************************************************************

-- Start of comments

-- Function       : This procedure is to fetch the Groups and Teams of any
--                  particular USAGE Type.

-- End of comments

-- *******************************************************************************



  PROCEDURE get_usage_resource(p_usage                 IN VARCHAR2,
                               x_assign_resources_tbl  IN OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type)
  IS

    CURSOR grp_usg_cur
           (
             l_group_id IN NUMBER,
             l_usage    IN VARCHAR2
           ) IS
      SELECT 'Y'
        FROM jtf_rs_group_usages
       WHERE group_id = l_group_id
         AND usage    = l_usage;

    CURSOR team_usg_cur
           (
             l_team_id IN NUMBER,
             l_usage   IN VARCHAR2
           ) IS
      SELECT 'Y'
        FROM jtf_rs_team_usages
       WHERE team_id = l_team_id
         AND usage   = l_usage;

    l_found   VARCHAR2(1) := 'N';
    l_count   NUMBER      := 0;
    i         NUMBER      := 0;
    l_assign_resource_tbl JTF_ASSIGN_PUB.AssignResources_tbl_type;

  BEGIN
    i := x_assign_resources_tbl.FIRST;

--    FOR i IN x_assign_resources_tbl.FIRST..x_assign_resources_tbl.COUNT
    WHILE (i <=  x_assign_resources_tbl.LAST)
    LOOP

      IF (x_assign_resources_tbl(i).resource_type in ('RS_TEAM' , 'RS_GROUP')) THEN

        l_found := 'N';
        IF (x_assign_resources_tbl(i).resource_type  = 'RS_GROUP') THEN

           OPEN  grp_usg_cur(x_assign_resources_tbl(i).resource_id,
                             p_usage);
           FETCH grp_usg_cur into l_found;
           CLOSE grp_usg_cur;
        ELSIF (x_assign_resources_tbl(i).resource_type  = 'RS_TEAM') THEN
           OPEN  team_usg_cur( x_assign_resources_tbl(i).resource_id,
                               p_usage);
           FETCH team_usg_cur into l_found;
           CLOSE team_usg_cur;
        END IF;

        IF (l_found = 'Y') THEN

          l_count := l_count + 1;
          l_assign_resource_tbl(l_count).resource_id           := x_assign_resources_tbl(i).resource_id;
          l_assign_resource_tbl(l_count).resource_type         := x_assign_resources_tbl(i).resource_type;
          l_assign_resource_tbl(l_count).terr_rsc_id           := x_assign_resources_tbl(i).terr_rsc_id;
          l_assign_resource_tbl(l_count).role                  := x_assign_resources_tbl(i).role ;
          l_assign_resource_tbl(l_count).start_date            := x_assign_resources_tbl(i).start_date;
          l_assign_resource_tbl(l_count).end_date              := x_assign_resources_tbl(i).end_date;
          l_assign_resource_tbl(l_count).shift_construct_id    := x_assign_resources_tbl(i).shift_construct_id;
          l_assign_resource_tbl(l_count).terr_id               := x_assign_resources_tbl(i).terr_id ;
          l_assign_resource_tbl(l_count).terr_name             := x_assign_resources_tbl(i).terr_name;
          l_assign_resource_tbl(l_count).terr_rank             := x_assign_resources_tbl(i).terr_rank;
          l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
          l_assign_resource_tbl(l_count).primary_flag          := x_assign_resources_tbl(i).primary_flag;
          l_assign_resource_tbl(l_count).travel_time           := x_assign_resources_tbl(i).travel_time;
          l_assign_resource_tbl(l_count).travel_uom            := x_assign_resources_tbl(i).travel_uom;
          l_assign_resource_tbl(l_count).preference_type       := x_assign_resources_tbl(i).preference_type;
          l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
          l_assign_resource_tbl(l_count).full_access_flag      := x_assign_resources_tbl(i).full_access_flag;
          l_assign_resource_tbl(l_count).group_id              := x_assign_resources_tbl(i).group_id;
          l_assign_resource_tbl(l_count).location              := x_assign_resources_tbl(i).location;
          l_assign_resource_tbl(l_count).trans_object_id       := x_assign_resources_tbl(i).trans_object_id;
          l_assign_resource_tbl(l_count).support_site_id       := x_assign_resources_tbl(i).support_site_id;
          l_assign_resource_tbl(l_count).support_site_name     := x_assign_resources_tbl(i).support_site_name;
          l_assign_resource_tbl(l_count).web_availability_flag := x_assign_resources_tbl(i).web_availability_flag;
          l_assign_resource_tbl(l_count).skill_level           := x_assign_resources_tbl(i).skill_level;
          l_assign_resource_tbl(l_count).skill_name            := x_assign_resources_tbl(i).skill_name;
          l_assign_resource_tbl(l_count).resource_source       := x_assign_resources_tbl(i).resource_source;


        END IF;

        i := x_assign_resources_tbl.next(i);

      ELSE
        l_count := l_count + 1;
        l_assign_resource_tbl(l_count).resource_id           := x_assign_resources_tbl(i).resource_id;
        l_assign_resource_tbl(l_count).resource_type         := x_assign_resources_tbl(i).resource_type;
        l_assign_resource_tbl(l_count).terr_rsc_id           := x_assign_resources_tbl(i).terr_rsc_id;
        l_assign_resource_tbl(l_count).role                  := x_assign_resources_tbl(i).role ;
        l_assign_resource_tbl(l_count).start_date            := x_assign_resources_tbl(i).start_date;
        l_assign_resource_tbl(l_count).end_date              := x_assign_resources_tbl(i).end_date;
        l_assign_resource_tbl(l_count).shift_construct_id    := x_assign_resources_tbl(i).shift_construct_id;
        l_assign_resource_tbl(l_count).terr_id               := x_assign_resources_tbl(i).terr_id ;
        l_assign_resource_tbl(l_count).terr_name             := x_assign_resources_tbl(i).terr_name;
        l_assign_resource_tbl(l_count).terr_rank             := x_assign_resources_tbl(i).terr_rank;
        l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
        l_assign_resource_tbl(l_count).primary_flag          := x_assign_resources_tbl(i).primary_flag;
        l_assign_resource_tbl(l_count).travel_time           := x_assign_resources_tbl(i).travel_time;
        l_assign_resource_tbl(l_count).travel_uom            := x_assign_resources_tbl(i).travel_uom;
        l_assign_resource_tbl(l_count).preference_type       := x_assign_resources_tbl(i).preference_type;
        l_assign_resource_tbl(l_count).primary_contact_flag  := x_assign_resources_tbl(i).primary_contact_flag;
        l_assign_resource_tbl(l_count).full_access_flag      := x_assign_resources_tbl(i).full_access_flag;
        l_assign_resource_tbl(l_count).group_id              := x_assign_resources_tbl(i).group_id;
        l_assign_resource_tbl(l_count).location              := x_assign_resources_tbl(i).location;
        l_assign_resource_tbl(l_count).trans_object_id       := x_assign_resources_tbl(i).trans_object_id;
        l_assign_resource_tbl(l_count).support_site_id       := x_assign_resources_tbl(i).support_site_id;
        l_assign_resource_tbl(l_count).support_site_name     := x_assign_resources_tbl(i).support_site_name;
        l_assign_resource_tbl(l_count).web_availability_flag := x_assign_resources_tbl(i).web_availability_flag;
        l_assign_resource_tbl(l_count).skill_level           := x_assign_resources_tbl(i).skill_level;
        l_assign_resource_tbl(l_count).skill_name            := x_assign_resources_tbl(i).skill_name;
        l_assign_resource_tbl(l_count).resource_source       := x_assign_resources_tbl(i).resource_source;


        i := x_assign_resources_tbl.next(i);
      END IF;

    END LOOP;

    x_assign_resources_tbl.delete;
    x_assign_resources_tbl := l_assign_resource_tbl;


  END get_usage_resource;


-- Calendar call to determine availability of a resource
-- The api will be called after Contracts/IB/Territory preferred/qualified resource has been selected
-- The api will be called only when p_calendar_flag = 'Y'. None of the other api's should now call JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT
PROCEDURE get_available_resources
            (
              p_init_msg_list                 IN  VARCHAR2,
              p_calendar_flag                 IN  VARCHAR2,
              p_effort_duration               IN  NUMBER,
              p_effort_uom                    IN  VARCHAR2,
              p_planned_start_date            IN  DATE,
              p_planned_end_date              IN  DATE,
              p_continuous_task               IN  VARCHAR2,
              x_return_status                 IN  OUT NOCOPY VARCHAR2,
              x_msg_count                     IN  OUT NOCOPY NUMBER,
              x_msg_data                      IN  OUT NOCOPY VARCHAR2,
              x_assign_resources_tbl          IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type
            )
  IS


    l_return_status_1               VARCHAR2(10);
    l_api_name                      VARCHAR2(100)  := 'GET_AVAILABLE_RESOURCES';
    l_api_name_1                    VARCHAR2(60)   := 'GET_AVAILABLE_RESOURCES';
    l_api_version                   NUMBER         := 1.0;
    l_status                        VARCHAR2(30);
    l_industry                      VARCHAR2(30);

    l_return_status                 VARCHAR2(10);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);


    l_current_record                INTEGER  := 0;
    l_current_rec                   INTEGER  := 0;
    l_pref_record                   INTEGER  := 0;

    l_travel_time                   NUMBER        := 0;
    l_travel_uom                    VARCHAR2(10)  := 'HR';

    l_x_planned_start_date          DATE;
    l_x_planned_end_date            DATE;
    l_x_shift_construct_id          NUMBER;
    l_x_availability_type           VARCHAR2(60);
    l_uom_hour                      VARCHAR2(200);
    l_effort_duration               NUMBER;

    l_resources_tbl                 JTF_ASSIGN_PUB.AssignResources_tbl_type;



  BEGIN
    -- initialize the variables
    x_return_status := fnd_api.g_ret_sts_success;
    l_current_rec := 0;
    l_resources_tbl.delete;

    -- Added by SBARAT on 21/04/2005 for Bug-4300801
    -- This conversion is done only before calling JTF_CALENDAR_PUB
     /* to handle the conversion of duration to hour */
    l_uom_hour  := nvl(fnd_profile.value('JTF_AM_TASK_HOUR'), 'HR');
    if(nvl(p_effort_uom, l_uom_hour) <> l_uom_hour)
    then
         l_effort_duration :=  inv_convert.inv_um_convert(
                                   item_id => NULL,
                                   precision => 2,
                                   from_quantity => p_effort_duration,
                                   from_unit => p_effort_uom,
                                   to_unit   => l_uom_hour, --'HR',
                                   from_name => NULL,
                                   to_name   => NULL);
    else
        l_effort_duration := p_effort_duration;
    end if;

    -- if the in table has any resources, then this check should continue
    IF x_assign_resources_tbl.COUNT > 0 THEN

      l_current_record := x_assign_resources_tbl.FIRST;

      WHILE l_current_record <= x_assign_resources_tbl.LAST
      LOOP
        -- if the calendar flag = Y then this should continue. This is a doublecheck as the calling api will check this
        -- also
        IF (p_calendar_flag = 'Y') THEN
          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_CALENDAR_PUB';
          l_return_status_1 := x_return_status ;

          -- This api returns the first available slot for the work duration within the available dates
          JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT(
               P_API_VERSION        => l_api_version,
               P_INIT_MSG_LIST      => p_init_msg_list,
               P_RESOURCE_ID        => x_assign_resources_tbl(l_current_record).resource_id,
               P_RESOURCE_TYPE      => x_assign_resources_tbl(l_current_record).resource_type,
               P_START_DATE_TIME    => p_planned_start_date,
               P_END_DATE_TIME      => p_planned_end_date,
               P_DURATION           => l_effort_duration, --p_effort_duration,
               X_RETURN_STATUS      => x_return_status,
               X_MSG_COUNT          => x_msg_count,
               X_MSG_DATA           => x_msg_data,
               X_SLOT_START_DATE    => l_x_planned_start_date,
               X_SLOT_END_DATE      => l_x_planned_end_date,
               X_SHIFT_CONSTRUCT_ID => l_x_shift_construct_id,
               X_AVAILABILITY_TYPE  => l_x_availability_type
            );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Calendar
            fnd_message.set_name('JTF', 'JTF_AM_ERROR_CAL_API');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
			   --  12/22/05 ** MPADHIAR ** Manas padhiary **
			   --  Removed Comment to Show error message Bug # 2919389
               RAISE fnd_api.g_exc_error;
            ELSE
			   RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

          -- Put the records into the PL/SQL Table.
          -- if the returned shift_construct_id is not null then the resource has an available slot.
          IF (l_x_shift_construct_id IS NOT NULL) THEN
              l_resources_tbl(l_current_rec).terr_rsc_id := NULL;
              l_resources_tbl(l_current_rec).resource_id :=
                                    x_assign_resources_tbl(l_current_record).resource_id;
              l_resources_tbl(l_current_rec).resource_type:=
                                   x_assign_resources_tbl(l_current_record).resource_type;
              l_resources_tbl(l_current_rec).role         := NULL;

              IF (l_travel_uom like 'HR%') THEN
                 l_resources_tbl(l_current_rec).start_date :=
                                     l_x_planned_start_date + l_travel_time/24;
                 l_resources_tbl(l_current_rec).end_date   :=
                                     l_x_planned_end_date   + l_travel_time/24;
              ELSIF (l_travel_uom like 'MI%') THEN
                 l_resources_tbl(l_current_rec).start_date :=
                                     l_x_planned_start_date + l_travel_time/1440;
                 l_resources_tbl(l_current_rec).end_date   :=
                                     l_x_planned_end_date   + l_travel_time/1440;
              ELSIF (l_travel_uom like 'S%') THEN
                 l_resources_tbl(l_current_rec).start_date :=
                                     l_x_planned_start_date + l_travel_time/86400;
                 l_resources_tbl(l_current_rec).end_date   :=
                                     l_x_planned_end_date   + l_travel_time/86400;
              END IF;

              l_resources_tbl(l_current_rec).shift_construct_id    := l_x_shift_construct_id;
              l_resources_tbl(l_current_rec).terr_id               := x_assign_resources_tbl(l_current_record).terr_id;
              l_resources_tbl(l_current_rec).terr_name             := x_assign_resources_tbl(l_current_record).terr_name;
	      -- ================code added for bug 6453896=============
              l_resources_tbl(l_current_rec).terr_rank             := x_assign_resources_tbl(l_current_record).terr_rank;
	      -- ================End for addition of code===============
              l_resources_tbl(l_current_rec).preference_type       := x_assign_resources_tbl(l_current_record).preference_type;
              l_resources_tbl(l_current_rec).primary_flag          := x_assign_resources_tbl(l_current_record).primary_flag;
              l_resources_tbl(l_current_rec).primary_contact_flag  := x_assign_resources_tbl(l_current_record).primary_contact_flag;
              l_resources_tbl(l_current_rec).full_access_flag      := x_assign_resources_tbl(l_current_record).full_access_flag;
              l_resources_tbl(l_current_rec).group_id              := x_assign_resources_tbl(l_current_record).group_id;
              l_resources_tbl(l_current_rec).location              := x_assign_resources_tbl(l_current_record).location;
              l_resources_tbl(l_current_rec).trans_object_id       := x_assign_resources_tbl(l_current_record).trans_object_id;
              l_resources_tbl(l_current_rec).support_site_id       := x_assign_resources_tbl(l_current_record).support_site_id;
              l_resources_tbl(l_current_rec).support_site_name     := x_assign_resources_tbl(l_current_record).support_site_name;
              l_resources_tbl(l_current_rec).web_availability_flag := x_assign_resources_tbl(l_current_record).web_availability_flag;
              l_resources_tbl(l_current_rec).skill_level           := x_assign_resources_tbl(l_current_record).skill_level;
              l_resources_tbl(l_current_rec).skill_name            := x_assign_resources_tbl(l_current_record).skill_name;
              l_resources_tbl(l_current_rec).resource_source        := x_assign_resources_tbl(l_current_record).resource_source;

              l_current_rec := l_current_rec + 1;
          END IF; -- End of shift_construct_id not null check

        END IF; -- Calendar Flag is NO

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;

      -- assign the available resources back to the out table
      x_assign_resources_tbl.delete;
      x_assign_resources_tbl := l_resources_tbl;

    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END get_available_resources;


  -- Overloaded procedure for calendar call
-- The api will be called after Contracts/IB/Territory preferred/qualified resource has been selected
-- The api will be called only when p_calendar_flag = 'Y'. None of the other api's should now call JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT
PROCEDURE get_available_resources
            (
              p_init_msg_list                 IN  VARCHAR2,
              p_calendar_flag                 IN  VARCHAR2,
              p_effort_duration               IN  NUMBER,
              p_effort_uom                    IN  VARCHAR2,
              p_breakdown                     IN  NUMBER,
              p_breakdown_uom                 IN  VARCHAR2,
              p_planned_start_date            IN  DATE,
              p_planned_end_date              IN  DATE,
              p_continuous_task               IN  VARCHAR2,
              x_return_status                 IN  OUT NOCOPY VARCHAR2,
              x_msg_count                     IN  OUT NOCOPY NUMBER,
              x_msg_data                      IN  OUT NOCOPY VARCHAR2,
              x_assign_resources_tbl          IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
	      --Added for Bug # 5573916
	      p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	      --Added for Bug # 5573916 Ends here
            )
  IS


    l_return_status_1               VARCHAR2(10);
    l_api_name                      VARCHAR2(100)  := 'GET_AVAILABLE_RESOURCES';
    l_api_name_1                    VARCHAR2(60)   := 'GET_AVAILABLE_RESOURCES';
    l_api_version                   NUMBER         := 1.0;
    l_status                        VARCHAR2(30);
    l_industry                      VARCHAR2(30);

    l_return_status                 VARCHAR2(10);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);


    l_current_record                INTEGER  := 0;
    l_current_rec                   INTEGER  := 0;
    l_pref_record                   INTEGER  := 0;

    l_travel_time                   NUMBER        := 0;
    l_travel_uom                    VARCHAR2(10)  := 'HR';

    l_x_planned_start_date          DATE;
    l_x_planned_end_date            DATE;
    l_x_shift_construct_id          NUMBER;
    l_x_availability_type           VARCHAR2(60);

    l_resources_tbl                 JTF_ASSIGN_PUB.AssignResources_tbl_type;

     TYPE l_slots_rec               IS RECORD
    (slot_value                     NUMBER);

    Type l_slots_tbl               IS TABLE of l_slots_rec
                                   INDEX BY BINARY_INTEGER;
    l_slots                        l_slots_tbl;

    l_effort_duration              NUMBER := p_effort_duration;
    l_effort_duration_1            NUMBER := p_effort_duration;
    l_breakdown                    NUMBER := p_breakdown;
    i                              NUMBER ;
    l_temp_start_date              DATE;
    l_temp_end_date                DATE;
    l_avail_count                  NUMBER;
    l_uom_hour                     VARCHAR2(200);
    l_avail_resource               JTF_ASSIGN_PUB.Avail_tbl_type;
    l_temp_count                   NUMBER := 0;
    l_planned_end_date             DATE;


    /*procedure ts(v varchar2)
    is
      pragma autonomous_transaction;
    begin
      insert into test_values values(v);
      commit;
    end;*/
  BEGIN
    -- initialize the variables
    x_return_status := fnd_api.g_ret_sts_success;
    l_current_rec := 0;
    l_resources_tbl.delete;
    JTF_ASSIGN_PUB.g_resource_avail.delete;


    /* to handle the conversion of duration to hour */
    l_uom_hour  := nvl(fnd_profile.value('JTF_AM_TASK_HOUR'), 'HR');



    if(nvl(p_effort_uom, l_uom_hour) <> l_uom_hour)
    then
         l_effort_duration :=  inv_convert.inv_um_convert(
                                   item_id => NULL,
                                   precision => 2,
                                   from_quantity => p_effort_duration,
                                   from_unit => p_effort_uom,
                                   to_unit   => l_uom_hour, --'HR',
                                   from_name => NULL,
                                   to_name   => NULL);
    else

         l_effort_duration := p_effort_duration;

    end if;

    l_effort_duration := nvl(l_effort_duration, 1);


     /* to handle the conversion of breakdown duration to hour */
    if(nvl(p_breakdown_uom, l_uom_hour) <> l_uom_hour)
        AND p_breakdown is not null
    then
         l_breakdown :=  inv_convert.inv_um_convert(
                                   item_id => NULL,
                                   precision => 2,
                                   from_quantity => p_breakdown,
                                   from_unit => p_breakdown_uom,
                                   to_unit   => l_uom_hour, --'HR',
                                   from_name => NULL,
                                   to_name   => NULL);
    else
        l_breakdown := p_breakdown;
    end if;

    -- if the in table has any resources, then this check should continue
    IF x_assign_resources_tbl.COUNT > 0 THEN
	--Added for Bug # 5573916
	--Calendar check won't be done if p_calendar_check = 'N' Where as p_calendar_flag will be continued to used as
	--filter resource based on available calendar time slot
	IF (p_calendar_check  = 'N') THEN
             l_current_rec := x_assign_resources_tbl.FIRST;
	     WHILE l_current_rec <= x_assign_resources_tbl.LAST
		  LOOP
		    x_assign_resources_tbl(l_current_rec).terr_rsc_id           := NULL;
		    x_assign_resources_tbl(l_current_rec).role                  := NULL;
		    x_assign_resources_tbl(l_current_rec).start_date            := NULL;
		    x_assign_resources_tbl(l_current_rec).end_date              := NULL;
		    x_assign_resources_tbl(l_current_rec).shift_construct_id    := NULL;
		    l_current_rec := l_current_rec + 1;
             END LOOP;
	ELSE
        --Added for Bug # 5573916 Ends here

    -- break up the duration if breakdown is given
    IF( (p_breakdown is not null) and (nvl(l_breakdown , 0) > 0) AND (nvl(l_breakdown,0) < l_effort_duration))
    THEN
       l_effort_duration_1 := l_effort_duration;
       i := 0;
       While (l_effort_duration_1 > 0)
       LOOP
          l_slots(i).slot_value := l_breakdown;
          l_effort_duration_1 := l_effort_duration_1 - l_breakdown;
          IF(l_effort_duration_1 > l_breakdown)
          THEN
              l_breakdown := l_breakdown;
          ELSE
              l_breakdown := l_effort_duration_1;
          END IF;
          i := i + 1;
        END LOOP;  -- end of l_effort_duration check
     END IF; -- end of breakdown check


     IF(l_effort_duration <= nvl(l_breakdown,l_effort_duration))
     THEN

       l_current_record := x_assign_resources_tbl.FIRST;
       l_avail_count    := 0;
       jtf_assign_pub.g_resource_avail.delete;




      IF p_planned_start_date=p_planned_end_date
      then
              l_planned_end_date := p_planned_start_date + 1/86400;
              l_effort_duration := 1/86400;
      else
         l_planned_end_date := p_planned_end_date;
      end if;

       WHILE l_current_record <= x_assign_resources_tbl.LAST
       LOOP
        -- if the calendar flag = Y then this should continue. This is a doublecheck as the calling api will check this
        -- also
        -- Irrespective of whether the calendar flag is Y or N
        -- IF (p_calendar_flag = 'Y') THEN
        -- change the API Name temporarily so that in case of unexpected error
        -- it is properly caught
          l_api_name := l_api_name||'-JTF_CALENDAR_PUB';
          l_return_status_1 := x_return_status ;

          -- This api returns the first available slot for the work duration within the available dates




          JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT
            (
               P_API_VERSION        => l_api_version,
               P_INIT_MSG_LIST      => p_init_msg_list,
               P_RESOURCE_ID        => x_assign_resources_tbl(l_current_record).resource_id,
               P_RESOURCE_TYPE      => x_assign_resources_tbl(l_current_record).resource_type,
               P_START_DATE_TIME    => p_planned_start_date,
               P_END_DATE_TIME      => l_planned_end_date,
               P_DURATION           => l_effort_duration,
               X_RETURN_STATUS      => x_return_status,
               X_MSG_COUNT          => x_msg_count,
               X_MSG_DATA           => x_msg_data,
               X_SLOT_START_DATE    => l_x_planned_start_date,
               X_SLOT_END_DATE      => l_x_planned_end_date,
               X_SHIFT_CONSTRUCT_ID => l_x_shift_construct_id,
               X_AVAILABILITY_TYPE  => l_x_availability_type
            );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Calendar
            fnd_message.set_name('JTF', 'JTF_AM_ERROR_CAL_API');
            fnd_msg_pub.add;

            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              --  12/22/05 ** MPADHIAR ** Manas padhiary **
			  --  Removed Comment to Show error message Bug # 2919389
			  RAISE fnd_api.g_exc_error;

            ELSE
			  RAISE fnd_api.g_exc_unexpected_error;

            END IF;
          END IF;

          -- Put the records into the PL/SQL Table.
          -- if the returned shift_construct_id is not null then the resource has an available slot.
          IF (l_x_shift_construct_id IS NOT NULL) THEN
              l_resources_tbl(l_current_rec).terr_rsc_id := NULL;
              l_resources_tbl(l_current_rec).resource_id :=
                                    x_assign_resources_tbl(l_current_record).resource_id;
              l_resources_tbl(l_current_rec).resource_type:=
                                   x_assign_resources_tbl(l_current_record).resource_type;
              l_resources_tbl(l_current_rec).role         := NULL;

              IF (l_travel_uom like 'HR%') THEN
                 l_resources_tbl(l_current_rec).start_date :=
                                     l_x_planned_start_date + l_travel_time/24;
                 l_resources_tbl(l_current_rec).end_date   :=
                                     l_x_planned_end_date   + l_travel_time/24;
              ELSIF (l_travel_uom like 'MI%') THEN
                 l_resources_tbl(l_current_rec).start_date :=
                                     l_x_planned_start_date + l_travel_time/1440;
                 l_resources_tbl(l_current_rec).end_date   :=
                                     l_x_planned_end_date   + l_travel_time/1440;
              ELSIF (l_travel_uom like 'S%') THEN
                 l_resources_tbl(l_current_rec).start_date :=
                                     l_x_planned_start_date + l_travel_time/86400;
                 l_resources_tbl(l_current_rec).end_date   :=
                                     l_x_planned_end_date   + l_travel_time/86400;
              END IF;

              l_resources_tbl(l_current_rec).shift_construct_id    := l_x_shift_construct_id;
              l_resources_tbl(l_current_rec).terr_id               := x_assign_resources_tbl(l_current_record).terr_id;
              l_resources_tbl(l_current_rec).terr_name             := x_assign_resources_tbl(l_current_record).terr_name;
	      -- ================code added for bug 6453896=============
              l_resources_tbl(l_current_rec).terr_rank             := x_assign_resources_tbl(l_current_record).terr_rank;
	      -- ================End for addition of code===============
              l_resources_tbl(l_current_rec).preference_type       := x_assign_resources_tbl(l_current_record).preference_type;
              l_resources_tbl(l_current_rec).primary_flag          := x_assign_resources_tbl(l_current_record).primary_flag;
              l_resources_tbl(l_current_rec).primary_contact_flag  := x_assign_resources_tbl(l_current_record).primary_contact_flag;
              l_resources_tbl(l_current_rec).full_access_flag      := x_assign_resources_tbl(l_current_record).full_access_flag;
              l_resources_tbl(l_current_rec).group_id              := x_assign_resources_tbl(l_current_record).group_id;
              l_resources_tbl(l_current_rec).location              := x_assign_resources_tbl(l_current_record).location;
              l_resources_tbl(l_current_rec).trans_object_id       := x_assign_resources_tbl(l_current_record).trans_object_id;
              l_resources_tbl(l_current_rec).support_site_id       := x_assign_resources_tbl(l_current_record).support_site_id;
              l_resources_tbl(l_current_rec).support_site_name     := x_assign_resources_tbl(l_current_record).support_site_name;
              l_resources_tbl(l_current_rec).web_availability_flag := x_assign_resources_tbl(l_current_record).web_availability_flag;
              l_resources_tbl(l_current_rec).skill_level           := x_assign_resources_tbl(l_current_record).skill_level;
              l_resources_tbl(l_current_rec).skill_name            := x_assign_resources_tbl(l_current_record).skill_name;
              l_resources_tbl(l_current_rec).resource_source       := x_assign_resources_tbl(l_current_record).resource_source;

              -- assign values to availability table
              JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).resource_id        := l_resources_tbl(l_current_rec).resource_id;
              JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).resource_type      := l_resources_tbl(l_current_rec).resource_type;
              JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).start_date         := l_resources_tbl(l_current_rec).start_date;
              JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).end_date           := l_resources_tbl(l_current_rec).end_date;
              JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).shift_construct_id := l_resources_tbl(l_current_rec).shift_construct_id;

              l_current_rec := l_current_rec + 1;
              l_avail_count := l_avail_count + 1;

          -- added the else part to return null if the resource does not have a shift also
          ELSE
              l_resources_tbl(l_current_rec).terr_rsc_id           := NULL;
              l_resources_tbl(l_current_rec).resource_id           := x_assign_resources_tbl(l_current_record).resource_id;
              l_resources_tbl(l_current_rec).resource_type         := x_assign_resources_tbl(l_current_record).resource_type;
              l_resources_tbl(l_current_rec).role                  := NULL;
              l_resources_tbl(l_current_rec).start_date            := NULL;
              l_resources_tbl(l_current_rec).end_date              := NULL;
              l_resources_tbl(l_current_rec).shift_construct_id    := NULL;
              l_resources_tbl(l_current_rec).terr_id               := x_assign_resources_tbl(l_current_record).terr_id;
              l_resources_tbl(l_current_rec).terr_name             := x_assign_resources_tbl(l_current_record).terr_name;
	      -- ================code added for bug 6453896=============
              l_resources_tbl(l_current_rec).terr_rank             := x_assign_resources_tbl(l_current_record).terr_rank;
	      -- ================End for addition of code===============
              l_resources_tbl(l_current_rec).preference_type       := x_assign_resources_tbl(l_current_record).preference_type;
              l_resources_tbl(l_current_rec).primary_flag          := x_assign_resources_tbl(l_current_record).primary_flag;
              l_resources_tbl(l_current_rec).primary_contact_flag  := x_assign_resources_tbl(l_current_record).primary_contact_flag;
              l_resources_tbl(l_current_rec).full_access_flag      := x_assign_resources_tbl(l_current_record).full_access_flag;
              l_resources_tbl(l_current_rec).group_id              := x_assign_resources_tbl(l_current_record).group_id;
              l_resources_tbl(l_current_rec).location              := x_assign_resources_tbl(l_current_record).location;
              l_resources_tbl(l_current_rec).trans_object_id       := x_assign_resources_tbl(l_current_record).trans_object_id;
              l_resources_tbl(l_current_rec).support_site_id       := x_assign_resources_tbl(l_current_record).support_site_id;
              l_resources_tbl(l_current_rec).support_site_name     := x_assign_resources_tbl(l_current_record).support_site_name;
              l_resources_tbl(l_current_rec).web_availability_flag := x_assign_resources_tbl(l_current_record).web_availability_flag;
              l_resources_tbl(l_current_rec).skill_level           := x_assign_resources_tbl(l_current_record).skill_level;
              l_resources_tbl(l_current_rec).skill_name            := x_assign_resources_tbl(l_current_record).skill_name;
              l_resources_tbl(l_current_rec).resource_source       := x_assign_resources_tbl(l_current_record).resource_source;

              l_current_rec := l_current_rec + 1;
          END IF; -- End of shift_construct_id not null check

        --END IF; -- Calendar Flag is NO

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;

      -- assign the available resources back to the out table
      x_assign_resources_tbl.delete;
      -- if calendar flag is Y then filter out the resources that do not have a available slot.

     IF (p_calendar_flag = 'Y') THEN
       l_current_rec := l_resources_tbl.first;
       l_current_record := 0;
       While(l_current_rec <= l_resources_tbl.LAST)
       Loop
         IF(l_resources_tbl(l_current_rec).shift_construct_id is not null)
         THEN
             x_assign_resources_tbl(l_current_record) := l_resources_tbl(l_current_rec);

             l_current_record := l_current_record + 1;
         END IF;
         l_current_rec  := l_current_rec + 1;
       END LOOP;

      ELSE  -- check p_calendar flag = Y
         -- else pass back all resources
         x_assign_resources_tbl := l_resources_tbl;
          l_api_name := l_api_name||'-JTF_CALENDAR_PUB';
          l_return_status_1 := x_return_status ;
      END IF; -- check p_calendar flag = Y

     ELSE -- check for l_effort_duration <= l_breakdown
     -- new logic to get resources when work has been broken down into seperate slots
      l_current_rec := x_assign_resources_tbl.first;
      l_avail_count     := 0;
      While(l_current_rec <= x_assign_resources_tbl.last)
      LOOP
          l_temp_start_date := p_planned_start_date;
          l_temp_end_date   := p_planned_end_date;

          FOR i in l_slots.first..l_slots.last
          LOOP
             l_api_name        := l_api_name||'-JTF_CALENDAR_PUB';
             l_return_status_1 := x_return_status ;

              l_x_shift_construct_id := null;
              l_x_planned_start_date := null;
              l_x_planned_end_date   := null;
              l_x_availability_type  := null;
             -- This api returns the first available slot for the work duration within the available dates
             JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT
              (
               P_API_VERSION        => l_api_version,
               P_INIT_MSG_LIST      => p_init_msg_list,
               P_RESOURCE_ID        => x_assign_resources_tbl(l_current_rec).resource_id,
               P_RESOURCE_TYPE      => x_assign_resources_tbl(l_current_rec).resource_type,
               P_START_DATE_TIME    => l_temp_start_date,
               P_END_DATE_TIME      => l_temp_end_date,
               P_DURATION           => l_slots(i).slot_value,
               X_RETURN_STATUS      => x_return_status,
               X_MSG_COUNT          => x_msg_count,
               X_MSG_DATA           => x_msg_data,
               X_SLOT_START_DATE    => l_x_planned_start_date,
               X_SLOT_END_DATE      => l_x_planned_end_date,
               X_SHIFT_CONSTRUCT_ID => l_x_shift_construct_id,
               X_AVAILABILITY_TYPE  => l_x_availability_type
              );
--dbms_output.put_line('Slots are ...'||to_char(l_slots(i).slot_value)||'...'||to_char(l_x_planned_start_date, 'DD-MON-YYYY HH24:MI'));
--dbms_output.put_line('Slots are ...'||to_char(x_assign_resources_tbl(l_current_rec).resource_id)||'...'||to_char(l_x_planned_end_date, 'DD-MON-YYYY HH24:MI'));
            -- set back the API name to original name
            l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Calendar
               fnd_message.set_name('JTF', 'JTF_AM_ERROR_CAL_API');
               fnd_msg_pub.add;
               IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  --  12/22/05 ** MPADHIAR ** Manas padhiary **
				  --  Removed Comment to Show error message Bug # 2919389
				  RAISE fnd_api.g_exc_error;

               ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;
            if(l_x_shift_construct_id is not null)
            then
               JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).resource_id        := x_assign_resources_tbl(l_current_rec).resource_id;
               JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).resource_type      :=x_assign_resources_tbl(l_current_rec).resource_type;
               JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).start_date         :=  l_x_planned_start_date;
               JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).end_date           :=  l_x_planned_end_date;
               JTF_ASSIGN_PUB.g_resource_avail(l_avail_count).shift_construct_id := l_x_shift_construct_id;
               l_avail_count     := l_avail_count + 1;
               l_temp_start_date := l_x_planned_end_date;
               l_temp_end_date   := p_planned_end_date;
            else
              -- remove the available slots for the resource
               l_temp_count := 0;
               FOR k in JTF_ASSIGN_PUB.g_resource_avail.first..JTF_ASSIGN_PUB.g_resource_avail.last
               LOOP
                 IF(JTF_ASSIGN_PUB.g_resource_avail(k).resource_id = x_assign_resources_tbl(l_current_rec).resource_id
                    AND JTF_ASSIGN_PUB.g_resource_avail(k).resource_type = x_assign_resources_tbl(l_current_rec).resource_type)
                 THEN
                     null ; --l_avail_count := l_avail_count - 1;
                 ELSE
                    l_avail_resource(l_temp_count) := JTF_ASSIGN_PUB.g_resource_avail(k);
                    l_temp_count := l_temp_count + 1;
                 END IF;
               END LOOP;
               JTF_ASSIGN_PUB.g_resource_avail.delete;
               JTF_ASSIGN_PUB.g_resource_avail :=  l_avail_resource;
               l_avail_count := JTF_ASSIGN_PUB.g_resource_avail.last + 1;
               exit;
             end if; -- end of l_x_shift_contruct_id check

          END LOOP; -- end of check for l_slots
          l_current_rec := l_current_rec + 1;
      END LOOP; -- end of l_current_rec check

      IF (p_calendar_flag = 'Y') THEN
         l_current_rec := x_assign_resources_tbl.first;
         l_current_record := 0;
         While(l_current_rec <= x_assign_resources_tbl.LAST)
         Loop
           -- remove records that are not there in g_avail_resource
            FOR i IN JTF_ASSIGN_PUB.g_resource_avail.first..JTF_ASSIGN_PUB.g_resource_avail.last
             LOOP
               IF(JTF_ASSIGN_PUB.g_resource_avail(i).resource_id = x_assign_resources_tbl(l_current_rec).resource_id
                AND JTF_ASSIGN_PUB.g_resource_avail(i).resource_type = x_assign_resources_tbl(l_current_rec).resource_type)
              THEN
                 l_resources_tbl(l_current_record) := x_assign_resources_tbl(l_current_rec);
                 l_resources_tbl(l_current_record).shift_construct_id := JTF_ASSIGN_PUB.g_resource_avail(i).shift_construct_id;
                 l_resources_tbl(l_current_record).start_date := JTF_ASSIGN_PUB.g_resource_avail(i).start_date;
                 l_resources_tbl(l_current_record).end_date := JTF_ASSIGN_PUB.g_resource_avail(i).end_date;
                 l_current_record := l_current_record + 1;
                 exit;
               END IF;
             END LOOP; -- end of loop for i in g_resource_avail first to last
             l_current_rec  := l_current_rec + 1;
          END LOOP;
          x_assign_resources_tbl.delete;
          l_current_rec := l_resources_tbl.first;
          l_current_record := 0;
          While(l_current_rec <= l_resources_tbl.LAST)
          Loop
            x_assign_resources_tbl(l_current_record) := l_resources_tbl(l_current_rec);
            l_current_rec  := l_current_rec + 1;
            l_current_record  := l_current_record + 1;
          END LOOP;

        ELSE  -- check p_calendar flag = Y
         -- else pass back all resources with the start date and end dates of resources with first availability slot dates
           l_current_rec := x_assign_resources_tbl.first;
           While(l_current_rec <= x_assign_resources_tbl.LAST
                AND JTF_ASSIGN_PUB.g_resource_avail.count > 0)
           Loop
           -- remove records that are not there in g_avail_resource
              FOR i IN JTF_ASSIGN_PUB.g_resource_avail.first..JTF_ASSIGN_PUB.g_resource_avail.last
              LOOP
                IF(JTF_ASSIGN_PUB.g_resource_avail(i).resource_id = x_assign_resources_tbl(l_current_rec).resource_id
                  AND JTF_ASSIGN_PUB.g_resource_avail(i).resource_type = x_assign_resources_tbl(l_current_rec).resource_type)
                THEN
                    x_assign_resources_tbl(l_current_rec).shift_construct_id := JTF_ASSIGN_PUB.g_resource_avail(i).shift_construct_id;
                    x_assign_resources_tbl(l_current_rec).start_date         := JTF_ASSIGN_PUB.g_resource_avail(i).start_date;
                    x_assign_resources_tbl(l_current_rec).end_date           := JTF_ASSIGN_PUB.g_resource_avail(i).end_date;
                    exit;
                END IF;
              END LOOP; -- end of loop for i in g_resource_avail first to last
              IF(x_assign_resources_tbl(l_current_rec).shift_construct_id IS NULL)
              THEN
                    x_assign_resources_tbl(l_current_rec).start_date   := NULL;
                    x_assign_resources_tbl(l_current_rec).end_date     := NULL;
              END IF;
              l_current_rec  := l_current_rec + 1;
           END LOOP;  -- end of l_current_rec check
         END IF; -- check p_calendar flag = Y
     END IF; -- check for p_effort_duration <= p_breakdown
   --Added for Bug # 5573916
   END IF;
   --Added for Bug # 5573916 Ends here
 END IF;  -- if x_assign_resurces_tbl count > 0 check

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END get_available_resources;





-- *******************************************************************************

--  Start of comments

--  Function       : This procedure is to fetch the Contracts Preferred Resources.
--                   This passes out the table of records with the resources.

--  End of comments

-- *******************************************************************************


  PROCEDURE get_contracts_resources
            (
              p_init_msg_list                 IN  VARCHAR2,
              p_contract_id                   IN  NUMBER,
              p_calendar_flag                 IN  VARCHAR2,
              p_effort_duration               IN  NUMBER,
              p_effort_uom                    IN  VARCHAR2,
              p_planned_start_date            IN  DATE,
              p_planned_end_date              IN  DATE,
              p_resource_type                 IN  VARCHAR2,
              p_business_process_id           IN  NUMBER,
              p_business_process_date         IN  DATE,
              x_return_status                 IN  OUT NOCOPY VARCHAR2,
              x_msg_count                     IN  OUT NOCOPY NUMBER,
              x_msg_data                      IN  OUT NOCOPY VARCHAR2,
              x_assign_resources_tbl          IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
              x_excluded_tbl                  IN  OUT NOCOPY JTF_ASSIGN_PUB.excluded_tbl_type,
	      --Added for Bug # 5573916
	      p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	      --Added for Bug # 5573916 Ends here
            )
  IS

   -- For bug# 5261565. Checking only whether 'OKS' is installed or not.
   -- This is the product that should be minimum installed at the site
   -- to get back the resources from contract setup. Don't need to check
   -- 'OKC' and 'OKL'. Got it confirmed from Contract team as well.

    CURSOR cur_contracts_installed IS
      SELECT application_id
        FROM fnd_application
       WHERE application_short_name = 'OKS';  -- IN ('OKC', 'OKL', 'OKS');
    l_cur_contracts_installed cur_contracts_installed%ROWTYPE;

    l_return_status_1               VARCHAR2(10);
    l_api_name                      VARCHAR2(100)  := 'GET_CONTRACTS_RESOURCES';
    l_api_name_1                    VARCHAR2(60)  := 'GET_CONTRACTS_RESOURCES';
    l_api_version                   NUMBER        := 1.0;
    l_status                        VARCHAR2(30);
    l_industry                      VARCHAR2(30);

    l_return_status                 VARCHAR2(10);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);

    l_engineer_id                   JTF_NUMBER_TABLE;
    l_resource_type                 JTF_VARCHAR2_TABLE_100;
    l_primary_flag                  JTF_VARCHAR2_TABLE_100;
    l_resource_class                JTF_VARCHAR2_TABLE_100;

    l_current_record                INTEGER  := 0;
    l_current_rec                   INTEGER  := 0;
    l_pref_record                   INTEGER  := 0;

    l_travel_time                   NUMBER        := 0;
    l_travel_uom                    VARCHAR2(10)  := 'HR';

    l_x_planned_start_date          DATE;
    l_x_planned_end_date            DATE;
    l_x_shift_construct_id          NUMBER;
    l_x_availability_type           VARCHAR2(60);

    l_con_preferred_engineers_tbl   JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_preferred_engineers_tbl       JTF_ASSIGN_PUB.Preferred_Engineers_tbl_type;

    l_business_process_date         DATE    := p_business_process_date;
    l_excl_record                   NUMBER  := 0;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    OPEN  cur_contracts_installed;
    FETCH cur_contracts_installed INTO l_cur_contracts_installed;
    CLOSE cur_contracts_installed;

    -- default the date to sysdate if it is null
    IF(p_business_process_id is not null and p_business_process_date is null)
    THEN
       l_business_process_date := sysdate;
    END IF;

    IF (l_cur_contracts_installed.application_id IS NULL) THEN
      fnd_message.set_name('JTF', 'JTF_AM_CONTRACTS_NOT_INSTALLED');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    ELSE

      IF FND_INSTALLATION.GET
           (
              l_cur_contracts_installed.application_id,
              l_cur_contracts_installed.application_id,
              l_status,
              l_industry
           ) THEN
        IF ( UPPER(l_status) <> 'I' ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_CONTRACTS_NOT_INSTALLED');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        fnd_message.set_name('JTF', 'JTF_AM_CONTRACTS_NOT_INSTALLED');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF(x_excluded_tbl.count > 0)
    THEN
       l_excl_record    := x_excluded_tbl.last + 1;
   ELSE
       l_excl_record    := 0;
    END IF;


    IF (p_contract_id IS NOT NULL) THEN

        /*  Also at a later point of time add code to check
            for coverage start and end dates */

      EXECUTE IMMEDIATE
      '
      DECLARE

        l_con_preferred_engineers_tbl  OKS_ENTITLEMENTS_PUB.prfeng_tbl_type;
        l_engineer_id                  JTF_NUMBER_TABLE;
        l_resource_type                JTF_VARCHAR2_TABLE_100;
        l_primary_flag                 JTF_VARCHAR2_TABLE_100;
        l_resource_class               JTF_VARCHAR2_TABLE_100;
        l_return_status                VARCHAR2(10);
        l_msg_count                    NUMBER;
        l_msg_data                     VARCHAR2(2000);

        l_ddindx BINARY_INTEGER;
        l_indx   BINARY_INTEGER;

      BEGIN

        OKS_ENTITLEMENTS_PUB.Get_Preferred_Engineers
        (
           p_api_version         => :1,
           p_init_msg_list       => :2,
           p_contract_line_id    => :3,
           p_business_process_id => :9,
           p_request_date        => :10,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data,
           x_prf_engineers       => l_con_preferred_engineers_tbl
        );

        :4 := l_msg_count;
        :5 := l_msg_data;
        :6 := l_return_status;


        IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Contracts API
          fnd_message.set_name('||''''||'JTF'||''''||','||''''||'JTF_AM_ERROR_CONTRACTS_API'||''''||');'||
         'fnd_msg_pub.add;
            IF (l_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        /* Procedure for Copying out the TABLE contents
           INTO local variables to process */

        IF l_con_preferred_engineers_tbl IS NULL OR
           l_con_preferred_engineers_tbl.count = 0 THEN
          l_engineer_id     := JTF_NUMBER_TABLE();
          l_resource_type   := JTF_VARCHAR2_TABLE_100();
          l_primary_flag    := JTF_VARCHAR2_TABLE_100();
          l_resource_class  := JTF_VARCHAR2_TABLE_100();

        ELSE
          l_engineer_id     := JTF_NUMBER_TABLE();
          l_resource_type   := JTF_VARCHAR2_TABLE_100();
          l_primary_flag    := JTF_VARCHAR2_TABLE_100();
          l_resource_class  := JTF_VARCHAR2_TABLE_100();

          IF l_con_preferred_engineers_tbl.count > 0 THEN
            l_engineer_id.extend(l_con_preferred_engineers_tbl.count);
            l_resource_type.extend(l_con_preferred_engineers_tbl.count);
            l_primary_flag.extend(l_con_preferred_engineers_tbl.count);
            l_resource_class.extend(l_con_preferred_engineers_tbl.count);

            l_ddindx := l_con_preferred_engineers_tbl.first;
            l_indx   := 1;
            WHILE true LOOP
              l_engineer_id(l_indx)     := l_con_preferred_engineers_tbl(l_ddindx).engineer_id;
              l_resource_type(l_indx)   := l_con_preferred_engineers_tbl(l_ddindx).resource_type;
              l_primary_flag(l_indx)    := l_con_preferred_engineers_tbl(l_ddindx).primary_flag;
              l_resource_class(l_indx)  := l_con_preferred_engineers_tbl(l_ddindx).resource_class;

              l_indx := l_indx+1;

              IF l_con_preferred_engineers_tbl.last = l_ddindx THEN
                exit;
              END IF;

              l_ddindx := l_con_preferred_engineers_tbl.next(l_ddindx);
            END LOOP;
          END IF;
        END IF;

        :7 := l_engineer_id;
        :8 := l_resource_type;
        :11 := l_primary_flag;
        :12 := l_resource_class;

      END;
      '
      USING IN  l_api_version,
            IN  p_init_msg_list,
            IN  p_contract_id,
            IN  p_business_process_id,
            IN  l_business_process_date,
            OUT l_msg_count,
            OUT l_msg_data,
            OUT l_return_status,
            OUT l_engineer_id,
            OUT l_resource_type,
            OUT l_primary_flag,
            OUT l_resource_class;

      table_copy_in ( l_engineer_id,
                      l_resource_type,
                      l_primary_flag,
                      l_resource_class,
                      l_con_preferred_engineers_tbl
                    );

      x_return_status  := l_return_status;
      x_msg_count      := l_msg_count;
      x_msg_data       := l_msg_data;

    END IF; -- p_contract_id IS NOT NULL


    l_pref_record := 0;
    If(x_excluded_tbl.count > 0)
    THEN
       l_excl_record := x_excluded_tbl.last + 1;
    ELSE
       l_excl_record := 0;
    END IF;


    IF ( l_con_preferred_engineers_tbl.COUNT > 0 ) THEN

      l_current_record := l_con_preferred_engineers_tbl.FIRST;

      WHILE l_current_record <= l_con_preferred_engineers_tbl.LAST
      LOOP
       IF(l_con_preferred_engineers_tbl(l_current_record).resource_class in ('P', 'R'))
       THEN
          IF(
            ((p_resource_type = 'RS_INDIVIDUAL' OR p_resource_type is null)
              AND (l_con_preferred_engineers_tbl(l_current_record).resource_type in ('RS_EMPLOYEE',
                                                                                     'RS_PARTY',
                                                                                     'RS_PARTNER')))
            OR ((p_resource_type = 'RS_GROUP' OR p_resource_type is null)
                 AND (l_con_preferred_engineers_tbl(l_current_record).resource_type = 'RS_GROUP'))
            OR ((p_resource_type = 'RS_TEAM' OR p_resource_type is null)
                 AND (l_con_preferred_engineers_tbl(l_current_record).resource_type = 'RS_TEAM'))
            ) THEN
              l_pref_record    := l_pref_record + 1;
              l_preferred_engineers_tbl(l_pref_record).engineer_id     :=
                                        l_con_preferred_engineers_tbl(l_current_record).engineer_id;
              l_preferred_engineers_tbl(l_pref_record).resource_type   :=
                                        l_con_preferred_engineers_tbl(l_current_record).resource_type;
              IF(( l_con_preferred_engineers_tbl(l_current_record).resource_class = 'P')
                 or (l_con_preferred_engineers_tbl(l_current_record).primary_flag = 'Y'))
              THEN
                  l_preferred_engineers_tbl(l_pref_record).primary_flag   := 'Y';
              END IF;
              l_preferred_engineers_tbl(l_pref_record).preference_type := 'C';

           END IF;
        -- keep the excluded resources in the excluded table
        ELSIF(l_con_preferred_engineers_tbl(l_current_record).resource_class = 'E')
        THEN
          x_excluded_tbl(l_excl_record).resource_id := l_con_preferred_engineers_tbl(l_current_record).engineer_id;
          x_excluded_tbl(l_excl_record).resource_type := l_con_preferred_engineers_tbl(l_current_record).resource_type;
          l_excl_record := l_excl_record + 1;
        END IF;
        l_current_record := l_con_preferred_engineers_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;


    --l_current_rec := x_assign_resources_tbl.LAST + 1;
    IF(x_assign_resources_tbl.COUNT > 0)
    THEN
       l_current_rec := x_assign_resources_tbl.LAST + 1;
    ELSE
      l_current_rec := 0;
    END IF;



    IF l_preferred_engineers_tbl.COUNT > 0 THEN
       l_current_record := l_preferred_engineers_tbl.FIRST;
       WHILE(l_current_record <=  l_preferred_engineers_tbl.LAST)
       LOOP
          x_assign_resources_tbl(l_current_rec).terr_rsc_id           := NULL;
          x_assign_resources_tbl(l_current_rec).resource_id           :=
                                 l_preferred_engineers_tbl(l_current_record).engineer_id;
          x_assign_resources_tbl(l_current_rec).resource_type         :=
                                 l_preferred_engineers_tbl(l_current_record).resource_type;
          x_assign_resources_tbl(l_current_rec).role                  := NULL;
          x_assign_resources_tbl(l_current_rec).start_date            := NULL;
          x_assign_resources_tbl(l_current_rec).end_date              := NULL;
          x_assign_resources_tbl(l_current_rec).shift_construct_id    := NULL;
          x_assign_resources_tbl(l_current_rec).terr_id               := NULL;
          x_assign_resources_tbl(l_current_rec).terr_name             := NULL;
          x_assign_resources_tbl(l_current_rec).preference_type       :=
                                 l_preferred_engineers_tbl(l_current_record).preference_type;
          x_assign_resources_tbl(l_current_rec).primary_flag       :=
                                 l_preferred_engineers_tbl(l_current_record).primary_flag;
          x_assign_resources_tbl(l_current_rec).resource_source := 'CONTRACTS';

          l_current_rec    := l_current_rec + 1;
          l_current_record := l_preferred_engineers_tbl.NEXT(l_current_record);
       END LOOP;


        -- The calendar flag check will not be done any more. The first available slot will be fetched
        -- This is for the preformance bug 3301417. If the calendar flag is Y then the resources will
        -- filtered based on availability in the procedure get_available_slot. This change is being done on
        -- 16 June 2004
      -- IF (p_calendar_flag = 'Y') THEN
          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
          l_return_status_1 := x_return_status ;
           -- call the api to check resource availability
           get_available_resources
            (
              p_init_msg_list                 =>  'F',
              p_calendar_flag                 =>   p_calendar_flag,
              p_effort_duration               =>   p_effort_duration,
              p_effort_uom                    =>   p_effort_uom,
              p_planned_start_date            =>   p_planned_start_date,
              p_planned_end_date              =>   p_planned_end_date,
              p_breakdown                     =>   null,
              p_breakdown_uom                 =>   null,
              p_continuous_task               =>   jtf_assign_pub.g_continuous_work,
              x_return_status                 =>   x_return_status,
              x_msg_count                     =>   x_msg_count,
              x_msg_data                      =>   x_msg_data,
              x_assign_resources_tbl          =>   x_assign_resources_tbl,
	      --Added for Bug # 5573916
	      p_calendar_check                =>   p_calendar_check
	      --Added for Bug # 5573916 Ends here
	      );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
               fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
               fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
               fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_CONTRACTS_RESOURCES');
               fnd_msg_pub.add;
               IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
               ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
             END IF; -- end of x_return_status check
         -- end if; -- if p_calendar_flag = Y
     end if;    --l_preferred_engineers_tbl.COUNT > 0


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END get_contracts_resources;





-- *******************************************************************************

--  Start of comments

--  Function       : This procedure is to fetch the Install Base Preferred Resources.
--                   This passes out the table of records with the resources.

--  End of comments

-- *******************************************************************************



  PROCEDURE get_ib_resources
            (
              p_init_msg_list                 IN  VARCHAR2,
              p_customer_product_id           IN  NUMBER,
              p_calendar_flag                 IN  VARCHAR2,
              p_effort_duration               IN  NUMBER,
              p_effort_uom                    IN  VARCHAR2,
              p_planned_start_date            IN  DATE,
              p_planned_end_date              IN  DATE,
              p_resource_type                 IN  VARCHAR2,
              x_return_status                 IN  OUT NOCOPY  VARCHAR2,
              x_msg_count                     IN  OUT NOCOPY  NUMBER,
              x_msg_data                      IN  OUT NOCOPY  VARCHAR2,
              x_assign_resources_tbl          IN  OUT NOCOPY  JTF_ASSIGN_PUB.AssignResources_tbl_type,
              x_excluded_tbl                  IN  OUT NOCOPY JTF_ASSIGN_PUB.excluded_tbl_type,
	      --Added for Bug # 5573916
	      p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	      --Added for Bug # 5573916 Ends here
            )
  IS

    l_return_status_1              VARCHAR2(10);
    l_api_name                     VARCHAR2(100)  := 'GET_IB_RESOURCES';
    l_api_name_1                   VARCHAR2(60)  := 'GET_IB_RESOURCES';
    l_api_version                  NUMBER  := 1.0;

    l_return_status                 VARCHAR2(10);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);

    l_engineer_id                   JTF_NUMBER_TABLE;
    l_resource_type                 JTF_VARCHAR2_TABLE_100;

    l_current_record                INTEGER  := 0;
    l_current_rec                   INTEGER  := 0;
    l_pref_record                   INTEGER  := 0;
    l_excl_record                   INTEGER  := 0;

    l_travel_time                   NUMBER        := 0;
    l_travel_uom                    VARCHAR2(10)  := 'HR';

    l_x_planned_start_date          DATE;
    l_x_planned_end_date            DATE;
    l_x_shift_construct_id          NUMBER;
    l_x_availability_type           VARCHAR2(60);

    l_ib_preferred_engineers_tbl    JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_preferred_engineers_tbl       JTF_ASSIGN_PUB.Preferred_Engineers_tbl_type;

    TYPE DYNAMIC_CUR_TYP            IS REF CURSOR;
    cur_csi_utility                 DYNAMIC_CUR_TYP;
    cur_cs_contacts                 DYNAMIC_CUR_TYP;
    l_dynamic_sql4                  VARCHAR2(2000);
    l_dynamic_sql2                  VARCHAR2(2000);

    l_cs_contacts_cp                VARCHAR2(5)  := 'CP';
    l_cs_contacts_y                 VARCHAR2(2)  := 'Y' ;
    l_cp_id                         NUMBER       :=  p_customer_product_id;
    l_flag                          VARCHAR2(2)  := 'Y' ;
    l_cs_contacts_rsc_id            NUMBER;
    l_cs_contacts_rsc_cat           VARCHAR2(60);
    l_primary                       VARCHAR2(2);
    l_preferred                     VARCHAR2(2);

    CURSOR cur_ib_resources IS
      SELECT resource_id,
             'RS_'||category category
        FROM  jtf_rs_resource_extns_vl
       WHERE  source_id = l_cs_contacts_rsc_id
         AND  category  = l_cs_contacts_rsc_cat;

    l_cur_ib_resources  cur_ib_resources%ROWTYPE;


    CURSOR cur_ib_resources_grp IS
      SELECT group_id resource_id,
             'RS_GROUP'
        FROM jtf_rs_groups_b
       WHERE group_id = l_cs_contacts_rsc_id;


    CURSOR cur_ib_resources_team IS
      SELECT team_id resource_id,
             'RS_TEAM'
        FROM jtf_rs_teams_b
       WHERE team_id = l_cs_contacts_rsc_id;

    CURSOR cur_ib_supp_resources IS
      SELECT resource_id,
             'RS_'||category category
        FROM  jtf_rs_resource_extns_vl
       WHERE  source_id = l_cs_contacts_rsc_id
         AND  category  = 'SUPPLIER_CONTACT';


  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_pref_record := 0;

    -- added by sudarsana on 30th nov 2001
    l_dynamic_sql4 := 'SELECT CSI_UTILITY_GRP.ib_active_flag() FROM DUAL';

    BEGIN
      OPEN  cur_csi_utility FOR l_dynamic_sql4;
      FETCH cur_csi_utility INTO l_flag;
      CLOSE cur_csi_utility;

    EXCEPTION WHEN OTHERS THEN
      l_flag := 'N';
    END;


    -- IF CSI_UTILITY_GRP.ib_active_flag() = 'Y' THEN

    IF (l_flag = 'Y') THEN
          l_dynamic_sql2 := 'SELECT  PARTY_ID resource_id, PARTY_SOURCE_TABLE resource_category, primary_flag, preferred_flag'||
                           ' FROM    CSI_I_PARTIES'||
                           ' WHERE   INSTANCE_ID  = :2'||
                          -- ' AND   PARTY_SOURCE_TABLE in ('''||'EMPLOYEE'||''''||','''||'HZ_PARTIES'||''''||','''||'GROUP'||''')'||
                           --' AND   PREFERRED_FLAG = :4' ;
                           -- changed this line to get excluded resources
                           ' AND   PREFERRED_FLAG in('''||'Y'||''''||','''||'E'||''')'||
                           ' AND   sysdate <= nvl(active_end_date, sysdate)' ;

      OPEN cur_cs_contacts FOR l_dynamic_sql2 USING --l_cs_contacts_cp,
                                                      l_cp_id;
                                                    --l_cs_contacts_emp,
                                                    --l_cs_contacts_y;
    ELSE

      l_dynamic_sql2  :=  ' SELECT resource_id, resource_category, primary_flag, preferred_flag '||
                          ' FROM   cs_contacts_v'||
                          ' WHERE  source_object_code = :1  AND '||
                          ' source_object_id   = :2  AND '||
                       -- ' resource_category  = :3  AND '||
                          ' preferred_flag     = :4';


      OPEN cur_cs_contacts FOR l_dynamic_sql2 USING l_cs_contacts_cp,
                                                    l_cp_id,
                                                 -- l_cs_contacts_emp,
                                                    l_cs_contacts_y;
    END IF; -- end of CSI_UTILITY_GRP check


    LOOP

      FETCH cur_cs_contacts INTO  l_cs_contacts_rsc_id,
                                  l_cs_contacts_rsc_cat,
                                  l_primary,
                                  l_preferred;
      EXIT WHEN cur_cs_contacts%NOTFOUND;
       if(l_primary is null)
       then
           l_primary := 'N';
       end if;

        -- IF cond for category added by sudarsana 30 nov 2001 to map to resource_manager

        IF((l_cs_contacts_rsc_cat = 'HZ_PARTIES') AND
           (p_resource_type is null OR p_resource_type = 'RS_INDIVIDUAL')) THEN


          l_cs_contacts_rsc_cat := 'PARTY';

          OPEN  cur_ib_resources;
          LOOP
            FETCH cur_ib_resources INTO l_cur_ib_resources;
            EXIT WHEN cur_ib_resources%NOTFOUND;

            l_ib_preferred_engineers_tbl(l_pref_record).engineer_id   := l_cur_ib_resources.resource_id;
            l_ib_preferred_engineers_tbl(l_pref_record).resource_type := l_cur_ib_resources.category;
            l_ib_preferred_engineers_tbl(l_pref_record).primary_flag  := l_primary;
            l_ib_preferred_engineers_tbl(l_pref_record).preferred_flag  := l_preferred;
            l_pref_record := l_pref_record + 1;
          END LOOP;
          CLOSE cur_ib_resources;

          l_cs_contacts_rsc_cat := 'PARTNER';

          OPEN  cur_ib_resources;
          LOOP
            FETCH cur_ib_resources INTO l_cur_ib_resources;
            EXIT WHEN cur_ib_resources%NOTFOUND;

            l_ib_preferred_engineers_tbl(l_pref_record).engineer_id   := l_cur_ib_resources.resource_id;
            l_ib_preferred_engineers_tbl(l_pref_record).resource_type := l_cur_ib_resources.category;
            l_ib_preferred_engineers_tbl(l_pref_record).primary_flag  := l_primary;
            l_ib_preferred_engineers_tbl(l_pref_record).preferred_flag  := l_preferred;
            l_pref_record := l_pref_record + 1;
          END LOOP;
          CLOSE cur_ib_resources;

        ELSIF((l_cs_contacts_rsc_cat = 'PO_VENDORS') AND
              ( p_resource_type =  'RS_INDIVIDUAL' OR  p_resource_type is null)) THEN

          OPEN  cur_ib_supp_resources;
          LOOP
            FETCH cur_ib_supp_resources INTO l_cur_ib_resources;
            EXIT WHEN cur_ib_supp_resources%NOTFOUND;

            l_ib_preferred_engineers_tbl(l_pref_record).engineer_id   := l_cur_ib_resources.resource_id;
            l_ib_preferred_engineers_tbl(l_pref_record).resource_type := l_cur_ib_resources.category;
            l_ib_preferred_engineers_tbl(l_pref_record).primary_flag  := l_primary;
            l_ib_preferred_engineers_tbl(l_pref_record).preferred_flag  := l_preferred;
            l_pref_record := l_pref_record + 1;
          END LOOP;
          CLOSE cur_ib_supp_resources;
        ELSIF((l_cs_contacts_rsc_cat = 'GROUP') AND
              ( p_resource_type =  'RS_GROUP' OR  p_resource_type is null)) THEN

          OPEN  cur_ib_resources_grp;
          LOOP
            FETCH cur_ib_resources_grp INTO l_cur_ib_resources;
            EXIT WHEN cur_ib_resources_grp%NOTFOUND;

            l_ib_preferred_engineers_tbl(l_pref_record).engineer_id   := l_cur_ib_resources.resource_id;
            l_ib_preferred_engineers_tbl(l_pref_record).resource_type := l_cur_ib_resources.category;
            l_ib_preferred_engineers_tbl(l_pref_record).primary_flag  := l_primary;
            l_ib_preferred_engineers_tbl(l_pref_record).preferred_flag  := l_preferred;
            l_pref_record := l_pref_record + 1;
          END LOOP;
          CLOSE cur_ib_resources_grp;

        ELSIF((l_cs_contacts_rsc_cat = 'TEAM') AND
              (p_resource_type =  'RS_TEAM' OR p_resource_type is null)) THEN

          OPEN  cur_ib_resources_team;
          LOOP
            FETCH cur_ib_resources_team INTO l_cur_ib_resources;
            EXIT WHEN cur_ib_resources_team%NOTFOUND;

            l_ib_preferred_engineers_tbl(l_pref_record).engineer_id   := l_cur_ib_resources.resource_id;
            l_ib_preferred_engineers_tbl(l_pref_record).resource_type := l_cur_ib_resources.category;
            l_ib_preferred_engineers_tbl(l_pref_record).primary_flag  := l_primary;
            l_ib_preferred_engineers_tbl(l_pref_record).preferred_flag  := l_preferred;
            l_pref_record := l_pref_record + 1;
          END LOOP;
          CLOSE cur_ib_resources_team;

        ELSIF(p_resource_type =  'RS_INDIVIDUAL' OR p_resource_type is null) THEN

          OPEN  cur_ib_resources;
          LOOP
            FETCH cur_ib_resources INTO l_cur_ib_resources;
            EXIT WHEN cur_ib_resources%NOTFOUND;

            l_ib_preferred_engineers_tbl(l_pref_record).engineer_id   := l_cur_ib_resources.resource_id;
            l_ib_preferred_engineers_tbl(l_pref_record).resource_type := l_cur_ib_resources.category;
            l_ib_preferred_engineers_tbl(l_pref_record).primary_flag  := l_primary;
            l_ib_preferred_engineers_tbl(l_pref_record).preferred_flag  := l_preferred;
            l_pref_record := l_pref_record + 1;
          END LOOP;
          CLOSE cur_ib_resources;
        END IF;
    END LOOP;
    CLOSE cur_cs_contacts;


    IF ( l_ib_preferred_engineers_tbl.COUNT > 0 ) THEN

      l_current_record := l_ib_preferred_engineers_tbl.FIRST;
      IF(x_excluded_tbl.count > 0)
      THEN
         l_excl_record    := x_excluded_tbl.last + 1;
      ELSE
         l_excl_record    := 0;
      END IF;

      WHILE l_current_record <= l_ib_preferred_engineers_tbl.LAST
      LOOP
        IF(l_ib_preferred_engineers_tbl(l_current_record).preferred_flag = 'Y')
        THEN
            l_preferred_engineers_tbl(l_pref_record).engineer_id     :=
                                  l_ib_preferred_engineers_tbl(l_current_record).engineer_id;
            l_preferred_engineers_tbl(l_pref_record).resource_type   :=
                                  l_ib_preferred_engineers_tbl(l_current_record).resource_type;
            l_preferred_engineers_tbl(l_pref_record).preference_type := 'I';
            l_preferred_engineers_tbl(l_pref_record).primary_flag    :=
                                  l_ib_preferred_engineers_tbl(l_current_record).primary_flag;

            l_pref_record    := l_pref_record + 1;
        ELSIF(l_ib_preferred_engineers_tbl(l_current_record).preferred_flag = 'E')
        THEN
            x_excluded_tbl(l_excl_record).resource_id     :=
                                  l_ib_preferred_engineers_tbl(l_current_record).engineer_id;
            x_excluded_tbl(l_excl_record).resource_type   :=
                                  l_ib_preferred_engineers_tbl(l_current_record).resource_type;


            l_excl_record    := l_excl_record + 1;


       END IF; -- end of check for preferred_flag
       l_current_record := l_ib_preferred_engineers_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;

    IF(x_assign_resources_tbl.COUNT > 0)
    THEN
       l_current_rec := x_assign_resources_tbl.LAST + 1;
    ELSE
      l_current_rec := 0;
    END IF;




    IF l_preferred_engineers_tbl.COUNT > 0 THEN
       l_current_record := l_preferred_engineers_tbl.FIRST;
       WHILE(l_current_record <=  l_preferred_engineers_tbl.LAST)
       LOOP
          x_assign_resources_tbl(l_current_rec).terr_rsc_id           := NULL;
          x_assign_resources_tbl(l_current_rec).resource_id           :=
                                 l_preferred_engineers_tbl(l_current_record).engineer_id;
          x_assign_resources_tbl(l_current_rec).resource_type         :=
                                 l_preferred_engineers_tbl(l_current_record).resource_type;
          x_assign_resources_tbl(l_current_rec).role                  := NULL;
          x_assign_resources_tbl(l_current_rec).start_date            := NULL;
          x_assign_resources_tbl(l_current_rec).end_date              := NULL;
          x_assign_resources_tbl(l_current_rec).shift_construct_id    := NULL;
          x_assign_resources_tbl(l_current_rec).terr_id               := NULL;
          x_assign_resources_tbl(l_current_rec).terr_name             := NULL;
          x_assign_resources_tbl(l_current_rec).preference_type       :=
                                 l_preferred_engineers_tbl(l_current_record).preference_type;
          x_assign_resources_tbl(l_current_rec).primary_flag       :=
                                 l_preferred_engineers_tbl(l_current_record).primary_flag;
          x_assign_resources_tbl(l_current_rec).resource_source       := 'IB';

          l_current_rec    := l_current_rec + 1;
          l_current_record := l_preferred_engineers_tbl.NEXT(l_current_record);
       END LOOP;

        -- The calendar flag check will not be done any more. The first available slot will be fetched
        -- This is for the preformance bug 3301417. If the calendar flag is Y then the resources will
        -- filtered based on availability in the procedure get_available_slot. This change is being done on
        -- 16 June 2004
        -- IF (p_calendar_flag = 'Y') THEN
        -- change the API Name temporarily so that in case of unexpected error
        -- it is properly caught
          l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
          l_return_status_1 := x_return_status ;
           -- call the api to check resource availability
           get_available_resources
            (
              p_init_msg_list                 =>  'F',
              p_calendar_flag                 =>   p_calendar_flag,
              p_effort_duration               =>   p_effort_duration,
              p_effort_uom                    =>   p_effort_uom,
              p_planned_start_date            =>   p_planned_start_date,
              p_planned_end_date              =>   p_planned_end_date,
              p_continuous_task               =>   jtf_assign_pub.g_continuous_work,
              p_breakdown                     =>   null,
              p_breakdown_uom                 =>   null,
              x_return_status                 =>   x_return_status,
              x_msg_count                     =>   x_msg_count,
              x_msg_data                      =>   x_msg_data,
              x_assign_resources_tbl          =>   x_assign_resources_tbl,
	      --Added for Bug # 5573916
	      p_calendar_check                =>   p_calendar_check
	      --Added for Bug # 5573916 Ends here
	      );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
               fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
               fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
               fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_IB_RESOURCES');
               fnd_msg_pub.add;
               IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
               ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
             END IF; -- end of x_return_status check
           -- end if; -- end if p_calendar_flag
     end if;    --l_preferred_engineers_tbl.COUNT > 0


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END get_ib_resources;


-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_TASK_RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is TASK.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT = FND_API.G_FALSE
--                        p_commit              IN      VARCHAR2 optional
--                                              DEFAULT = FND_API.G_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of CONTRACTS PREFERRED ENGINEERS
--     Defaulted to the PROFILE value
--     p_contracts_preferred_engineer           VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of INSTALL BASE PREFERRED ENGINEERS
--     Defaulted to the PROFILE value
--     p_ib_preferred_engineer                  VARCHAR2(1)
--                                              : value of  Y or N

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N


--     This parameter contains the Calling Document ID
--     In this case it is a TASK_ID.
--     p_task_id                                 NUMBER  -- REQUIRED

--     This parameter contains list of qualifier columns from the
--     UI which have been selected to re-query the resources.
--     Strictly for the use of User Interface of Assignment Manager.
--     p_column_list                             VARCHAR2

--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--      Version         : Current version        1.0
--                        Initial version        1.0
--
--      Notes           :
--

-- End of comments

-- *********************************************************************************



  /* Procedure Body with the parameters when the
     Source Document is TASK */


  PROCEDURE GET_ASSIGN_TASK_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2,
        p_resource_type                       IN  VARCHAR2,
        p_role                                IN  VARCHAR2,
        p_no_of_resources                     IN  NUMBER,
        p_auto_select_flag                    IN  VARCHAR2,
        p_contracts_preferred_engineer        IN  VARCHAR2,
        p_ib_preferred_engineer               IN  VARCHAR2,
        p_effort_duration                     IN  NUMBER,
        p_effort_uom                          IN  VARCHAR2,
        p_start_date                          IN  DATE,
        p_end_date                            IN  DATE,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_web_availability_flag               IN  VARCHAR2,
        p_task_id                             IN  JTF_TASKS_VL.TASK_ID%TYPE,
        p_column_list                         IN  VARCHAR2,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        p_filter_excluded_resource            IN  VARCHAR2,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_TASK_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_TASK_RESOURCES';
    l_api_version                         NUMBER        := 1.0;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);
    l_task_id                             JTF_TASKS_VL.TASK_ID%TYPE := p_task_id;
    l_task_source_code                    JTF_TASKS_VL.SOURCE_OBJECT_TYPE_CODE%TYPE;
    l_task_source_id                      JTF_TASKS_VL.SOURCE_OBJECT_ID%TYPE;
    l_contract_id                         NUMBER;
    l_cp_id                               NUMBER;
    l_contract_flag                       VARCHAR2(1)   := 'N';

    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(10)  := 'HR';

    l_current_record                      INTEGER       := 0;
    l_current_rec                         INTEGER       := 0;
    l_pref_record                         INTEGER       := 0;

    l_assign_resources_rec                JTF_TERRITORY_PUB.JTF_Task_Rec_Type;
    l_assign_resources_sr_rec             JTF_TERRITORY_PUB.JTF_Srv_Task_rec_type;
    l_assign_resources_tbl                JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;

    l_engineer_id                         JTF_NUMBER_TABLE;
    l_resource_type                       JTF_VARCHAR2_TABLE_100;

    l_return_status                       VARCHAR2(10);
    l_msg_count                           NUMBER;
    l_msg_data                            VARCHAR2(2000);

    l_ib_preferred_engineers_tbl          JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_con_preferred_engineers_tbl         JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_preferred_engineers_tbl             JTF_ASSIGN_PUB.Preferred_Engineers_tbl_type;

    -- tables for excluded resource
    l_excluded_resource_tbl               JTF_ASSIGN_PUB.excluded_tbl_type;
    l_contracts_tbl                       JTF_ASSIGN_PUB.AssignResources_tbl_type;
    l_ib_tbl                              JTF_ASSIGN_PUB.AssignResources_tbl_type;

    l_status                              VARCHAR2(30);
    l_industry                            VARCHAR2(30);

    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

    l_column_list                         VARCHAR2(4000);

    l_dynamic_sql                         VARCHAR2(2000);
    l_dynamic_sql1                        VARCHAR2(2000);
    l_dynamic_sql2                        VARCHAR2(2000);
    l_dynamic_sql3                        VARCHAR2(2000);


    TYPE DYNAMIC_CUR_TYP  IS REF CURSOR;

    cur_task          DYNAMIC_CUR_TYP;
    cur_srv_task      DYNAMIC_CUR_TYP;
    cur_cs_incidents  DYNAMIC_CUR_TYP;
    cur_cs_contacts   DYNAMIC_CUR_TYP;


    CURSOR cur_task_id IS
      SELECT source_object_type_code,
             source_object_id,
             planned_start_date,
             planned_end_date,
             planned_effort,
             planned_effort_uom
      FROM   jtf_tasks_vl
      WHERE  task_id = l_task_id;
    l_cur_task_id cur_task_id%ROWTYPE;


    l_cs_contacts_cp       VARCHAR2(5) := 'CP';
    l_cs_contacts_y        VARCHAR2(2) := 'Y' ;
    l_cs_contacts_emp      VARCHAR2(10) := 'EMPLOYEE';
    l_cs_contacts_rsc_id   NUMBER;
    l_cs_contacts_rsc_cat  VARCHAR2(60);


    CURSOR cur_ib_resources IS
      SELECT resource_id,
             'RS_'||category category
      FROM   jtf_rs_resource_extns_vl
      WHERE  source_id = l_cs_contacts_rsc_id AND
             category  = l_cs_contacts_rsc_cat;
    l_cur_ib_resources cur_ib_resources%ROWTYPE;


    cur_support_site_name  DYNAMIC_CUR_TYP;

    l_support_site         VARCHAR2(15) := 'SUPPORT_SITE';
    l_rsc_type             VARCHAR2(30);
    l_rsc_id               NUMBER;


    CURSOR cur_support_site_id (p_rsc_id NUMBER, p_rsc_type VARCHAR2) IS
      SELECT support_site_id
      FROM   jtf_rs_resource_extns_vl
      WHERE  resource_id = p_rsc_id AND
             category    = p_rsc_type;


    CURSOR cur_web_availability (p_res_id NUMBER, p_res_type VARCHAR2) IS
      SELECT resource_id
      FROM   jtf_rs_web_available_v
      WHERE  resource_id = p_res_id AND
             category    = p_res_type;


  BEGIN

    SAVEPOINT get_assign_task_resources;

    -- Started Assignment Manager API for TASKS


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;



    /* Get TASK source and the related information for contracts and
       contracts primary and secondary engineers, if they exist */

  If(l_task_id IS NOT NULL)
  -- this has been added as in form startup we now do a autoquery. So if no task id is passed instead of throwing the
  -- message that invalid id has been passed in we will just not do any processing
  THEN
    OPEN  cur_task_id;
    FETCH cur_task_id INTO l_cur_task_id;
    IF  ( cur_task_id%NOTFOUND ) THEN
      fnd_message.set_name('JTF', 'JTF_AM_INVALID_TASK_ID');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    ELSE
      l_task_source_code    := l_cur_task_id.source_object_type_code;
      l_task_source_id      := l_cur_task_id.source_object_id;
      l_planned_start_date  := l_cur_task_id.planned_start_date;
      l_planned_end_date    := l_cur_task_id.planned_end_date;
      l_effort_duration     := l_cur_task_id.planned_effort;
      l_effort_uom          := l_cur_task_id.planned_effort_uom;
    END IF;
    CLOSE cur_task_id;


    IF (l_task_source_id IS NOT NULL AND
        l_task_source_code = 'SR') THEN

      /*
        CURSOR cur_cs_incidents IS
          SELECT contract_service_id,
                 customer_product_id,
                 expected_resolution_date
          FROM   cs_incidents_all_vl
          WHERE  incident_id = l_task_source_id;
      */

      l_dynamic_sql1 :=  ' SELECT contract_service_id, customer_product_id, expected_resolution_date'||
                         ' FROM   cs_incidents_all_vl'||
                         ' WHERE  incident_id = :1';

      -- dbms_output.put_line('Select1 is : '||l_dynamic_sql1);

      OPEN  cur_cs_incidents FOR  l_dynamic_sql1 USING l_task_source_id;
      FETCH cur_cs_incidents INTO l_contract_id,
                                  l_cp_id,
                                  l_planned_end_date;

      IF  ( cur_cs_incidents%NOTFOUND ) THEN
        fnd_message.set_name('JTF', 'JTF_AM_INVALID_SR_ID');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      ELSE
        l_contract_flag       := 'Y';
        l_planned_start_date  := SYSDATE;
      END IF;

      CLOSE cur_cs_incidents;
    END IF;

    /* Defaulting the variable values to IN parameters,
       if the IN paramaters have values given */

    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE + 14;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;

    /* Check if the Contracts Preferred Engineers Profile is SET
       If it is SET then get the available preferred engineers
       into the table of records */

    IF (p_contracts_preferred_engineer = 'Y') THEN

      -- Process for the contracts preferred engineers

         get_contracts_resources
          (
            p_init_msg_list           =>  p_init_msg_list,
            p_contract_id             =>  l_contract_id,
            p_calendar_flag           =>  p_calendar_flag,
            p_effort_duration         =>  l_effort_duration,
            p_effort_uom              =>  l_effort_uom,
            p_planned_start_date      =>  l_planned_start_date,
            p_planned_end_date        =>  l_planned_end_date,
            p_resource_type           =>  p_resource_type,
            p_business_process_id     =>  p_business_process_id,
            p_business_process_date   =>  p_business_process_date,
            x_return_status           =>  x_return_status,
            x_msg_count               =>  x_msg_count,
            x_msg_data                =>  x_msg_data,
            x_assign_resources_tbl    =>  l_contracts_tbl,
            x_excluded_tbl            =>  l_excluded_resource_tbl,
	    --Added for Bug # 5573916
	    p_calendar_check          =>  p_calendar_check
	    --Added for Bug # 5573916 Ends here
          );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_CONTRACTS_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_TASK_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

    END IF; -- p_contracts_preferred_engineer = 'Y'

    /* Check if the Installed Base Preferred Engineers Profile is SET
       If it is SET then get the available preferred engineers
       into the table of records */

    IF (p_ib_preferred_engineer = 'Y') THEN
      -- Process for the Installed Base preferred engineers
     -- changed to ib code to call the common procedure and remove the old code - 4th april 2003
      get_ib_resources
            (
              p_init_msg_list           =>  p_init_msg_list,
              p_customer_product_id     =>  l_cp_id,
              p_calendar_flag           =>  p_calendar_flag,
              p_effort_duration         =>  l_effort_duration,
              p_effort_uom              =>  l_effort_uom,
              p_planned_start_date      =>  l_planned_start_date,
              p_planned_end_date        =>  l_planned_end_date,
              p_resource_type           =>  p_resource_type,
              x_return_status           =>  x_return_status,
              x_msg_count               =>  x_msg_count,
              x_msg_data                =>  x_msg_data,
              x_assign_resources_tbl    =>  l_ib_tbl,
              x_excluded_tbl            =>  l_excluded_resource_tbl,
	      --Added for Bug # 5573916
	      p_calendar_check          =>  p_calendar_check
	      --Added for Bug # 5573916 Ends here
            );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_IB_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_TASK_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

     END IF; -- p_ib_preferred_engineer = 'Y'


   -- remove excluded resources
   IF(p_filter_excluded_resource = 'Y')
   THEN
     IF(p_contracts_preferred_engineer = 'Y')
      THEN
          remove_excluded(x_res_tbl  => l_contracts_tbl,
                          x_exc_res  => l_excluded_resource_tbl);
      END IF;
      IF(p_ib_preferred_engineer = 'Y')
      THEN
          remove_excluded(x_res_tbl  => l_ib_tbl,
                          x_exc_res  => l_excluded_resource_tbl);
      END IF;
    END IF;

    -- after the preferred engineers are obtained from contracts/ib, select the resources
    -- that are to be returned
    /* Check if the Contracts Preferred Engineers Profile is SET If it is SET then get the available
       preferred engineers into the table of records */
        IF (p_contracts_preferred_engineer = 'Y') THEN
            table_copy(l_contracts_tbl, x_assign_resources_tbl);
        END IF; -- p_contracts_preferred_engineer = 'Y'

    /* Check if the Installed Base Preferred Engineers Profile is SET
       If it is SET then get the available preferred engineers
       into the table of records */
       IF (p_ib_preferred_engineer = 'Y') THEN
             table_copy(l_ib_tbl, x_assign_resources_tbl);
       END IF; -- p_ib_preferred_engineer = 'Y'

    /* Actual Flow of Assignment Manager */

    /* Initialize the record number to add the records of
       Contracts or Installed Base Preferred Engineers to the table of records */

    /* If this table has rows then there are preferred engineers existing */

    IF x_assign_resources_tbl.COUNT > 0 THEN
      -- removed the processing here as the calendar check is already being done inside the
      -- common procedures calls
       null;

    ELSE -- l_preferred_engineers_tbl.COUNT <= 0

      -- If there are NO preferred engineers then call territory API

      IF (l_task_source_code = 'SR') THEN
        fnd_message.set_name('JTF', 'JTF_AM_TASK_CREATED_BY_SR');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;

        /* Query the View which is a combination of Task and Service Request
           to get the data into the Record Type to pass it to the Territory API */


        IF (p_column_list IS NULL) THEN
          l_column_list := '*';
        ELSE
          l_column_list := p_column_list;
        END IF;

        /*
          SELECT * INTO l_assign_resources_sr_rec
          FROM   jtf_terr_srv_task_v -- (cs_sr_task_territory_v)
          WHERE  task_id            = l_task_id AND
                 service_request_id = l_task_source_id;
        */

        l_dynamic_sql :=   'SELECT '||
                           l_column_list||
                           ' FROM cs_sr_task_territory_v'||
                           ' WHERE task_id            = :1 AND
                                   service_request_id = :2';

        OPEN cur_srv_task FOR l_dynamic_sql USING l_task_id, l_task_source_id;
        FETCH cur_srv_task INTO l_assign_resources_sr_rec;
        -- EXIT WHEN cur_srv_task%NOTFOUND;
        CLOSE cur_srv_task;

        IF (p_territory_flag = 'Y') THEN

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_TERR_SERVICE_PUB';

          JTF_TERR_SERVICE_PUB.Get_WinningTerrMembers
          (
             p_api_version_number  => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_TerrSrvTask_Rec     => l_assign_resources_sr_rec,
             p_Resource_Type       => p_resource_type,
             p_Role                => p_role,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             x_TerrResource_tbl    => l_assign_resources_tbl
          );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Territory Manager
            fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
          -- added 2 april 2003 by sudarsana to conver RS_SUPPLIER TO RS_SUPPLIER_CONTACT
          IF(l_assign_resources_tbl.COUNT > 0)
          THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;

          IF l_assign_resources_tbl.COUNT > 0 THEN

            l_current_record := l_assign_resources_tbl.FIRST;

            -- FOR i IN 1 .. l_assign_resources_tbl.COUNT

            WHILE l_current_record <= l_assign_resources_tbl.LAST
            LOOP
                -- Check the calendar for resource availability
                -- Call Calendar API
                -- IF the resource is available then accept the values and
                -- finally check for the WORKFLOW profile option

                -- removed the calendar check from here 26th September 2003. Calendar check will be done in a seperate
                -- procedure. The call is made after resources are copied to x_assign_resources_tbl
                x_assign_resources_tbl(l_current_record).terr_rsc_id           :=
                                       l_assign_resources_tbl(l_current_record).terr_rsc_id;
                x_assign_resources_tbl(l_current_record).resource_id           :=
                                       l_assign_resources_tbl(l_current_record).resource_id;
                x_assign_resources_tbl(l_current_record).resource_type         :=
                                       l_assign_resources_tbl(l_current_record).resource_type;
                x_assign_resources_tbl(l_current_record).role                  :=
                                       l_assign_resources_tbl(l_current_record).role;
                x_assign_resources_tbl(l_current_record).start_date            :=
                                       l_assign_resources_tbl(l_current_record).start_date;
                x_assign_resources_tbl(l_current_record).end_date              :=
                                       l_assign_resources_tbl(l_current_record).end_date;
                x_assign_resources_tbl(l_current_record).shift_construct_id    := NULL;
                x_assign_resources_tbl(l_current_record).terr_id               :=
                                       l_assign_resources_tbl(l_current_record).terr_id;
                x_assign_resources_tbl(l_current_record).terr_name             :=
                                       l_assign_resources_tbl(l_current_record).terr_name;
		-- ================code added for bug 6453896=============
	        x_assign_resources_tbl(l_current_record).terr_rank             :=
                                       l_assign_resources_tbl(l_current_record).ABSOLUTE_RANK;
		-- ================End for addition of code===============
                x_assign_resources_tbl(l_current_record).primary_contact_flag  :=
                                       l_assign_resources_tbl(l_current_record).primary_contact_flag;
                 x_assign_resources_tbl(l_current_record).primary_flag  :=
                                         l_assign_resources_tbl(l_current_record).primary_contact_flag;
                x_assign_resources_tbl(l_current_record).resource_source       := 'TERR';
                 l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;

             -- If resource availability is to be checked then the calendar api is called. This is done in s seperate
             -- procedure get_available_resources
             -- The calendar flag check will not be done any more. The first available slot will be fetched
             -- This is for the preformance bug 3301417. If the calendar flag is Y then the resources will
             -- filtered based on availability in the procedure get_available_slot. This change is being done on
             -- 16 June 2004
            -- IF (p_calendar_flag = 'Y') THEN
             -- change the API Name temporarily so that in case of unexpected error
             -- it is properly caught
              l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
              l_return_status_1 := x_return_status ;
              -- call the api to check resource availability
              get_available_resources
              (
                p_init_msg_list                 =>  'F',
                p_calendar_flag                 =>  p_calendar_flag,
                p_effort_duration               =>  l_effort_duration,
                p_effort_uom                    =>  l_effort_uom,
                p_planned_start_date            =>  l_planned_start_date,
                p_planned_end_date              =>  l_planned_end_date,
                p_breakdown                     =>   null,
                p_breakdown_uom                 =>   null,
                p_continuous_task               =>  jtf_assign_pub.g_continuous_work,
                x_return_status                 =>  x_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data,
                x_assign_resources_tbl          =>  x_assign_resources_tbl,
		--Added for Bug # 5573916
	        p_calendar_check                =>  p_calendar_check
	        --Added for Bug # 5573916 Ends here
		);

              -- set back the API name to original name
               l_api_name := l_api_name_1;

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
                 fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_TASK_RESOURCES');
                 fnd_msg_pub.add;
                 IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
                 ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF; -- end of x_return_status check
            -- end if; -- if p_calendar_flag = Y

            IF ( p_calendar_flag = 'Y' AND
                 x_assign_resources_tbl.count = 0 ) THEN
              fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
              fnd_msg_pub.add;
--              RAISE fnd_api.g_exc_error;
            END IF;

             -- remove excluded resources
           IF(p_filter_excluded_resource = 'Y')
           THEN
              remove_excluded(x_res_tbl  => x_assign_resources_tbl,
                              x_exc_res  => l_excluded_resource_tbl);
           END IF;

          ELSE   -- No resources returned from the Territory API
            fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
            fnd_msg_pub.add;
--            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE  -- Territory Flag is NO
          fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
          fnd_msg_pub.add;
--          RAISE fnd_api.g_exc_error;
        END IF;

      ELSE  -- l_task_source_code <> 'SR'

        /* If Source Code is NOT a SERVICE REQUEST
           Query the Task View to get the data into the Record Type
           to pass it to the Territory API */

        IF (p_column_list IS NULL) THEN
          l_column_list := '*';
        ELSE
          l_column_list := p_column_list;
        END IF;

        l_dynamic_sql :=  'SELECT '||
                          l_column_list||
                          ' FROM jtf_task_territory_v'||
                          ' WHERE task_id = :1 AND rownum < 2';

        OPEN cur_task FOR l_dynamic_sql USING l_task_id;
        FETCH cur_task INTO l_assign_resources_rec.TASK_ID,
                            l_assign_resources_rec.PARTY_ID,
                            l_assign_resources_rec.COUNTRY,
                            l_assign_resources_rec.PARTY_SITE_ID,
                            l_assign_resources_rec.CITY,
                            l_assign_resources_rec.POSTAL_CODE,
                            l_assign_resources_rec.STATE,
                            l_assign_resources_rec.AREA_CODE,
                            l_assign_resources_rec.COUNTY,
                            l_assign_resources_rec.COMP_NAME_RANGE,
                            l_assign_resources_rec.PROVINCE,
                            l_assign_resources_rec.NUM_OF_EMPLOYEES,
                            l_assign_resources_rec.TASK_TYPE_ID,
                            l_assign_resources_rec.TASK_STATUS_ID,
                            l_assign_resources_rec.TASK_PRIORITY_ID,
                            l_assign_resources_rec.ATTRIBUTE1,
                            l_assign_resources_rec.ATTRIBUTE2,
                            l_assign_resources_rec.ATTRIBUTE3,
                            l_assign_resources_rec.ATTRIBUTE4,
                            l_assign_resources_rec.ATTRIBUTE5,
                            l_assign_resources_rec.ATTRIBUTE6,
                            l_assign_resources_rec.ATTRIBUTE7,
                            l_assign_resources_rec.ATTRIBUTE8,
                            l_assign_resources_rec.ATTRIBUTE9,
                            l_assign_resources_rec.ATTRIBUTE10,
                            l_assign_resources_rec.ATTRIBUTE11,
                            l_assign_resources_rec.ATTRIBUTE12,
                            l_assign_resources_rec.ATTRIBUTE13,
                            l_assign_resources_rec.ATTRIBUTE14,
                            l_assign_resources_rec.ATTRIBUTE15;
        -- EXIT WHEN cur_task%NOTFOUND;
        CLOSE cur_task;

        IF (p_territory_flag = 'Y') THEN

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_TERR_TASK_PUB';

          JTF_TERR_TASK_PUB.Get_WinningTerrMembers
          (
            p_api_version_number  => l_api_version,
            p_init_msg_list       => p_init_msg_list,
            p_TerrTask_rec        => l_assign_resources_rec,
            p_Resource_Type       => p_resource_type,
            p_Role                => p_role,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            x_TerrResource_tbl    => l_assign_resources_tbl
          );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Territory Manager for TASKS
            fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;



          -- to handle RS_SUPPLIER returned from territories -- added on 2nd april2003 by sudarsana

          IF(l_assign_resources_tbl.COUNT > 0)
          THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;

        -- removed the calendar check here. calling the procedure for calendar check in the next step
        -- calendar check removed 29th September 2003

          IF l_assign_resources_tbl.COUNT > 0 THEN

            l_current_rec    := 0;
            l_current_record := l_assign_resources_tbl.FIRST;

            WHILE l_current_record <= l_assign_resources_tbl.LAST
            LOOP
                x_assign_resources_tbl(l_current_record).terr_rsc_id           :=
                                       l_assign_resources_tbl(l_current_record).terr_rsc_id;
                x_assign_resources_tbl(l_current_record).resource_id           :=
                                       l_assign_resources_tbl(l_current_record).resource_id;
                x_assign_resources_tbl(l_current_record).resource_type         :=
                                       l_assign_resources_tbl(l_current_record).resource_type;
                x_assign_resources_tbl(l_current_record).role                  :=
                                       l_assign_resources_tbl(l_current_record).role;
                x_assign_resources_tbl(l_current_record).start_date            :=
                                       l_assign_resources_tbl(l_current_record).start_date;
                x_assign_resources_tbl(l_current_record).end_date              :=
                                       l_assign_resources_tbl(l_current_record).end_date;
                x_assign_resources_tbl(l_current_record).shift_construct_id    := NULL;
                x_assign_resources_tbl(l_current_record).terr_id               :=
                                       l_assign_resources_tbl(l_current_record).terr_id;
                x_assign_resources_tbl(l_current_record).terr_name             :=
                                       l_assign_resources_tbl(l_current_record).terr_name;
		-- ================code added for bug 6453896=============
                x_assign_resources_tbl(l_current_record).terr_rank             :=
                                       l_assign_resources_tbl(l_current_record).ABSOLUTE_RANK;
		-- ================End for addition of code===============
                x_assign_resources_tbl(l_current_record).primary_contact_flag  :=
                                       l_assign_resources_tbl(l_current_record).primary_contact_flag;
                x_assign_resources_tbl(l_current_record).primary_flag :=
                                         l_assign_resources_tbl(l_current_record).primary_contact_flag;
                x_assign_resources_tbl(l_current_record).resource_source       := 'TERR';

                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
            END LOOP;

          -- added calendar call out
          -- this has been done as now the calendar check is done in a seperate procedure GET_AVAILABLE_RESOURCE
          -- changed on 29th September 2003
           -- The calendar flag check will not be done any more. The first available slot will be fetched
          -- This is for the preformance bug 3301417. If the calendar flag is Y then the resources will
           -- filtered based on availability in the procedure get_available_slot. This change is being done on
           -- 16 June 2004
           --IF (p_calendar_flag = 'Y') THEN
             -- change the API Name temporarily so that in case of unexpected error
             -- it is properly caught
              l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
              l_return_status_1 := x_return_status ;
              -- call the api to check resource availability
              get_available_resources
              (
                p_init_msg_list                 =>  'F',
                p_calendar_flag                 =>  p_calendar_flag,
                p_effort_duration               =>  l_effort_duration,
                p_effort_uom                    =>  l_effort_uom,
                p_planned_start_date            =>  l_planned_start_date,
                p_planned_end_date              =>  l_planned_end_date,
                p_breakdown                     =>   null,
                p_breakdown_uom                 =>   null,
                p_continuous_task               =>  jtf_assign_pub.g_continuous_work,
                x_return_status                 =>  x_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data,
                x_assign_resources_tbl          =>  x_assign_resources_tbl,
		--Added for Bug # 5573916
	        p_calendar_check                =>  p_calendar_check
	        --Added for Bug # 5573916 Ends here
		);

              -- set back the API name to original name
               l_api_name := l_api_name_1;

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
                 fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_TASK_RESOURCES');
                 fnd_msg_pub.add;
                 IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
                 ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF; -- end of x_return_status check
            -- end if; -- if p_calendar_flag = Y

            IF ( p_calendar_flag = 'Y' AND
                 x_assign_resources_tbl.count = 0 ) THEN
              fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
              fnd_msg_pub.add;
--              RAISE fnd_api.g_exc_error;
            END IF;

          ELSE   -- No resources returned from the Territory API
            fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
            fnd_msg_pub.add;
--            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE  -- Territory Flag is NO

-- Since Territory Flag (along with Contracts and IB Flags) is unchecked
-- removed code which fetches Resources even if Calendar Flag is checked.
-- This was done as we don't want to fetch all resources blindly any time.
-- Fix for Bug 3308883.

          fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
          fnd_msg_pub.add;
        END IF; -- End of Territory_Flag = 'Y'

      END IF; -- End of l_task_source_code = 'SR'

    END IF; -- End of l_preferred_engineers_tbl.COUNT > 0

    -- Start of enhancement to add SUPPORT SITE ID and NAME to the OUT Table

    l_dynamic_sql3 := ' SELECT a.city city '||
                      ' FROM   hz_locations a, hz_party_sites b,  hz_party_site_uses c '||
                      ' WHERE  c.site_use_type = :1  AND '||
                      ' b.party_site_id        = :2  AND '||
                      ' a.location_id          = b.location_id   AND '||
                      ' c.party_site_id        = b.party_site_id ';

    IF x_assign_resources_tbl.COUNT > 0 THEN

      l_current_record := x_assign_resources_tbl.FIRST;

      WHILE l_current_record <= x_assign_resources_tbl.LAST
      LOOP

        l_rsc_type := resource_type_change(x_assign_resources_tbl(l_current_record).resource_type);

        OPEN  cur_support_site_id (x_assign_resources_tbl(l_current_record).resource_id,
                                   l_rsc_type);
        FETCH cur_support_site_id INTO x_assign_resources_tbl(l_current_record).support_site_id;

        IF (x_assign_resources_tbl(l_current_record).support_site_id IS NOT NULL) THEN

          OPEN  cur_support_site_name FOR l_dynamic_sql3
                USING l_support_site,
                      x_assign_resources_tbl(l_current_record).support_site_id;

          FETCH cur_support_site_name INTO x_assign_resources_tbl(l_current_record).support_site_name;
          IF (  cur_support_site_name % NOTFOUND ) THEN
            x_assign_resources_tbl(l_current_record).support_site_name := NULL;
          END IF;
          CLOSE cur_support_site_name;
        ELSE
          x_assign_resources_tbl(l_current_record).support_site_id   := NULL;
          x_assign_resources_tbl(l_current_record).support_site_name := NULL;

        END IF;

        CLOSE cur_support_site_id;

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;

    -- End of enhancement




    -- Start of enhancement to add Web Availability to the OUT Table


    IF (x_assign_resources_tbl.COUNT > 0) THEN

      l_current_record := x_assign_resources_tbl.FIRST;

      WHILE l_current_record <= x_assign_resources_tbl.LAST
      LOOP

        IF ( UPPER(p_web_availability_flag) = 'Y') THEN
          l_rsc_type := resource_type_change(x_assign_resources_tbl(l_current_record).resource_type);

          OPEN  cur_web_availability (x_assign_resources_tbl(l_current_record).resource_id,
                                      l_rsc_type);
          FETCH cur_web_availability INTO l_rsc_id;

          IF (cur_web_availability%FOUND) THEN
            x_assign_resources_tbl(l_current_record).web_availability_flag := 'Y';
          ELSE
            x_assign_resources_tbl(l_current_record).web_availability_flag := 'N';
          END IF;

          CLOSE cur_web_availability;
        ELSE
          x_assign_resources_tbl(l_current_record).web_availability_flag := NULL;
        END IF; --p_web_availability_flag = 'Y'

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;

    -- End of enhancement


end if; -- End of l_task_id is not null


    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_TASK_RESOURCES;



-- *******************************************************************************

-- Start of comments

--      API name        : _RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is
--                        SERVICE REQUEST.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT = FND_API.G_FALSE
--                        p_commit              IN      VARCHAR2 optional
--                                              DEFAULT = FND_API.G_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of CONTRACTS PREFERRED ENGINEERS
--     Defaulted to the PROFILE value
--     p_contracts_preferred_engineer           VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of INSTALL BASE PREFERRED ENGINEERS
--     Defaulted to the PROFILE value
--     p_ib_preferred_engineer                  VARCHAR2(1)
--                                              : value of  Y or N

--     This is to fetch the CONTRACTS PREFERRED ENGINEERS
--     p_contract_id                            NUMBER

--     This is to fetch the INSTALL BASE PREFERRED ENGINEERS
--     p_customer_product_id                    NUMBER

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N

--     This parameter contains the Calling Document ID
--     In this case it is a SR_ID.
--     p_sr_id                                   NUMBER  -- REQUIRED


--     These parameters contain the Qualifier Values for
--     the Calling Document
--     p_sr_rec                                  JTF_TERRITORY_PUB.
--                                               JTF_Serv_Req_rec_type
--     p_sr_task_rec                             JTF_TERRITORY_PUB.
--                                               JTF_Srv_Task_rec_type


--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--      Version         : Current version        1.0
--                        Initial version        1.0
--
--      Notes           :
--

-- End of comments

-- *********************************************************************************



--      Procedure definition with the parameters when the
--      Source Document is SERVICE REQUEST

  PROCEDURE GET_ASSIGN_SR_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2,
        p_resource_type                       IN  VARCHAR2,
        p_role                                IN  VARCHAR2,
        p_no_of_resources                     IN  NUMBER,
        p_auto_select_flag                    IN  VARCHAR2,
        p_contracts_preferred_engineer        IN  VARCHAR2,
        p_ib_preferred_engineer               IN  VARCHAR2,
        p_contract_id                         IN  NUMBER,
        p_customer_product_id                 IN  NUMBER,
        p_effort_duration                     IN  NUMBER,
        p_effort_uom                          IN  VARCHAR2,
        p_start_date                          IN  DATE,
        p_end_date                            IN  DATE,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_web_availability_flag               IN  VARCHAR2,
        p_category_id                         IN  NUMBER,
        p_inventory_item_id                   IN  NUMBER,
	p_inventory_org_id                    IN  NUMBER,
	p_problem_code                        IN  VARCHAR2 ,
        p_sr_id                               IN  NUMBER,
        p_sr_rec                              IN  JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type,
        p_sr_task_rec                         IN  JTF_TERRITORY_PUB.JTF_Srv_Task_rec_type,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        p_filter_excluded_resource            IN  VARCHAR2,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5386560
	p_inventory_component_id              IN  NUMBER   DEFAULT NULL,
        --Added for Bug # 5386560 Ends here
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_SR_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_SR_RESOURCES';

    l_api_version                         NUMBER        := 1.0;
    l_sr_id                               NUMBER;
    l_p_resource_type                     VARCHAR2(30)  := p_resource_type;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_expected_end_date                   DATE;     -- Added by SBARAT on 10/12/2004 for Bug 4052202
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);
    l_contract_id                         NUMBER;
    l_cp_id                               NUMBER;
    l_contract_flag                       VARCHAR2(1)   := 'N';
    l_terr_cal_flag                       VARCHAR2(1)   := 'N';

    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(10)  := 'HR';

    l_current_record                      INTEGER;
    l_current_rec                         INTEGER       := 0;
    l_pref_record                         INTEGER       := 0;

    l_assign_resources_tbl                JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_tbl                                 JTF_ASSIGN_PUB.AssignResources_tbl_type;


    l_return_status                       VARCHAR2(10);
    l_msg_count                           NUMBER;
    l_msg_data                            VARCHAR2(2000);

    l_pref_res_order                      VARCHAR2(20) := 'BOTH';
    l_ib_preferred_engineers_tbl          JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_con_preferred_engineers_tbl         JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_preferred_engineers_tbl             JTF_ASSIGN_PUB.Preferred_Engineers_tbl_type;

    -- tables to handle excluded resource feature
    l_excluded_resource_tbl               JTF_ASSIGN_PUB.excluded_tbl_type;
    l_contracts_tbl                       JTF_ASSIGN_PUB.AssignResources_tbl_type;
    l_ib_tbl                              JTF_ASSIGN_PUB.AssignResources_tbl_type;


    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

    l_dynamic_sql1                        VARCHAR2(2000);
    l_dynamic_sql3                        VARCHAR2(2000);

    l_sr_comp_sub                         VARCHAR2(10);  -- Added by SBARAT on 11/01/2005 for Enh 4112155
    l_sr_task_comp_sub                    VARCHAR2(10);  -- Added by SBARAT on 11/01/2005 for Enh 4112155


    TYPE DYNAMIC_CUR_TYP   IS REF CURSOR;
    cur_cs_incidents       DYNAMIC_CUR_TYP;
    cur_support_site_name  DYNAMIC_CUR_TYP;

    l_support_site         VARCHAR2(15) := 'SUPPORT_SITE';
    l_rsc_type             VARCHAR2(30);
    l_rsc_id               NUMBER;


    CURSOR cur_support_site_id (p_rsc_id NUMBER, p_rsc_type VARCHAR2) IS
      SELECT support_site_id
      FROM   jtf_rs_resource_extns_vl
      WHERE  resource_id = p_rsc_id AND
             category    = p_rsc_type;



    CURSOR cur_web_availability (p_res_id NUMBER, p_res_type VARCHAR2) IS
      SELECT resource_id
      FROM   jtf_rs_web_available_v
      WHERE  resource_id = p_res_id AND
             category    = p_res_type;



    CURSOR cur_resource_skills (p_res_id NUMBER) IS
      SELECT skill_level, level_name
      FROM   jtf_rs_resource_skills a,
             jtf_rs_skill_levels_vl  b
      WHERE  a.skill_level_id = b.skill_level_id AND
             a.resource_id    = p_res_id AND
             (category_id     = p_category_id OR category_id IS NULL)   AND
             product_id       = p_inventory_item_id AND
             product_org_id   = p_inventory_org_id  AND
             component_id     IS NULL AND
             subcomponent_id  IS NULL;

    l_skill_level    NUMBER;
    l_skill_name     VARCHAR2(60);
    l_skill_ret_sts  VARCHAR2(1);
    l_skill_tbl      JTF_AM_FILTER_RESOURCE_PVT.skill_param_tbl_type;
    l_group_filter   VARCHAR2(100) := 'YES';

    -- added record type for service security check
    l_sr_sec_rec     JTF_AM_FILTER_RESOURCE_PVT.sr_rec_type;

 /*procedure ts(v varchar2)
    is
      pragma autonomous_transaction;
    begin
      insert into test_values values(v);
      commit;
    end;*/
  BEGIN

    SAVEPOINT get_assign_sr_resources;


    -- Started Assignment Manager API for SERVICE REQUESTS


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;


    x_return_status := fnd_api.g_ret_sts_success;


    IF ( UPPER(p_resource_type) = 'RS_INDIVIDUAL') THEN
      l_p_resource_type := 'RS_INDIVIDUAL';
    ELSIF(p_resource_type is null) THEN
      l_p_resource_type := null;
    ELSE
      l_p_resource_type := p_resource_type;
    END IF;


    IF (p_sr_id IS NOT NULL ) THEN
      l_sr_id := p_sr_id;
    ELSIF (p_sr_rec.service_request_id IS NOT NULL) THEN
      l_sr_id := p_sr_rec.service_request_id;
    ELSIF (p_sr_task_rec.service_request_id IS NOT NULL) THEN
      l_sr_id := p_sr_task_rec.service_request_id;
    END IF;

    -- assign values to l_sr_sec_rec for SR Security Check
    l_sr_sec_rec.incident_id  := l_sr_id;
    IF(p_sr_rec.incident_type_id is not null)
    THEN
       l_sr_sec_rec.incident_type_id  := p_sr_rec.incident_type_id;
    ELSE
       l_sr_sec_rec.incident_type_id  := p_sr_task_rec.incident_type_id;
    END IF;

    /* Defaulting the variable values to IN parameters,
       if the IN paramaters have values given */

    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE + 14;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;

    -- Get the Profile value to determine the order of preferred resources

    --l_pref_res_order  := FND_PROFILE.VALUE_SPECIFIC ( 'JTF_AM_PREF_RES_ORDER' ); --Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_pref_res_order  := FND_PROFILE.VALUE ( 'JTF_AM_PREF_RES_ORDER' ); --Added by SBARAT on 12/10/2004, Bug-3830061


    IF ( p_contracts_preferred_engineer = 'Y'  OR
         p_ib_preferred_engineer        = 'Y') THEN


      l_contract_id := p_contract_id;
      l_cp_id       := p_customer_product_id;


      -- Code to fetch the Preferred Resources for saved SR
      IF (l_contract_id IS NULL AND
          l_cp_id       IS NULL AND
          l_sr_id       IS NOT NULL) THEN

        l_dynamic_sql1 :=  ' SELECT contract_service_id, customer_product_id, expected_resolution_date'||
                           ' FROM   cs_incidents_all_vl'||
                           ' WHERE  incident_id = :1';

        OPEN  cur_cs_incidents FOR  l_dynamic_sql1 USING l_sr_id;
        FETCH cur_cs_incidents INTO l_contract_id,
                                    l_cp_id,
                                    l_expected_end_date;   -- Added by SBARAT on 10/12/2004 for Bug 4052202
                                    --l_planned_end_date;  -- Commented by SBARAT on 10/12/2004 for Bug 4052202

        IF ( cur_cs_incidents%NOTFOUND ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_INVALID_SR_ID');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
          /*
          ELSE
            l_contract_flag       := 'Y';
          */
        END IF;

        CLOSE cur_cs_incidents;

        /**********Start of addition by SBARAT on 10/12/2004 for Bug 4052202**********/

        IF ( l_expected_end_date IS NOT NULL) And (l_expected_end_date >= l_planned_start_date)
        THEN

            l_planned_end_date := l_expected_end_date;

        END IF;

        /**********End of Addition by SBARAT on 10/12/2004 for Bug 4052202**********/

      END IF;  -- end of l_contract_id and l_cp_id null check

    END IF;



   -- initiliaze the table type variables
   l_excluded_resource_tbl.delete;
   l_contracts_tbl.delete;
   l_ib_tbl.delete;

   -- get the contracts preferred and excluded engineers
   IF (p_contracts_preferred_engineer = 'Y') THEN
      get_contracts_resources
          (
            p_init_msg_list           =>  p_init_msg_list,
            p_contract_id             =>  l_contract_id,
            p_calendar_flag           =>  p_calendar_flag,
            p_effort_duration         =>  l_effort_duration,
            p_effort_uom              =>  l_effort_uom,
            p_planned_start_date      =>  l_planned_start_date,
            p_planned_end_date        =>  l_planned_end_date,
            p_resource_type           =>  l_p_resource_type,
            p_business_process_id     =>  p_business_process_id,
            p_business_process_date   =>  p_business_process_date,
            x_return_status           =>  x_return_status,
            x_msg_count               =>  x_msg_count,
            x_msg_data                =>  x_msg_data,
            x_assign_resources_tbl    =>  l_contracts_tbl,
            x_excluded_tbl            =>  l_excluded_resource_tbl,
	    --Added for Bug # 5573916
	    p_calendar_check          =>  p_calendar_check
	    --Added for Bug # 5573916 Ends here
          );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_CONTRACTS_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_SR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
    END IF;

   -- get the ib preferred and excluded engineers
    IF (p_ib_preferred_engineer = 'Y') THEN

          get_ib_resources
            (
              p_init_msg_list           =>  p_init_msg_list,
              p_customer_product_id     =>  l_cp_id,
              p_calendar_flag           =>  p_calendar_flag,
              p_effort_duration         =>  l_effort_duration,
              p_effort_uom              =>  l_effort_uom,
              p_planned_start_date      =>  l_planned_start_date,
              p_planned_end_date        =>  l_planned_end_date,
              p_resource_type           =>  l_p_resource_type,
              x_return_status           =>  x_return_status,
              x_msg_count               =>  x_msg_count,
              x_msg_data                =>  x_msg_data,
              x_assign_resources_tbl    =>  l_ib_tbl,
              x_excluded_tbl            =>  l_excluded_resource_tbl,
	      --Added for Bug # 5573916
	      p_calendar_check          =>  p_calendar_check
	      --Added for Bug # 5573916 Ends here
            );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_IB_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_SR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

    END IF; -- p_ib_preferred_engineer = 'Y'

   -- remove excluded resources , added on 3rd July 2003
  IF(p_filter_excluded_resource = 'Y')
  THEN
     IF(p_contracts_preferred_engineer = 'Y')
      THEN
          remove_excluded(x_res_tbl  => l_contracts_tbl,
                          x_exc_res  => l_excluded_resource_tbl);
      END IF;
      IF(p_ib_preferred_engineer = 'Y')
      THEN
          remove_excluded(x_res_tbl  => l_ib_tbl,
                          x_exc_res  => l_excluded_resource_tbl);
      END IF;
   END IF;


   -- pass returned resources through security check
   IF(l_contracts_tbl.count > 0)
   THEN
       JTF_AM_FILTER_RESOURCE_PVT.SERVICE_SECURITY_CHECK
         (   p_api_version                  =>1.0,
             x_assign_resources_tbl         =>l_contracts_tbl,
             p_sr_tbl                       =>l_sr_sec_rec,
             x_return_status                =>x_return_status ,
             x_msg_count                    =>x_msg_count,
             x_msg_data                     =>x_msg_data);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','SERVICE_SECURITY_CHECK');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_SR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
      END IF;

   end IF; -- end of security check for contracts resource

   IF(l_ib_tbl.count > 0)
   THEN
       JTF_AM_FILTER_RESOURCE_PVT.SERVICE_SECURITY_CHECK
         (   p_api_version                  =>1.0,
             x_assign_resources_tbl         =>l_ib_tbl,
             p_sr_tbl                       =>l_sr_sec_rec,
             x_return_status                =>x_return_status ,
             x_msg_count                    =>x_msg_count,
             x_msg_data                     =>x_msg_data);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','SERVICE_SECURITY_CHECK');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_SR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
      END IF;

   end IF; -- end of security check for contracts resource






    -- after the preferred engineers are obtained from contracts/ib, select the resources
    -- that are to be returned based on the value of the profile for search order and after
    -- filtering out excluded resources
    IF ( upper(l_pref_res_order) = 'CONTRACTS' )
    THEN
        IF (p_contracts_preferred_engineer = 'Y')
        THEN
            table_copy(l_contracts_tbl, x_assign_resources_tbl);
        END IF; -- p_contracts_preferred_engineer = 'Y'


        IF ( x_assign_resources_tbl.COUNT <= 0 )
        THEN
          IF (p_ib_preferred_engineer = 'Y')
          THEN
              table_copy(l_ib_tbl, x_assign_resources_tbl);
          END IF; -- p_ib_preferred_engineer = 'Y'
        END IF; -- x_assign_resources_tbl.COUNT <= 0

    ELSIF ( upper(l_pref_res_order) = 'IB' )
    THEN

        IF (p_ib_preferred_engineer = 'Y')
        THEN
            table_copy(l_ib_tbl, x_assign_resources_tbl);
        END IF; -- p_ib_preferred_engineer = 'Y'

        IF ( x_assign_resources_tbl.COUNT <= 0 )
        THEN
          IF (p_contracts_preferred_engineer = 'Y')
          THEN
              table_copy(l_contracts_tbl, x_assign_resources_tbl);
          END IF; -- p_contracts_preferred_engineer = 'Y'
        END IF; -- x_assign_resources_tbl.COUNT <= 0

    ELSE  -- l_pref_res_order = 'BOTH'
      /* Check if the Contracts Preferred Engineers Profile is SET If it is SET then get the available
         preferred engineers into the table of records */
        IF (p_contracts_preferred_engineer = 'Y')
        THEN
            table_copy(l_contracts_tbl, x_assign_resources_tbl);
        END IF; -- p_contracts_preferred_engineer = 'Y'


      /* Check if the Installed Base Preferred Engineers Profile is SET
         If it is SET then get the available preferred engineers
         into the table of records */
        IF (p_ib_preferred_engineer = 'Y')
        THEN
             table_copy(l_ib_tbl, x_assign_resources_tbl);
        END IF; -- p_ib_preferred_engineer = 'Y'

     END IF; -- l_pref_res_order = 'CONTRACTS' / 'IB' / 'BOTH'

    /* Actual Flow of Assignment Manager */
   -- if the Contracts and IB Preferred Engineers are nor found then Territory Qualified Resources are fetched
    IF x_assign_resources_tbl.COUNT > 0
    THEN
      NULL;
    ELSE -- x_assign_resources_tbl.COUNT <= 0
      -- If there are NO preferred engineers then call territory API

      /* Trace the Service Request Record Type
         to pass it to the Territory API */

  /**************** Start of addition by SBARAT on 11/01/2005 for Enh 4112155**************/

      JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type:=p_sr_rec;
      JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type:=p_sr_task_rec;

      Terr_Qual_Dyn_Check(l_sr_comp_sub, l_sr_task_comp_sub);

      JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type:=Null;
      JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type:=Null;

  /**************** End of addition by SBARAT on 11/01/2005 for Enh 4112155**************/

      IF
        (
          p_sr_rec.SERVICE_REQUEST_ID   IS NOT NULL OR
          p_sr_rec.PARTY_ID             IS NOT NULL OR
          p_sr_rec.COUNTRY              IS NOT NULL OR
          p_sr_rec.PARTY_SITE_ID        IS NOT NULL OR
          p_sr_rec.CITY                 IS NOT NULL OR
          p_sr_rec.POSTAL_CODE          IS NOT NULL OR
          p_sr_rec.STATE                IS NOT NULL OR
          p_sr_rec.AREA_CODE            IS NOT NULL OR
          p_sr_rec.COUNTY               IS NOT NULL OR
          p_sr_rec.COMP_NAME_RANGE      IS NOT NULL OR
          p_sr_rec.PROVINCE             IS NOT NULL OR
          p_sr_rec.NUM_OF_EMPLOYEES     IS NOT NULL OR
          p_sr_rec.INCIDENT_TYPE_ID     IS NOT NULL OR
          p_sr_rec.INCIDENT_SEVERITY_ID IS NOT NULL OR
          p_sr_rec.INCIDENT_URGENCY_ID  IS NOT NULL OR
          p_sr_rec.PROBLEM_CODE         IS NOT NULL OR
          p_sr_rec.INCIDENT_STATUS_ID   IS NOT NULL OR
          p_sr_rec.PLATFORM_ID          IS NOT NULL OR
          p_sr_rec.SUPPORT_SITE_ID      IS NOT NULL OR
          p_sr_rec.CUSTOMER_SITE_ID     IS NOT NULL OR
          p_sr_rec.SR_CREATION_CHANNEL  IS NOT NULL OR
          p_sr_rec.INVENTORY_ITEM_ID    IS NOT NULL OR
          p_sr_rec.ATTRIBUTE1           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE2           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE3           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE4           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE5           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE6           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE7           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE8           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE9           IS NOT NULL OR
          p_sr_rec.ATTRIBUTE10          IS NOT NULL OR
          p_sr_rec.ATTRIBUTE11          IS NOT NULL OR
          p_sr_rec.ATTRIBUTE12          IS NOT NULL OR
          p_sr_rec.ATTRIBUTE13          IS NOT NULL OR
          p_sr_rec.ATTRIBUTE14          IS NOT NULL OR
          p_sr_rec.ATTRIBUTE15          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM12          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM13          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM14          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM15          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM16          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM17          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM18          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM19          IS NOT NULL OR
          p_sr_rec.SQUAL_NUM30          IS NOT NULL OR
          p_sr_rec.SQUAL_CHAR11         IS NOT NULL OR
          p_sr_rec.SQUAL_CHAR12         IS NOT NULL OR
          p_sr_rec.SQUAL_CHAR13         IS NOT NULL OR
          p_sr_rec.SQUAL_CHAR20         IS NOT NULL OR
          p_sr_rec.SQUAL_CHAR21         IS NOT NULL OR
          p_sr_rec.DAY_OF_WEEK          IS NOT NULL OR
          p_sr_rec.TIME_OF_DAY          IS NOT NULL OR
          l_sr_comp_sub                 IS NOT NULL         -- Added by SBARAT on 11/01/2005 for Enh 4112155

        ) THEN

/*ts('p_sr_rec.SERVICE_REQUEST_ID'||p_sr_rec.SERVICE_REQUEST_ID);
ts('p_sr_rec.PARTY_ID'||p_sr_rec.PARTY_ID);
ts('p_sr_rec.COUNTRY'||p_sr_rec.COUNTRY);
ts('p_sr_rec.PARTY_SITE_ID'||p_sr_rec.PARTY_SITE_ID);
ts('p_sr_rec.CITY'||p_sr_rec.CITY);
ts('p_sr_rec.INCIDENT_TYPE_ID'||p_sr_rec.INCIDENT_TYPE_ID);
ts('p_sr_rec.INCIDENT_SEVERITY_ID'||p_sr_rec.INCIDENT_SEVERITY_ID);
ts('p_sr_rec.INCIDENT_URGENCY_ID'||p_sr_rec.INCIDENT_URGENCY_ID);
ts('p_sr_rec.PROBLEM_CODE'||p_sr_rec.PROBLEM_CODE);
ts('p_sr_rec.INCIDENT_STATUS_ID'||p_sr_rec.INCIDENT_STATUS_ID);
ts('p_sr_rec.DAY_OF_WEEK'||p_sr_rec.DAY_OF_WEEK);
ts('p_sr_rec.TIME_OF_DAY'||p_sr_rec.TIME_OF_DAY);
ts('p_sr_rec.CUSTOMER_SITE_ID'||p_sr_rec.CUSTOMER_SITE_ID);ts('p_sr_rec.INVENTORY_ITEM_ID'||p_sr_rec.INVENTORY_ITEM_ID);
ts('p_sr_rec.SR_CREATION_CHANNEL'||p_sr_rec.SR_CREATION_CHANNEL);ts('p_sr_rec.PLATFORM_ID'||p_sr_rec.PLATFORM_ID);*/
        IF (p_territory_flag = 'Y') THEN

          if(l_p_resource_type = 'RS_INDIVIDUAL')
          then
                l_p_resource_type := null;
          end if;

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_TERR_SERVICE_PUB';

          JTF_TERR_SERVICE_PUB.Get_WinningTerrMembers
            (
               p_api_version_number  => l_api_version,
               p_init_msg_list       => p_init_msg_list,
               p_TerrServReq_Rec     => p_sr_rec,
               p_Resource_Type       => l_p_resource_type,
               p_Role                => p_role,
               x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data,
               x_TerrResource_tbl    => l_assign_resources_tbl
            );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Territory Manager
            fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

          -- added 2 april 2003 by sudarsana to convert RS_SUPPLIER TO RS_SUPPLIER_CONTACT
          IF(l_assign_resources_tbl.COUNT > 0)
          THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;

        ELSE  -- Territory Flag is NO

-- Since Territory Flag (along with Contracts and IB Flags) is unchecked
-- removed code which fetches Resources even if Calendar Flag is checked.
-- This was done as we don't want to fetch all resources blindly any time.
-- Fix for Bug 3308883.

          fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
          fnd_msg_pub.add;
        END IF; -- End of p_territory_flag = 'Y'

      ELSIF
        (
          p_sr_task_rec.TASK_ID              IS NOT NULL OR
          p_sr_task_rec.SERVICE_REQUEST_ID   IS NOT NULL OR
          p_sr_task_rec.PARTY_ID             IS NOT NULL OR
          p_sr_task_rec.COUNTRY              IS NOT NULL OR
          p_sr_task_rec.PARTY_SITE_ID        IS NOT NULL OR
          p_sr_task_rec.CITY                 IS NOT NULL OR
          p_sr_task_rec.POSTAL_CODE          IS NOT NULL OR
          p_sr_task_rec.STATE                IS NOT NULL OR
          p_sr_task_rec.AREA_CODE            IS NOT NULL OR
          p_sr_task_rec.COUNTY               IS NOT NULL OR
          p_sr_task_rec.COMP_NAME_RANGE      IS NOT NULL OR
          p_sr_task_rec.PROVINCE             IS NOT NULL OR
          p_sr_task_rec.NUM_OF_EMPLOYEES     IS NOT NULL OR
          p_sr_task_rec.TASK_TYPE_ID         IS NOT NULL OR
          p_sr_task_rec.TASK_STATUS_ID       IS NOT NULL OR
          p_sr_task_rec.TASK_PRIORITY_ID     IS NOT NULL OR
          p_sr_task_rec.INCIDENT_TYPE_ID     IS NOT NULL OR
          p_sr_task_rec.INCIDENT_SEVERITY_ID IS NOT NULL OR
          p_sr_task_rec.INCIDENT_URGENCY_ID  IS NOT NULL OR
          p_sr_task_rec.PROBLEM_CODE         IS NOT NULL OR
          p_sr_task_rec.INCIDENT_STATUS_ID   IS NOT NULL OR
          p_sr_task_rec.PLATFORM_ID          IS NOT NULL OR
          p_sr_task_rec.SUPPORT_SITE_ID      IS NOT NULL OR
          p_sr_task_rec.CUSTOMER_SITE_ID     IS NOT NULL OR
          p_sr_task_rec.SR_CREATION_CHANNEL  IS NOT NULL OR
          p_sr_task_rec.INVENTORY_ITEM_ID    IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE1           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE2           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE3           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE4           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE5           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE6           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE7           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE8           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE9           IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE10          IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE11          IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE12          IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE13          IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE14          IS NOT NULL OR
          p_sr_task_rec.ATTRIBUTE15          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM12          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM13          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM14          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM15          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM16          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM17          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM18          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM19          IS NOT NULL OR
          p_sr_task_rec.SQUAL_NUM30          IS NOT NULL OR
          p_sr_task_rec.SQUAL_CHAR11         IS NOT NULL OR
          p_sr_task_rec.SQUAL_CHAR12         IS NOT NULL OR
          p_sr_task_rec.SQUAL_CHAR13         IS NOT NULL OR
          p_sr_task_rec.SQUAL_CHAR20         IS NOT NULL OR
          p_sr_task_rec.SQUAL_CHAR21         IS NOT NULL OR
          p_sr_task_rec.DAY_OF_WEEK         IS NOT NULL OR
          p_sr_task_rec.TIME_OF_DAY         IS NOT NULL OR
          l_sr_task_comp_sub                 IS NOT NULL        -- Added by SBARAT on 11/01/2005 for Enh 4112155

        ) THEN


        IF (p_territory_flag = 'Y') THEN

          IF (l_p_resource_type  = 'RS_INDIVIDUAL') THEN
              l_p_resource_type := NULL;
          END IF;

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_TERR_SERVICE_PUB';

          JTF_TERR_SERVICE_PUB.Get_WinningTerrMembers
          (
             p_api_version_number  => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_TerrSrvTask_Rec     => p_sr_task_rec,
             p_Resource_Type       => l_p_resource_type,
             p_Role                => p_role,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             x_TerrResource_tbl    => l_assign_resources_tbl
          );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

          -- dbms_output.put_line('Count of TM :: '||l_assign_resources_tbl.count);

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Territory Manager
            fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

           -- added 2 april 2003 by sudarsana to conver RS_SUPPLIER TO RS_SUPPLIER_CONTACT

          IF(l_assign_resources_tbl.COUNT > 0)
          THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;

        ELSE  -- Territory Flag is NO

-- Since Territory Flag (along with Contracts and IB Flags) is unchecked
-- removed code which fetches Resources even if Calendar Flag is checked.
-- This was done as we don't want to fetch all resources blindly any time.
-- Fix for Bug 3308883.

          fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
          fnd_msg_pub.add;
        END IF; -- End of p_territory_flag = 'Y'

      END IF; -- End of p_sr_rec IS NOT NULL or p_sr_task_rec IS NOT NULL

      -- removed the calendar check here. calling the procedure for calendar check in the next step
      -- calendar check removed 29th September 2003
      IF l_assign_resources_tbl.COUNT > 0 THEN

        l_current_rec    := 0;
        l_current_record := l_assign_resources_tbl.FIRST;

        WHILE(l_current_record <=  l_assign_resources_tbl.LAST)
        LOOP
            x_assign_resources_tbl(l_current_rec).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_current_rec).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_current_rec).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;
            x_assign_resources_tbl(l_current_rec).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
            x_assign_resources_tbl(l_current_rec).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
            x_assign_resources_tbl(l_current_rec).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
            x_assign_resources_tbl(l_current_rec).shift_construct_id    := NULL;
            x_assign_resources_tbl(l_current_rec).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_current_rec).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
	    -- ================code added for bug 6453896=============
	    x_assign_resources_tbl(l_current_rec).terr_rank             :=
                                l_assign_resources_tbl(l_current_record).ABSOLUTE_RANK;
	    -- ================End for addition of code===============
            x_assign_resources_tbl(l_current_rec).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_current_rec).primary_flag  :=
                                       l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_current_rec).resource_source       := 'TERR';

            l_current_rec    := l_current_rec + 1;
            l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
       END LOOP;


      -- added calendar call out
      -- this has been done as now the calendar check is done in a seperate procedure GET_AVAILABLE_RESOURCE
      -- changed on 29th September 2003
       -- The calendar flag check will not be done any more. The first available slot will be fetched
        -- This is for the preformance bug 3301417. If the calendar flag is Y then the resources will
        -- filtered based on availability in the procedure get_available_slot. This change is being done on
        -- 16 June 2004
       --IF (p_calendar_flag = 'Y') THEN
          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
          l_return_status_1 := x_return_status ;
           -- call the api to check resource availability


           get_available_resources
            (
              p_init_msg_list                 =>  'F',
              p_calendar_flag                 =>   p_calendar_flag,
              p_effort_duration               =>  l_effort_duration,
              p_effort_uom                    =>  l_effort_uom,
              p_planned_start_date            =>  l_planned_start_date,
              p_planned_end_date              =>  l_planned_end_date,
              p_breakdown                     =>   null,
              p_breakdown_uom                 =>   null,
              p_continuous_task               =>   jtf_assign_pub.g_continuous_work,
              x_return_status                 =>   x_return_status,
              x_msg_count                     =>   x_msg_count,
              x_msg_data                      =>   x_msg_data,
              x_assign_resources_tbl          =>   x_assign_resources_tbl,
	      --Added for Bug # 5573916
	      p_calendar_check                =>   p_calendar_check
	      --Added for Bug # 5573916 Ends here
	      );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
               fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
               fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
               fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_SR_RESOURCES');
               fnd_msg_pub.add;
               IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
               ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
             END IF; -- end of x_return_status check
       --  end if; -- if p_calendar_flag = Y


        IF ( p_calendar_flag = 'Y' AND
          x_assign_resources_tbl.count = 0 ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
          fnd_msg_pub.add;
--          RAISE fnd_api.g_exc_error;
        END IF;


         -- remove excluded resources from territory qualifeid resource list
         -- added 4th July 2003
         IF(p_filter_excluded_resource = 'Y')
         THEN
              remove_excluded(x_res_tbl  => x_assign_resources_tbl,
                              x_exc_res  => l_excluded_resource_tbl);
         END IF;


          IF(x_assign_resources_tbl.count > 0)
          THEN
             JTF_AM_FILTER_RESOURCE_PVT.SERVICE_SECURITY_CHECK
              (   p_api_version                  =>1.0,
                  x_assign_resources_tbl         =>x_assign_resources_tbl,
                  p_sr_tbl                       =>l_sr_sec_rec,
                  x_return_status                =>x_return_status ,
                  x_msg_count                    =>x_msg_count,
                  x_msg_data                     =>x_msg_data);

              IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             -- Unexpected Execution Error from call to Get_contracts_resources
                  fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                  fnd_message.set_token('P_PROC_NAME','SERVICE_SECURITY_CHECK');
                  fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_SR_RESOURCES');
                  fnd_msg_pub.add;
                  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                    RAISE fnd_api.g_exc_error;
                  ELSE
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
              END IF;
          END IF; -- end of security check
      ELSE   -- No resources returned from the Territory API

        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;


      -- Logic for getting resources belonging to group id passed in
      -- get the profile value to see if you have to filter by group membership
      -- to fix bug 2789319 on 3rd april 2003
      --l_group_filter :=  nvl(FND_PROFILE.VALUE_SPECIFIC ('JTF_AM_GROUP_MEMBER_FILTER'), 'YES'); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
      l_group_filter :=  nvl(FND_PROFILE.VALUE ('JTF_AM_GROUP_MEMBER_FILTER'), 'YES'); -- Added by SBARAT on 12/10/2004, Bug-3830061


      IF(l_group_filter = 'YES')
      THEN
         if((p_sr_rec.squal_num17 is not null) ) -- AND (p_resource_type = 'RS_INDIVIDUAL'))
         then
            get_group_resource(p_sr_rec.squal_num17 ,
                            x_assign_resources_tbl );
         elsif((p_sr_task_rec.squal_num17 is not null) ) --  AND (p_resource_type = 'RS_INDIVIDUAL'))
         then
            get_group_resource(p_sr_task_rec.squal_num17 ,
                            x_assign_resources_tbl );
         END IF;

      end if;


    END IF; -- End of x_assign_resources_tbl.COUNT > 0





    -- Start of enhancement for showing Individual Resources ONLY


    IF ( UPPER(p_resource_type) = 'RS_INDIVIDUAL' ) THEN


      -- Reconstructing the table to further do the enhancements

      IF ( x_assign_resources_tbl.COUNT > 0 ) THEN

        l_current_record := x_assign_resources_tbl.FIRST;
        l_current_rec    := 1;

        WHILE l_current_record <= x_assign_resources_tbl.LAST
        LOOP

          l_tbl(l_current_rec).resource_id           :=
                                 x_assign_resources_tbl(l_current_record).resource_id;
          l_tbl(l_current_rec).resource_type         :=
                                 x_assign_resources_tbl(l_current_record).resource_type;

          l_tbl(l_current_rec).start_date            :=
                                 x_assign_resources_tbl(l_current_record).start_date;
          l_tbl(l_current_rec).end_date              :=
                                 x_assign_resources_tbl(l_current_record).end_date;
          l_tbl(l_current_rec).shift_construct_id    :=
                                 x_assign_resources_tbl(l_current_record).shift_construct_id;

          l_tbl(l_current_rec).terr_rsc_id           :=
                                 x_assign_resources_tbl(l_current_record).terr_rsc_id;
          l_tbl(l_current_rec).role                  :=
                                 x_assign_resources_tbl(l_current_record).role;
          l_tbl(l_current_rec).terr_id               :=
                                 x_assign_resources_tbl(l_current_record).terr_id;
          l_tbl(l_current_rec).terr_name             :=
                                 x_assign_resources_tbl(l_current_record).terr_name;
	  -- ================code added for bug 6453896=============
	  l_tbl(l_current_rec).terr_rank             :=
                                x_assign_resources_tbl(l_current_record).terr_rank;
	  -- ================End for addition of code===============
          l_tbl(l_current_rec).primary_contact_flag  :=
                                 x_assign_resources_tbl(l_current_record).primary_contact_flag;
          l_tbl(l_current_rec).preference_type       :=
                                 x_assign_resources_tbl(l_current_record).preference_type;
          l_tbl(l_current_rec).group_id              :=
                                 x_assign_resources_tbl(l_current_record).group_id;

          l_tbl(l_current_rec).primary_flag          :=
                                 x_assign_resources_tbl(l_current_record).primary_flag;

          l_tbl(l_current_rec).resource_source       :=
                                 x_assign_resources_tbl(l_current_record).resource_source;

          l_current_rec    := l_current_rec + 1;
          l_current_record := x_assign_resources_tbl.NEXT(l_current_record);

        END LOOP;



      END IF; --End of x_assign_resources_tbl.COUNT > 0

      -- End of reconstruction




      IF ( l_tbl.COUNT > 0 ) THEN

        l_current_record := l_tbl.FIRST;
        l_current_rec    := 0;

        -- Added by sroychou for rebuilding
        x_assign_resources_tbl.delete;

        WHILE l_current_record <= l_tbl.LAST
        LOOP
          IF ( UPPER(l_tbl(l_current_record).resource_type) NOT IN ( 'RS_GROUP', 'RS_TEAM')) THEN

            x_assign_resources_tbl(l_current_rec).resource_id           :=
                                   l_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_current_rec).resource_type         :=
                                   l_tbl(l_current_record).resource_type;

            x_assign_resources_tbl(l_current_rec).start_date            :=
                                   l_tbl(l_current_record).start_date;
            x_assign_resources_tbl(l_current_rec).end_date              :=
                                   l_tbl(l_current_record).end_date;
            x_assign_resources_tbl(l_current_rec).shift_construct_id    :=
                                   l_tbl(l_current_record).shift_construct_id;

            x_assign_resources_tbl(l_current_rec).terr_rsc_id           :=
                                   l_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_current_rec).role                  :=
                                   l_tbl(l_current_record).role;
            x_assign_resources_tbl(l_current_rec).terr_id               :=
                                   l_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_current_rec).terr_name             :=
                                   l_tbl(l_current_record).terr_name;
	    -- ================code added for bug 6453896=============
	    x_assign_resources_tbl(l_current_rec).terr_rank             :=
                                l_tbl(l_current_record).terr_rank;
	    -- ================End for addition of code===============
            x_assign_resources_tbl(l_current_rec).primary_contact_flag  :=
                                   l_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_current_rec).preference_type       :=
                                   l_tbl(l_current_record).preference_type;
            x_assign_resources_tbl(l_current_rec).group_id              :=
                                   l_tbl(l_current_record).group_id;

            x_assign_resources_tbl(l_current_rec).primary_flag          :=
                                   l_tbl(l_current_record).primary_flag;

            x_assign_resources_tbl(l_current_rec).resource_source       :=
                                   l_tbl(l_current_record).resource_source;

            l_current_rec := l_current_rec + 1;

          END IF;
          l_current_record := l_tbl.NEXT(l_current_record);

        END LOOP;

      END IF; --End of l_tbl.COUNT > 0

    END IF;   --End of p_resource_type = 'RS_INDIVIDUAL'

    -- End of enhancement




    -- Start of enhancement to add SUPPORT SITE ID and NAME to the OUT Table

    l_dynamic_sql3 := ' SELECT a.city city '||
                      ' FROM   hz_locations a, hz_party_sites b,  hz_party_site_uses c '||
                      ' WHERE  c.site_use_type = :1  AND '||
                      ' b.party_site_id        = :2 AND '||
                      ' a.location_id          = b.location_id   AND '||
                      ' c.party_site_id        = b.party_site_id ';

    IF x_assign_resources_tbl.COUNT > 0 THEN

      l_current_record := x_assign_resources_tbl.FIRST;

      WHILE l_current_record <= x_assign_resources_tbl.LAST
      LOOP

        l_rsc_type := resource_type_change(x_assign_resources_tbl(l_current_record).resource_type);

        OPEN  cur_support_site_id (x_assign_resources_tbl(l_current_record).resource_id,
                                   l_rsc_type);
        FETCH cur_support_site_id INTO x_assign_resources_tbl(l_current_record).support_site_id;

        IF (x_assign_resources_tbl(l_current_record).support_site_id IS NOT NULL) THEN

          OPEN  cur_support_site_name FOR l_dynamic_sql3
                USING l_support_site,
                      x_assign_resources_tbl(l_current_record).support_site_id;

          FETCH cur_support_site_name INTO x_assign_resources_tbl(l_current_record).support_site_name;
          IF (  cur_support_site_name % NOTFOUND ) THEN
            x_assign_resources_tbl(l_current_record).support_site_name := NULL;
          END IF;
          CLOSE cur_support_site_name;
        ELSE
          x_assign_resources_tbl(l_current_record).support_site_id   := NULL;
          x_assign_resources_tbl(l_current_record).support_site_name := NULL;

        END IF;

        CLOSE cur_support_site_id;

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;

    -- End of enhancement




    -- Start of enhancement to add Web Availability to the OUT Table


    IF (x_assign_resources_tbl.COUNT > 0) THEN

      l_current_record := x_assign_resources_tbl.FIRST;

      WHILE l_current_record <= x_assign_resources_tbl.LAST
      LOOP

        IF ( UPPER(p_web_availability_flag) = 'Y') THEN
          l_rsc_type := resource_type_change(x_assign_resources_tbl(l_current_record).resource_type);

          OPEN  cur_web_availability (x_assign_resources_tbl(l_current_record).resource_id,
                                      l_rsc_type);
          FETCH cur_web_availability INTO l_rsc_id;

          IF (cur_web_availability%FOUND) THEN
            x_assign_resources_tbl(l_current_record).web_availability_flag := 'Y';
          ELSE
            x_assign_resources_tbl(l_current_record).web_availability_flag := 'N';
          END IF;

          CLOSE cur_web_availability;
        ELSE
          x_assign_resources_tbl(l_current_record).web_availability_flag := NULL;
        END IF; --p_web_availability_flag = 'Y'

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;

    -- End of enhancement



    -- Start of enhancement for skill level using Product Code

   /* IF ( p_category_id       IS NOT NULL OR
         p_inventory_item_id IS NOT NULL OR
         p_inventory_org_id  IS NOT NULL  ) THEN


      IF ( x_assign_resources_tbl.COUNT > 0 ) THEN

        l_current_record := x_assign_resources_tbl.FIRST;

        WHILE l_current_record <= x_assign_resources_tbl.LAST
        LOOP

          OPEN  cur_resource_skills (x_assign_resources_tbl(l_current_record).resource_id);
          FETCH cur_resource_skills INTO l_skill_level, l_skill_name;
          IF (  cur_resource_skills%FOUND  ) THEN

            IF ( l_skill_level > 0 ) THEN
              x_assign_resources_tbl(l_current_record).skill_level  := l_skill_level;
              x_assign_resources_tbl(l_current_record).skill_name   := l_skill_name;
            ELSE
              x_assign_resources_tbl(l_current_record).skill_level  := NULL;
              x_assign_resources_tbl(l_current_record).skill_name   := NULL;
            END IF; -- End of l_skill_level > 0

          END IF; -- End of cur_resource_skills%FOUND
          CLOSE cur_resource_skills;


          l_current_record := x_assign_resources_tbl.NEXT(l_current_record);

        END LOOP;

      END IF; --End of x_assign_resources_tbl.COUNT > 0

    END IF;   --End of p_category_id IS NOT NULL
    */


    -- skills bank filter call to api  JTF_AM_FILTER_RESOURCE_PVT

     -- initialize values of the skill table
       l_skill_tbl(1).document_type   := 'SR';
       l_skill_tbl(1).category_id     := p_category_id;
       l_skill_tbl(1).product_id      := p_inventory_item_id;
       l_skill_tbl(1).product_org_id  := p_inventory_org_id;
       --Added for Bug # 5386560
       l_skill_tbl(1).component_id    := p_inventory_component_id;
       --Added for Bug # 5386560 Ends here

    -- changed problem code value to be talken from parameter instead of territory qualifier
    -- done by sudarsana on 24th april 2003
       l_skill_tbl(1).problem_code    := p_problem_code;

       -- change the API Name temporarily so that in case of unexpected error
       -- it is properly caught
       l_api_name := l_api_name||'-JTF_AM_FILTER_RESOURCE_PVT';
     JTF_AM_FILTER_RESOURCE_PVT.SEARCH_SKILL
                       ( p_api_version => 1.0,
                         x_assign_resources_tbl => x_assign_resources_tbl,
                         p_skill_param_tbl => l_skill_tbl,
                         x_return_status   => l_skill_ret_sts,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data );

    -- set back the API name to original name
    l_api_name := l_api_name_1;
    if(l_skill_ret_sts <>  fnd_api.g_ret_sts_success)
    then
      IF (l_skill_ret_sts = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    end if;

    -- End of enhancement




    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_SR_RESOURCES;


/************** Addition by SBARAT on 01/11/2004 for Enh-3919046 ***********/

-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_DR_RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is
--                        DEPOT REPAIR.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT = FND_API.G_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of CONTRACTS PREFERRED ENGINEERS
--     Defaulted to the PROFILE value
--     p_contracts_preferred_engineer           VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of INSTALL BASE PREFERRED ENGINEERS
--     Defaulted to the PROFILE value
--     p_ib_preferred_engineer                  VARCHAR2(1)
--                                              : value of  Y or N

--     This is to fetch the CONTRACTS PREFERRED ENGINEERS
--     p_contract_id                            NUMBER

--     This is to fetch the INSTALL BASE PREFERRED ENGINEERS
--     p_customer_product_id                    NUMBER

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N

--     This parameter contains the Calling Document ID
--     In this case it is a DR_ID.
--     p_dr_id                                   NUMBER  -- REQUIRED


--     These parameters contain the Qualifier Values for
--     the Calling Document
--     p_dr_rec                                  JTF_ASSIGN_PUB.
--                                               JTF_DR_rec_type

--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--      Version         : Current version        1.0
--                        Initial version        1.0
--
--      Notes           :
--

-- End of comments

-- *********************************************************************************



--      Procedure definition with the parameters when the
--      Source Document is DEPOT REPAIR


  PROCEDURE GET_ASSIGN_DR_RESOURCES
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_contracts_preferred_engineer        IN  VARCHAR2 ,
        p_ib_preferred_engineer               IN  VARCHAR2 ,
        p_contract_id                         IN  NUMBER   ,
        p_customer_product_id                 IN  NUMBER   ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2 ,
        p_calendar_flag                       IN  VARCHAR2 ,
        p_web_availability_flag               IN  VARCHAR2 ,
        p_category_id                         IN  NUMBER   ,
        p_inventory_item_id                   IN  NUMBER   ,
        p_inventory_org_id                    IN  NUMBER   ,
        p_problem_code                        IN  VARCHAR2 ,
        p_dr_id                               IN  NUMBER,
        p_column_list                         IN  VARCHAR2 ,
        p_dr_rec                              IN  JTF_ASSIGN_PUB.JTF_DR_rec_type ,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        p_filter_excluded_resource            IN  VARCHAR2,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name			            VARCHAR2(100)	:= 'GET_ASSIGN_DR_RESOURCES';
    l_api_name_1  	                  VARCHAR2(60)	:= 'GET_ASSIGN_DR_RESOURCES';

    l_api_version           	            NUMBER        := 1.0;
    l_no_of_resources                     NUMBER        := p_no_of_resources;
    l_auto_select_flag                    VARCHAR2(1)   := p_auto_select_flag;
    l_contracts_preferred_engineer        VARCHAR2(1)   := p_contracts_preferred_engineer;
    l_ib_preferred_engineer               VARCHAR2(1)   := p_ib_preferred_engineer;
    l_territory_flag                      VARCHAR2(1)   := p_territory_flag;
    l_calendar_flag                       VARCHAR2(1)   := p_calendar_flag;

    l_web_availability_flag               VARCHAR2(1)   := p_web_availability_flag;

    l_contracts_profile                   VARCHAR2(1);
    l_ib_profile                          VARCHAR2(1);
    l_auto_select_profile                 VARCHAR2(1);
    l_workflow_profile                    VARCHAR2(60);

    l_current_record                      INTEGER;
    l_dynamic_cursor                      INTEGER;
    l_dynamic_sql                         VARCHAR2(4000);

    l_return_code                         VARCHAR2(60);
    l_wf_return_status                    VARCHAR2(60);
    l_wf_msg_count                        NUMBER;
    l_wf_msg_data                         VARCHAR2(2000);

    l_bind_data_id                        NUMBER;
    l_workflow_key                        NUMBER;

    l_dr_rec                              JTF_TERRITORY_PUB.JTF_Srv_Task_rec_type;
    l_tbl                                 JTF_ASSIGN_PUB.AssignResources_tbl_type;
    l_assign_resources_tbl                JTF_ASSIGN_PUB.AssignResources_tbl_type;
    l_winningterrmember_tbl               JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;

    l_dr_id                               NUMBER;
    l_p_resource_type                     VARCHAR2(30)  := p_resource_type;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_expected_end_date                   DATE;     -- Added by SBARAT on 10/12/2004 for Bug 4052202
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);
    l_contract_id                         NUMBER;
    l_cp_id                               NUMBER;
    l_contract_flag                       VARCHAR2(1)   := 'N';
    l_terr_cal_flag                       VARCHAR2(1)   := 'N';

    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(10)  := 'HR';

    l_current_rec                         INTEGER       := 0;
    l_pref_record                         INTEGER       := 0;


    l_return_status                       VARCHAR2(10);
    l_msg_count                           NUMBER;
    l_msg_data                            VARCHAR2(2000);

    l_pref_res_order                      VARCHAR2(20) := 'BOTH';
    l_ib_preferred_engineers_tbl          JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_con_preferred_engineers_tbl         JTF_ASSIGN_PUB.prfeng_tbl_type;
    l_preferred_engineers_tbl             JTF_ASSIGN_PUB.Preferred_Engineers_tbl_type;

    -- tables to handle excluded resource feature
    l_excluded_resource_tbl               JTF_ASSIGN_PUB.excluded_tbl_type;
    l_contracts_tbl                       JTF_ASSIGN_PUB.AssignResources_tbl_type;
    l_ib_tbl                              JTF_ASSIGN_PUB.AssignResources_tbl_type;


    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

    l_dynamic_sql1                        VARCHAR2(2000);
    l_dynamic_sql3                        VARCHAR2(2000);

    TYPE DYNAMIC_CUR_TYP   IS REF CURSOR;
    cur_cs_incidents       DYNAMIC_CUR_TYP;
    cur_support_site_name  DYNAMIC_CUR_TYP;

    l_support_site         VARCHAR2(15) := 'SUPPORT_SITE';
    l_rsc_type             VARCHAR2(30);
    l_rsc_id               NUMBER;

    l_value                               VARCHAR2(100);
    l_count                               NUMBER:= 0;
    l_usage                               VARCHAR2(2000);
    l_uom_hour                            VARCHAR2(2000);

    l_skill_level    NUMBER;
    l_skill_name     VARCHAR2(60);
    l_skill_ret_sts  VARCHAR2(1);
    l_skill_tbl      JTF_AM_FILTER_RESOURCE_PVT.skill_param_tbl_type;
    l_group_filter   VARCHAR2(100) := 'YES';

    -- Record type for service security check
    l_dr_sec_rec     JTF_AM_FILTER_RESOURCE_PVT.sr_rec_type;


    CURSOR cur_resource_type IS
      SELECT object_code
      FROM   jtf_object_usages
      WHERE  object_user_code = 'RESOURCES' AND
             object_code      = p_resource_type;
    l_cur_resource_type cur_resource_type%ROWTYPE;


    CURSOR cur_res_location(p_rid NUMBER, p_rtype VARCHAR2) IS
      SELECT DECODE(source_postal_code, NULL, '00000', source_postal_code)
      FROM   jtf_rs_resource_extns_vl
      WHERE  resource_id     = p_rid AND
             'RS_'||category = p_rtype;


    --Bug# 4455803 MOAC.
    CURSOR check_date_cur(l_resource_id in number,
                          l_resource_type in varchar2)
        IS
     SELECT 'Y'
       FROM  jtf_task_resources_vl
      where   resource_id = l_resource_id
        and   resource_type = l_resource_type
        and   nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);


    CURSOR cur_support_site_id (p_rsc_id NUMBER, p_rsc_type VARCHAR2) IS
      SELECT support_site_id
      FROM   jtf_rs_resource_extns_vl
      WHERE  resource_id = p_rsc_id AND
             category    = p_rsc_type;


    CURSOR cur_web_availability (p_res_id NUMBER, p_res_type VARCHAR2) IS
      SELECT resource_id
      FROM   jtf_rs_web_available_v
      WHERE  resource_id = p_res_id AND
             category    = p_res_type;


    CURSOR cur_resource_skills (p_res_id NUMBER) IS
      SELECT skill_level, level_name
      FROM   jtf_rs_resource_skills a,
             jtf_rs_skill_levels_vl  b
      WHERE  a.skill_level_id = b.skill_level_id AND
             a.resource_id    = p_res_id AND
             (category_id     = p_category_id OR category_id IS NULL)   AND
             product_id       = p_inventory_item_id AND
             product_org_id   = p_inventory_org_id  AND
             component_id     IS NULL AND
             subcomponent_id  IS NULL;

  BEGIN

    SAVEPOINT jtf_assign_pub;

    -- Started Assignment Manager Public API

    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    /* Paramater Validation */

    IF (p_resource_type IS NOT NULL) THEN
      OPEN  cur_resource_type;
      FETCH cur_resource_type INTO l_cur_resource_type;
      IF ( cur_resource_type%NOTFOUND) THEN
        fnd_message.set_name('JTF', 'JTF_AM_INVALID_RESOURCE_TYPE');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE cur_resource_type;
    END IF;


    /* Getting the Profile values defined for the Assignment Manager */

    l_contracts_profile       := FND_PROFILE.VALUE ( 'ACTIVATE_CONTRACTS_PREFERRED_ENGINEERS' );
    l_auto_select_profile     := FND_PROFILE.VALUE ( 'ACTIVATE_AUTO_SELECT' );
    l_workflow_profile        := FND_PROFILE.VALUE ( 'ACTIVATE_WORKFLOW_NAME' );
    l_ib_profile              := FND_PROFILE.VALUE ( 'ACTIVATE_IB_PREFERRED_ENGINEERS');
    l_usage                   := fnd_profile.value ( 'JTF_AM_USAGE');

    /* Assigning the DEFAULT values for the Parameters */

    IF (p_auto_select_flag IS NULL) THEN
      l_auto_select_flag  := l_auto_select_profile; -- PROFILE VALUE is the default value
    ELSE
      l_auto_select_flag  := p_auto_select_flag;
    END IF;


    IF (p_contracts_preferred_engineer IS NULL) THEN
      l_contracts_preferred_engineer  := l_contracts_profile; -- PROFILE VALUE is the default value
    ELSE
      l_contracts_preferred_engineer  := p_contracts_preferred_engineer;
    END IF;


    IF (p_ib_preferred_engineer IS NULL) THEN
      l_ib_preferred_engineer  := l_ib_profile; -- PROFILE VALUE is the default value
    ELSE
      l_ib_preferred_engineer  := p_ib_preferred_engineer;
    END IF;


    IF (p_no_of_resources IS NULL) THEN
      l_no_of_resources  := 1;  -- 1 is the default value
    ELSE
      l_no_of_resources  := p_no_of_resources;
    END IF;


    IF ( (UPPER(p_territory_flag) = 'N') OR (p_territory_flag IS NULL)) THEN
      l_territory_flag  := 'N';
    ELSE
      l_territory_flag  := 'Y';  -- YES is the default value
    END IF;


    IF ( (UPPER(p_calendar_flag) = 'N') OR (p_calendar_flag IS NULL)) THEN
      l_calendar_flag  := 'N';
    ELSE
      l_calendar_flag  := 'Y';  -- YES is the default value
    END IF;


    IF ( p_web_availability_flag IS NULL) THEN
      l_web_availability_flag  := 'Y';
    ELSE
      l_web_availability_flag  := p_web_availability_flag;
    END IF;


     /* To handle the conversion of duration to hour */

    l_uom_hour  := nvl(fnd_profile.value('JTF_AM_TASK_HOUR'), 'HR');
    IF(nvl(p_effort_uom, l_uom_hour) <> l_uom_hour)
    THEN
         l_effort_duration :=  inv_convert.inv_um_convert(
                                   item_id => NULL,
                                   precision => 2,
                                   from_quantity => p_effort_duration,
                                   from_unit => p_effort_uom,
                                   to_unit   => l_uom_hour,
                                   from_name => NULL,
                                   to_name   => NULL);
    ELSE
        l_effort_duration := p_effort_duration;
    END IF;

    /* This assigning is being done because of the limitation for
       the direct use of the variables FND_API.MISS_NUM, MISS_CHAR etc. */


    /* Assigning values to the Depot Repair Record Type */

    l_dr_rec.TASK_ID              :=  p_dr_rec.TASK_ID;
    l_dr_rec.SERVICE_REQUEST_ID   :=  p_dr_rec.SERVICE_REQUEST_ID;
    l_dr_rec.PARTY_ID             :=  p_dr_rec.PARTY_ID;
    l_dr_rec.COUNTRY              :=  p_dr_rec.COUNTRY;
    l_dr_rec.PARTY_SITE_ID        :=  p_dr_rec.PARTY_SITE_ID;
    l_dr_rec.CITY                 :=  p_dr_rec.CITY;
    l_dr_rec.POSTAL_CODE          :=  p_dr_rec.POSTAL_CODE;
    l_dr_rec.STATE                :=  p_dr_rec.STATE;
    l_dr_rec.AREA_CODE            :=  p_dr_rec.AREA_CODE;
    l_dr_rec.COUNTY               :=  p_dr_rec.COUNTY;
    l_dr_rec.COMP_NAME_RANGE      :=  p_dr_rec.COMP_NAME_RANGE;
    l_dr_rec.PROVINCE             :=  p_dr_rec.PROVINCE;
    l_dr_rec.NUM_OF_EMPLOYEES     :=  p_dr_rec.NUM_OF_EMPLOYEES;
    l_dr_rec.TASK_TYPE_ID         :=  p_dr_rec.TASK_TYPE_ID;
    l_dr_rec.TASK_STATUS_ID       :=  p_dr_rec.TASK_STATUS_ID;
    l_dr_rec.TASK_PRIORITY_ID     :=  p_dr_rec.TASK_PRIORITY_ID;
    l_dr_rec.INCIDENT_TYPE_ID     :=  p_dr_rec.INCIDENT_TYPE_ID;
    l_dr_rec.INCIDENT_SEVERITY_ID :=  p_dr_rec.INCIDENT_SEVERITY_ID;
    l_dr_rec.INCIDENT_URGENCY_ID  :=  p_dr_rec.INCIDENT_URGENCY_ID;
    l_dr_rec.PROBLEM_CODE         :=  p_dr_rec.PROBLEM_CODE;
    l_dr_rec.INCIDENT_STATUS_ID   :=  p_dr_rec.INCIDENT_STATUS_ID;
    l_dr_rec.PLATFORM_ID          :=  p_dr_rec.PLATFORM_ID;
    l_dr_rec.SUPPORT_SITE_ID      :=  p_dr_rec.SUPPORT_SITE_ID;
    l_dr_rec.CUSTOMER_SITE_ID     :=  p_dr_rec.CUSTOMER_SITE_ID;
    l_dr_rec.SR_CREATION_CHANNEL  :=  p_dr_rec.SR_CREATION_CHANNEL;
    l_dr_rec.INVENTORY_ITEM_ID    :=  p_dr_rec.INVENTORY_ITEM_ID;
    l_dr_rec.ATTRIBUTE1           :=  p_dr_rec.ATTRIBUTE1;
    l_dr_rec.ATTRIBUTE2           :=  p_dr_rec.ATTRIBUTE2;
    l_dr_rec.ATTRIBUTE3           :=  p_dr_rec.ATTRIBUTE3;
    l_dr_rec.ATTRIBUTE4           :=  p_dr_rec.ATTRIBUTE4;
    l_dr_rec.ATTRIBUTE5           :=  p_dr_rec.ATTRIBUTE5;
    l_dr_rec.ATTRIBUTE6           :=  p_dr_rec.ATTRIBUTE6;
    l_dr_rec.ATTRIBUTE7           :=  p_dr_rec.ATTRIBUTE7;
    l_dr_rec.ATTRIBUTE8           :=  p_dr_rec.ATTRIBUTE8;
    l_dr_rec.ATTRIBUTE9           :=  p_dr_rec.ATTRIBUTE9;
    l_dr_rec.ATTRIBUTE10          :=  p_dr_rec.ATTRIBUTE10;
    l_dr_rec.ATTRIBUTE11          :=  p_dr_rec.ATTRIBUTE11;
    l_dr_rec.ATTRIBUTE12          :=  p_dr_rec.ATTRIBUTE12;
    l_dr_rec.ATTRIBUTE13          :=  p_dr_rec.ATTRIBUTE13;
    l_dr_rec.ATTRIBUTE14          :=  p_dr_rec.ATTRIBUTE14;
    l_dr_rec.ATTRIBUTE15          :=  p_dr_rec.ATTRIBUTE15;
    l_dr_rec.ORGANIZATION_ID      :=  p_dr_rec.ORGANIZATION_ID;
    l_dr_rec.SQUAL_NUM12          :=  p_dr_rec.SQUAL_NUM12;
    l_dr_rec.SQUAL_NUM13          :=  p_dr_rec.SQUAL_NUM13;
    l_dr_rec.SQUAL_NUM14          :=  p_dr_rec.SQUAL_NUM14;
    l_dr_rec.SQUAL_NUM15          :=  p_dr_rec.SQUAL_NUM15;
    l_dr_rec.SQUAL_NUM16          :=  p_dr_rec.SQUAL_NUM16;
    l_dr_rec.SQUAL_NUM17          :=  p_dr_rec.SQUAL_NUM17;
    l_dr_rec.SQUAL_NUM18          :=  p_dr_rec.SQUAL_NUM18;
    l_dr_rec.SQUAL_NUM19          :=  p_dr_rec.SQUAL_NUM19;
    l_dr_rec.SQUAL_NUM30          :=  p_dr_rec.SQUAL_NUM30;
    l_dr_rec.SQUAL_CHAR11         :=  p_dr_rec.SQUAL_CHAR11;
    l_dr_rec.SQUAL_CHAR12         :=  p_dr_rec.SQUAL_CHAR12;
    l_dr_rec.SQUAL_CHAR13         :=  p_dr_rec.SQUAL_CHAR13;
    l_dr_rec.SQUAL_CHAR20         :=  p_dr_rec.SQUAL_CHAR20;
    l_dr_rec.SQUAL_CHAR21         :=  p_dr_rec.SQUAL_CHAR21;


    IF ( UPPER(p_resource_type) = 'RS_INDIVIDUAL') THEN
      l_p_resource_type := 'RS_INDIVIDUAL';
    ELSIF(p_resource_type is null) THEN
      l_p_resource_type := null;
    ELSE
      l_p_resource_type := p_resource_type;
    END IF;


    IF (p_dr_id IS NOT NULL ) THEN
      l_dr_id := p_dr_id;
    ELSIF (p_dr_rec.service_request_id IS NOT NULL) THEN
      l_dr_id := p_dr_rec.service_request_id;
    END IF;

    -- Assign values to l_dr_sec_rec for DR Security Check
    l_dr_sec_rec.incident_id  := l_dr_id;
    l_dr_sec_rec.incident_type_id  := p_dr_rec.incident_type_id;


    /* Defaulting the variable values to IN parameters,
       if the IN paramaters have values given */

    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE + 14;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;

    -- Get the Profile value to determine the order of preferred resources

    l_pref_res_order  := FND_PROFILE.VALUE ( 'JTF_AM_PREF_RES_ORDER' );


    IF ( p_contracts_preferred_engineer = 'Y'  OR
         p_ib_preferred_engineer        = 'Y') THEN


      l_contract_id := p_contract_id;
      l_cp_id       := p_customer_product_id;


      -- Code to fetch the Preferred Resources for saved DR
      IF (l_contract_id IS NULL AND
          l_cp_id       IS NULL AND
          l_dr_id       IS NOT NULL) THEN

        l_dynamic_sql1 :=  ' SELECT contract_service_id, customer_product_id, expected_resolution_date'||
                           ' FROM   cs_incidents_all_vl'||
                           ' WHERE  incident_id = :1';

        OPEN  cur_cs_incidents FOR  l_dynamic_sql1 USING l_dr_id;
        FETCH cur_cs_incidents INTO l_contract_id,
                                    l_cp_id,
                                    l_expected_end_date;    --Added by SBARAT on 10/12/2004 for bug 4052202
                                    --l_planned_end_date;   --Commented out by SBARAT on 10/12/2004 for bug 4052202

        IF ( cur_cs_incidents%NOTFOUND ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_INVALID_DR_ID');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;

        CLOSE cur_cs_incidents;

        /**********Start of addition by SBARAT on 10/12/2004 for Bug 4052202**********/
        --since this API for DR is same as SR_TASK, added this check to handle
        --NULL or l_expected_end_date < l_planned_start_date as done for SR, SR_TASK

        IF ( l_expected_end_date IS NOT NULL) And (l_expected_end_date >= l_planned_start_date)
        THEN

            l_planned_end_date := l_expected_end_date;

        END IF;

       /**********End of Addition by SBARAT on 10/12/2004 for Bug 4052202**********/

      END IF;  -- end of l_contract_id and l_cp_id null check

    END IF;

    /* Actual Flow of Assignment Manager*/

   -- initiliaze the table type variables
   l_excluded_resource_tbl.delete;
   l_contracts_tbl.delete;
   l_ib_tbl.delete;

   -- get the contracts preferred and excluded engineers
   IF (p_contracts_preferred_engineer = 'Y') THEN
      get_contracts_resources
          (
            p_init_msg_list           =>  p_init_msg_list,
            p_contract_id             =>  l_contract_id,
            p_calendar_flag           =>  p_calendar_flag,
            p_effort_duration         =>  l_effort_duration,
            p_effort_uom              =>  l_effort_uom,
            p_planned_start_date      =>  l_planned_start_date,
            p_planned_end_date        =>  l_planned_end_date,
            p_resource_type           =>  l_p_resource_type,
            p_business_process_id     =>  p_business_process_id,
            p_business_process_date   =>  p_business_process_date,
            x_return_status           =>  x_return_status,
            x_msg_count               =>  x_msg_count,
            x_msg_data                =>  x_msg_data,
            x_assign_resources_tbl    =>  l_contracts_tbl,
            x_excluded_tbl            =>  l_excluded_resource_tbl,
	    --Added for Bug # 5573916
	    p_calendar_check          =>  p_calendar_check
	    --Added for Bug # 5573916 Ends here
          );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_CONTRACTS_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_DR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
    END IF;

   -- get the ib preferred and excluded engineers
    IF (p_ib_preferred_engineer = 'Y') THEN

          get_ib_resources
            (
              p_init_msg_list           =>  p_init_msg_list,
              p_customer_product_id     =>  l_cp_id,
              p_calendar_flag           =>  p_calendar_flag,
              p_effort_duration         =>  l_effort_duration,
              p_effort_uom              =>  l_effort_uom,
              p_planned_start_date      =>  l_planned_start_date,
              p_planned_end_date        =>  l_planned_end_date,
              p_resource_type           =>  l_p_resource_type,
              x_return_status           =>  x_return_status,
              x_msg_count               =>  x_msg_count,
              x_msg_data                =>  x_msg_data,
              x_assign_resources_tbl    =>  l_ib_tbl,
              x_excluded_tbl            =>  l_excluded_resource_tbl,
	      --Added for Bug # 5573916
	      p_calendar_check          =>  p_calendar_check
	      --Added for Bug # 5573916 Ends here
            );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_IB_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_DR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

    END IF; -- p_ib_preferred_engineer = 'Y'

   -- remove excluded resources
  IF(p_filter_excluded_resource = 'Y')
  THEN
     IF(p_contracts_preferred_engineer = 'Y')
      THEN
          remove_excluded(x_res_tbl  => l_contracts_tbl,
                          x_exc_res  => l_excluded_resource_tbl);
      END IF;
      IF(p_ib_preferred_engineer = 'Y')
      THEN
          remove_excluded(x_res_tbl  => l_ib_tbl,
                          x_exc_res  => l_excluded_resource_tbl);
      END IF;
   END IF;


   -- pass returned resources through security check
   IF(l_contracts_tbl.count > 0)
   THEN
       JTF_AM_FILTER_RESOURCE_PVT.SERVICE_SECURITY_CHECK
         (   p_api_version                  =>1.0,
             x_assign_resources_tbl         =>l_contracts_tbl,
             p_sr_tbl                       =>l_dr_sec_rec,
             x_return_status                =>x_return_status ,
             x_msg_count                    =>x_msg_count,
             x_msg_data                     =>x_msg_data);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','SERVICE_SECURITY_CHECK');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_DR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
      END IF;

   end IF; -- end of security check for contracts resource

   IF(l_ib_tbl.count > 0)
   THEN
       JTF_AM_FILTER_RESOURCE_PVT.SERVICE_SECURITY_CHECK
         (   p_api_version                  =>1.0,
             x_assign_resources_tbl         =>l_ib_tbl,
             p_sr_tbl                       =>l_dr_sec_rec,
             x_return_status                =>x_return_status ,
             x_msg_count                    =>x_msg_count,
             x_msg_data                     =>x_msg_data);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','SERVICE_SECURITY_CHECK');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_DR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
      END IF;

   end IF; -- end of security check for contracts resource


    -- after the preferred engineers are obtained from contracts/ib, select the resources
    -- that are to be returned based on the value of the profile for search order and after
    -- filtering out excluded resources
    IF ( upper(l_pref_res_order) = 'CONTRACTS' )
    THEN
        IF (p_contracts_preferred_engineer = 'Y')
        THEN
            table_copy(l_contracts_tbl, l_assign_resources_tbl);
        END IF; -- p_contracts_preferred_engineer = 'Y'


        IF ( l_assign_resources_tbl.COUNT <= 0 )
        THEN
          IF (p_ib_preferred_engineer = 'Y')
          THEN
              table_copy(l_ib_tbl, l_assign_resources_tbl);
          END IF; -- p_ib_preferred_engineer = 'Y'
        END IF; -- l_assign_resources_tbl.COUNT <= 0

    ELSIF ( upper(l_pref_res_order) = 'IB' )
    THEN

        IF (p_ib_preferred_engineer = 'Y')
        THEN
            table_copy(l_ib_tbl, l_assign_resources_tbl);
        END IF; -- p_ib_preferred_engineer = 'Y'

        IF ( l_assign_resources_tbl.COUNT <= 0 )
        THEN
          IF (p_contracts_preferred_engineer = 'Y')
          THEN
              table_copy(l_contracts_tbl, l_assign_resources_tbl);
          END IF; -- p_contracts_preferred_engineer = 'Y'
        END IF; -- l_assign_resources_tbl.COUNT <= 0

    ELSE  -- l_pref_res_order = 'BOTH'

      /* Check if the Contracts Preferred Engineers Profile is SET If it is SET then get the available
         preferred engineers into the table of records */

        IF (p_contracts_preferred_engineer = 'Y')
        THEN
            table_copy(l_contracts_tbl, l_assign_resources_tbl);
        END IF; -- p_contracts_preferred_engineer = 'Y'


      /* Check if the Installed Base Preferred Engineers Profile is SET
         If it is SET then get the available preferred engineers
         into the table of records */

        IF (p_ib_preferred_engineer = 'Y')
        THEN
             table_copy(l_ib_tbl, l_assign_resources_tbl);
        END IF; -- p_ib_preferred_engineer = 'Y'

     END IF; -- l_pref_res_order = 'CONTRACTS' / 'IB' / 'BOTH'


   -- if the Contracts and IB Preferred Engineers are nor found then Territory Qualified Resources are fetched

    IF l_assign_resources_tbl.COUNT <= 0
    THEN
	   IF (p_territory_flag = 'Y') THEN

          IF (l_p_resource_type  = 'RS_INDIVIDUAL') THEN
              l_p_resource_type := NULL;
          END IF;

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught

          l_api_name := l_api_name||'-JTF_TERR_SERVICE_PUB';

          JTF_TERR_SERVICE_PUB.Get_WinningTerrMembers
          (
             p_api_version_number  => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_TerrSrvTask_Rec     => l_dr_rec,
             p_Resource_Type       => l_p_resource_type,
             p_Role                => p_role,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             x_TerrResource_tbl    => l_winningterrmember_tbl
          );

          -- set back the API name to original name
          l_api_name := l_api_name_1;

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Territory Manager
            fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;

          IF(l_winningterrmember_tbl.COUNT > 0)
          THEN
             l_current_record := l_winningterrmember_tbl.FIRST;
             WHILE l_current_record <= l_winningterrmember_tbl.LAST
             LOOP
                IF(l_winningterrmember_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_winningterrmember_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_winningterrmember_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;

        ELSE  -- Territory Flag is NO

          fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
          fnd_msg_pub.add;

        END IF; -- End of p_territory_flag = 'Y'

      IF l_winningterrmember_tbl.COUNT > 0 THEN

        l_current_rec    := 0;
        l_current_record := l_winningterrmember_tbl.FIRST;

        WHILE(l_current_record <=  l_winningterrmember_tbl.LAST)
        LOOP
            l_assign_resources_tbl(l_current_rec).terr_rsc_id           :=
                                   l_winningterrmember_tbl(l_current_record).terr_rsc_id;
            l_assign_resources_tbl(l_current_rec).resource_id           :=
                                   l_winningterrmember_tbl(l_current_record).resource_id;
            l_assign_resources_tbl(l_current_rec).resource_type         :=
                                   l_winningterrmember_tbl(l_current_record).resource_type;
            l_assign_resources_tbl(l_current_rec).role                  :=
                                   l_winningterrmember_tbl(l_current_record).role;
            l_assign_resources_tbl(l_current_rec).start_date            :=
                                   l_winningterrmember_tbl(l_current_record).start_date;
            l_assign_resources_tbl(l_current_rec).end_date              :=
                                   l_winningterrmember_tbl(l_current_record).end_date;
            l_assign_resources_tbl(l_current_rec).shift_construct_id    := NULL;
            l_assign_resources_tbl(l_current_rec).terr_id               :=
                                   l_winningterrmember_tbl(l_current_record).terr_id;
            l_assign_resources_tbl(l_current_rec).terr_name             :=
                                   l_winningterrmember_tbl(l_current_record).terr_name;
            l_assign_resources_tbl(l_current_rec).primary_contact_flag  :=
                                   l_winningterrmember_tbl(l_current_record).primary_contact_flag;
            l_assign_resources_tbl(l_current_rec).primary_flag  :=
                                       l_winningterrmember_tbl(l_current_record).primary_contact_flag;
            l_assign_resources_tbl(l_current_rec).resource_source       := 'TERR';

            l_current_rec    := l_current_rec + 1;
            l_current_record := l_winningterrmember_tbl.NEXT(l_current_record);
       END LOOP;

          l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
          l_return_status_1 := x_return_status ;

           -- call the api to check resource availability

           get_available_resources
            (
              p_init_msg_list                 =>  'F',
              p_calendar_flag                 =>   p_calendar_flag,
              p_effort_duration               =>  l_effort_duration,
              p_effort_uom                    =>  l_effort_uom,
              p_planned_start_date            =>  l_planned_start_date,
              p_planned_end_date              =>  l_planned_end_date,
              p_breakdown                     =>   null,
              p_breakdown_uom                 =>   null,
              p_continuous_task               =>   jtf_assign_pub.g_continuous_work,
              x_return_status                 =>   x_return_status,
              x_msg_count                     =>   x_msg_count,
              x_msg_data                      =>   x_msg_data,
              x_assign_resources_tbl          =>   l_assign_resources_tbl,
	      --Added for Bug # 5573916
	      p_calendar_check                =>   p_calendar_check
	      --Added for Bug # 5573916 Ends here
	      );

          -- set back the API name to original name

          l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
               fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
               fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
               fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_DR_RESOURCES');
               fnd_msg_pub.add;
               IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
               ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
             END IF; -- end of x_return_status check

        IF ( p_calendar_flag = 'Y' AND
          l_assign_resources_tbl.count = 0 ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
          fnd_msg_pub.add;
        END IF;


         -- remove excluded resources from territory qualifeid resource list

         IF(p_filter_excluded_resource = 'Y')
         THEN
              remove_excluded(x_res_tbl  => l_assign_resources_tbl,
                              x_exc_res  => l_excluded_resource_tbl);
         END IF;

          IF(l_assign_resources_tbl.count > 0)
          THEN
             JTF_AM_FILTER_RESOURCE_PVT.SERVICE_SECURITY_CHECK
              (   p_api_version                  =>1.0,
                  x_assign_resources_tbl         =>l_assign_resources_tbl,
                  p_sr_tbl                       =>l_dr_sec_rec,
                  x_return_status                =>x_return_status ,
                  x_msg_count                    =>x_msg_count,
                  x_msg_data                     =>x_msg_data);

              IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
             -- Unexpected Execution Error from call to Get_contracts_resources
                  fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                  fnd_message.set_token('P_PROC_NAME','SERVICE_SECURITY_CHECK');
                  fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_DR_RESOURCES');
                  fnd_msg_pub.add;
                  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                    RAISE fnd_api.g_exc_error;
                  ELSE
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
              END IF;
          END IF; -- end of security check
      ELSE   -- No resources returned from the Territory API

        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
      END IF;


      -- Logic for getting resources belonging to group id passed in
      -- get the profile value to see if you have to filter by group membership

      l_group_filter :=  nvl(FND_PROFILE.VALUE ('JTF_AM_GROUP_MEMBER_FILTER'), 'YES');

      IF(l_group_filter = 'YES')
      THEN
         IF((p_dr_rec.squal_num17 is not null) )
         THEN
            get_group_resource(p_dr_rec.squal_num17 ,
                            l_assign_resources_tbl );
         END IF;

      END IF;

    END IF; -- End of l_assign_resources_tbl.COUNT <= 0


    -- Start of enhancement for showing Individual Resources ONLY

    IF ( UPPER(p_resource_type) = 'RS_INDIVIDUAL' ) THEN

      -- Reconstructing the table to further do the enhancements

      IF ( l_assign_resources_tbl.COUNT > 0 ) THEN

        l_current_record := l_assign_resources_tbl.FIRST;
        l_current_rec    := 1;

        WHILE l_current_record <= l_assign_resources_tbl.LAST
        LOOP

          l_tbl(l_current_rec).resource_id           :=
                                 l_assign_resources_tbl(l_current_record).resource_id;
          l_tbl(l_current_rec).resource_type         :=
                                 l_assign_resources_tbl(l_current_record).resource_type;

          l_tbl(l_current_rec).start_date            :=
                                 l_assign_resources_tbl(l_current_record).start_date;
          l_tbl(l_current_rec).end_date              :=
                                 l_assign_resources_tbl(l_current_record).end_date;
          l_tbl(l_current_rec).shift_construct_id    :=
                                 l_assign_resources_tbl(l_current_record).shift_construct_id;

          l_tbl(l_current_rec).terr_rsc_id           :=
                                 l_assign_resources_tbl(l_current_record).terr_rsc_id;
          l_tbl(l_current_rec).role                  :=
                                 l_assign_resources_tbl(l_current_record).role;
          l_tbl(l_current_rec).terr_id               :=
                                 l_assign_resources_tbl(l_current_record).terr_id;
          l_tbl(l_current_rec).terr_name             :=
                                 l_assign_resources_tbl(l_current_record).terr_name;
          l_tbl(l_current_rec).primary_contact_flag  :=
                                 l_assign_resources_tbl(l_current_record).primary_contact_flag;
          l_tbl(l_current_rec).preference_type       :=
                                 l_assign_resources_tbl(l_current_record).preference_type;
          l_tbl(l_current_rec).group_id              :=
                                 l_assign_resources_tbl(l_current_record).group_id;

          l_tbl(l_current_rec).primary_flag          :=
                                 l_assign_resources_tbl(l_current_record).primary_flag;

          l_tbl(l_current_rec).resource_source       :=
                                 l_assign_resources_tbl(l_current_record).resource_source;

          l_current_rec    := l_current_rec + 1;
          l_current_record := l_assign_resources_tbl.NEXT(l_current_record);

        END LOOP;

      END IF; --End of l_assign_resources_tbl.COUNT > 0

      -- End of reconstruction


      IF ( l_tbl.COUNT > 0 ) THEN

        l_current_record := l_tbl.FIRST;
        l_current_rec    := 0;

        l_assign_resources_tbl.delete;

        WHILE l_current_record <= l_tbl.LAST
        LOOP
          IF ( UPPER(l_tbl(l_current_record).resource_type) NOT IN ( 'RS_GROUP', 'RS_TEAM')) THEN

            l_assign_resources_tbl(l_current_rec).resource_id           :=
                                   l_tbl(l_current_record).resource_id;
            l_assign_resources_tbl(l_current_rec).resource_type         :=
                                   l_tbl(l_current_record).resource_type;

            l_assign_resources_tbl(l_current_rec).start_date            :=
                                   l_tbl(l_current_record).start_date;
            l_assign_resources_tbl(l_current_rec).end_date              :=
                                   l_tbl(l_current_record).end_date;
            l_assign_resources_tbl(l_current_rec).shift_construct_id    :=
                                   l_tbl(l_current_record).shift_construct_id;

            l_assign_resources_tbl(l_current_rec).terr_rsc_id           :=
                                   l_tbl(l_current_record).terr_rsc_id;
            l_assign_resources_tbl(l_current_rec).role                  :=
                                   l_tbl(l_current_record).role;
            l_assign_resources_tbl(l_current_rec).terr_id               :=
                                   l_tbl(l_current_record).terr_id;
            l_assign_resources_tbl(l_current_rec).terr_name             :=
                                   l_tbl(l_current_record).terr_name;
            l_assign_resources_tbl(l_current_rec).primary_contact_flag  :=
                                   l_tbl(l_current_record).primary_contact_flag;
            l_assign_resources_tbl(l_current_rec).preference_type       :=
                                   l_tbl(l_current_record).preference_type;
            l_assign_resources_tbl(l_current_rec).group_id              :=
                                   l_tbl(l_current_record).group_id;

            l_assign_resources_tbl(l_current_rec).primary_flag          :=
                                   l_tbl(l_current_record).primary_flag;

            l_assign_resources_tbl(l_current_rec).resource_source       :=
                                   l_tbl(l_current_record).resource_source;

            l_current_rec := l_current_rec + 1;

          END IF;
          l_current_record := l_tbl.NEXT(l_current_record);

        END LOOP;

      END IF; --End of l_tbl.COUNT > 0

    END IF;   --End of p_resource_type = 'RS_INDIVIDUAL'


    -- To add SUPPORT SITE ID and NAME to the OUT Table

    l_dynamic_sql3 := ' SELECT a.city city '||
                      ' FROM   hz_locations a, hz_party_sites b,  hz_party_site_uses c '||
                      ' WHERE  c.site_use_type = :1  AND '||
                      ' b.party_site_id        = :2 AND '||
                      ' a.location_id          = b.location_id   AND '||
                      ' c.party_site_id        = b.party_site_id ';

    IF l_assign_resources_tbl.COUNT > 0 THEN

      l_current_record := l_assign_resources_tbl.FIRST;

      WHILE l_current_record <= l_assign_resources_tbl.LAST
      LOOP

        l_rsc_type := resource_type_change(l_assign_resources_tbl(l_current_record).resource_type);

        OPEN  cur_support_site_id (l_assign_resources_tbl(l_current_record).resource_id,
                                   l_rsc_type);
        FETCH cur_support_site_id INTO l_assign_resources_tbl(l_current_record).support_site_id;

        IF (l_assign_resources_tbl(l_current_record).support_site_id IS NOT NULL) THEN

          OPEN  cur_support_site_name FOR l_dynamic_sql3
                USING l_support_site,
                      l_assign_resources_tbl(l_current_record).support_site_id;

          FETCH cur_support_site_name INTO l_assign_resources_tbl(l_current_record).support_site_name;
          IF (  cur_support_site_name % NOTFOUND ) THEN
            l_assign_resources_tbl(l_current_record).support_site_name := NULL;
          END IF;
          CLOSE cur_support_site_name;
        ELSE
          l_assign_resources_tbl(l_current_record).support_site_id   := NULL;
          l_assign_resources_tbl(l_current_record).support_site_name := NULL;

        END IF;

        CLOSE cur_support_site_id;

        l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;


    -- To add Web Availability to the OUT Table

    IF (l_assign_resources_tbl.COUNT > 0) THEN

      l_current_record := l_assign_resources_tbl.FIRST;

      WHILE l_current_record <= l_assign_resources_tbl.LAST
      LOOP

        IF ( UPPER(p_web_availability_flag) = 'Y') THEN
          l_rsc_type := resource_type_change(l_assign_resources_tbl(l_current_record).resource_type);

          OPEN  cur_web_availability (l_assign_resources_tbl(l_current_record).resource_id,
                                      l_rsc_type);
          FETCH cur_web_availability INTO l_rsc_id;

          IF (cur_web_availability%FOUND) THEN
            l_assign_resources_tbl(l_current_record).web_availability_flag := 'Y';
          ELSE
            l_assign_resources_tbl(l_current_record).web_availability_flag := 'N';
          END IF;

          CLOSE cur_web_availability;
        ELSE
          l_assign_resources_tbl(l_current_record).web_availability_flag := NULL;
        END IF; --p_web_availability_flag = 'Y'

        l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;


  -- skills bank filter call to api  JTF_AM_FILTER_RESOURCE_PVT
  -- initialize values of the skill table
       l_skill_tbl(1).document_type   := 'DR';
       l_skill_tbl(1).category_id     := p_category_id;
       l_skill_tbl(1).product_id      := p_inventory_item_id;
       l_skill_tbl(1).product_org_id  := p_inventory_org_id;
      l_skill_tbl(1).problem_code    := p_problem_code;

       -- change the API Name temporarily so that in case of unexpected error
       -- it is properly caught
       l_api_name := l_api_name||'-JTF_AM_FILTER_RESOURCE_PVT';

     JTF_AM_FILTER_RESOURCE_PVT.SEARCH_SKILL
                       ( p_api_version => 1.0,
                         x_assign_resources_tbl => l_assign_resources_tbl,
                         p_skill_param_tbl => l_skill_tbl,
                         x_return_status   => l_skill_ret_sts,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data );

    -- set back the API name to original name
    l_api_name := l_api_name_1;

    if(l_skill_ret_sts <>  fnd_api.g_ret_sts_success)
    then
      IF (l_skill_ret_sts = fnd_api.g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      ELSE
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    end if;


      -- added this to filter by usage

      IF ((l_assign_resources_tbl.count > 0 ) AND
          (nvl(l_usage, fnd_api.g_miss_char)  <> 'ALL' ) AND
          (l_usage is not null)
         )
      THEN
          get_usage_resource(l_usage ,
                             l_assign_resources_tbl);
      END IF;


      IF l_assign_resources_tbl.COUNT > 0 THEN

        l_current_record := l_assign_resources_tbl.FIRST;

        IF ( UPPER(l_auto_select_flag) = 'Y' ) THEN

            l_no_of_resources := least(nvl(l_assign_resources_tbl.count, 0),l_no_of_resources) ;

          WHILE (l_count < l_no_of_resources)
          LOOP

          open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
          fetch check_date_cur into l_value;
          if (check_date_cur%found)
          then

            l_count := l_count + 1;

            x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_count).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_count).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;
            x_assign_resources_tbl(l_count).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
            x_assign_resources_tbl(l_count).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
            x_assign_resources_tbl(l_count).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
            x_assign_resources_tbl(l_count).shift_construct_id    :=
                                   l_assign_resources_tbl(l_current_record).shift_construct_id;
            x_assign_resources_tbl(l_count).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_count).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
            x_assign_resources_tbl(l_count).preference_type       :=
                                   l_assign_resources_tbl(l_current_record).preference_type;
            x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_count).group_id              :=
                                   l_assign_resources_tbl(l_current_record).group_id;

            x_assign_resources_tbl(l_count).support_site_id       :=
                                   l_assign_resources_tbl(l_current_record).support_site_id;
            x_assign_resources_tbl(l_count).support_site_name     :=
                                   l_assign_resources_tbl(l_current_record).support_site_name;
            x_assign_resources_tbl(l_count).web_availability_flag :=
                                   l_assign_resources_tbl(l_current_record).web_availability_flag;

            x_assign_resources_tbl(l_count).skill_level           :=
                                   l_assign_resources_tbl(l_current_record).skill_level;
            x_assign_resources_tbl(l_count).skill_name            :=
                                   l_assign_resources_tbl(l_current_record).skill_name;
            x_assign_resources_tbl(l_count).primary_flag            :=
                                   l_assign_resources_tbl(l_current_record).primary_flag;
            x_assign_resources_tbl(l_count).resource_source       :=
                                   l_assign_resources_tbl(l_current_record).resource_source;
            end if;
            close check_date_cur;
            l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
          END LOOP;

        ELSE  -- Auto Select Flag is NO

          WHILE l_current_record <= l_assign_resources_tbl.LAST
          LOOP

             open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
             fetch check_date_cur into l_value;
             if (check_date_cur%found)
             then
               l_count := l_count + 1;

               x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
               x_assign_resources_tbl(l_count).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
               x_assign_resources_tbl(l_count).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;
               x_assign_resources_tbl(l_count).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
               x_assign_resources_tbl(l_count).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
               x_assign_resources_tbl(l_count).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
               x_assign_resources_tbl(l_count).shift_construct_id    :=
                                   l_assign_resources_tbl(l_current_record).shift_construct_id;
               x_assign_resources_tbl(l_count).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
               x_assign_resources_tbl(l_count).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
               x_assign_resources_tbl(l_count).preference_type       :=
                                   l_assign_resources_tbl(l_current_record).preference_type;
               x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
               x_assign_resources_tbl(l_count).group_id              :=
                                   l_assign_resources_tbl(l_current_record).group_id;

               x_assign_resources_tbl(l_count).support_site_id       :=
                                   l_assign_resources_tbl(l_current_record).support_site_id;
               x_assign_resources_tbl(l_count).support_site_name     :=
                                   l_assign_resources_tbl(l_current_record).support_site_name;
               x_assign_resources_tbl(l_count).web_availability_flag :=
                                   l_assign_resources_tbl(l_current_record).web_availability_flag;

               x_assign_resources_tbl(l_count).skill_level           :=
                                   l_assign_resources_tbl(l_current_record).skill_level;
               x_assign_resources_tbl(l_count).skill_name            :=
                                   l_assign_resources_tbl(l_current_record).skill_name;
               x_assign_resources_tbl(l_count).primary_flag            :=
                                   l_assign_resources_tbl(l_current_record).primary_flag;
               x_assign_resources_tbl(l_count).resource_source       :=
                                   l_assign_resources_tbl(l_current_record).resource_source;
               end if;
               close check_date_cur;
               l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
          END LOOP;
        END IF;   -- Auto Select Flag

      ELSE
        -- No resources returned from the Assignment Manager API for SERVICE REQUESTS
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
      END IF;


      -- Raise Workflow Event
      -- Workflow Test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_dr_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_CONTRACT_ID           =>  p_contract_id   ,
                     P_CUSTOMER_PRODUCT_ID   =>  p_customer_product_id   ,
                     P_CATEGORY_ID           =>  p_category_id   ,
                     P_INVENTORY_ITEM_ID     =>  p_inventory_item_id   ,
                     P_INVENTORY_ORG_ID      =>  p_inventory_org_id   ,
                     P_PROBLEM_CODE          =>  p_problem_code ,
                     P_DR_REC                =>  p_dr_rec,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


         IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_dr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_RESOURCES');
            fnd_msg_pub.add;

        ELSE
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;


         Exception
            When Others Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;



    -- To Plugin the Workflow enabling the user
    -- to further filter the resources

    SELECT jtf_calendars_s.NEXTVAL INTO l_workflow_key
    FROM   dual;

    IF (JTF_USR_HKS.ok_to_execute
          (
            'JTF_ASSIGN_PUB',
            'GET_ASSIGN_DR_RESOURCES',
            'W',
            'W'
          )
       ) THEN

      IF (JTF_ASSIGN_CUHK.ok_to_launch_workflow
            (
              p_api_version     => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data
            )
         ) THEN


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;


        l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

        JTF_USR_HKS.WrkFlowLaunch
          (
            'JTF_ASSIGN_WF',
            l_workflow_profile,
            'ASSIGN WF - '|| TO_CHAR(l_workflow_key),
            l_bind_data_id,
            l_return_code
          );

        JTF_USR_HKS.purge_bind_data
          (
            l_bind_data_id,
            'W'
          );


        IF (l_return_code = fnd_api.g_ret_sts_error) THEN
          -- Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_return_code = fnd_api.g_ret_sts_unexp_error) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;  -- End of JTF_ASSIGN_CUHK

    END IF;    -- End of JTF_USR_HKS


    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );


    x_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_DR_RESOURCES;

 /*************** End of addition by SBARAT on 01/11/2004 for Enh-3919046*********/


-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_OPPR_RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is
--                        OPPORTUNITIES.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT = FND_API.G_FALSE
--                        p_commit              IN      VARCHAR2 optional
--                                              DEFAULT = FND_API.G_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N


--     This parameter contains the Qualifier values for the
--     Calling Document.
--     p_opportunity_rec                         JTF_ASSIGN_PUB.
--                                               JTF_Oppor_rec_type
--                                               REQUIRED


--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--     Version          : Current version        1.0
--                        Initial version        1.0
--
--     Notes            :
--

-- End of comments

-- *********************************************************************************



--      Procedure definition with the parameters when the
--      Source Document is OPPORTUNITIES

  PROCEDURE GET_ASSIGN_OPPR_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_opportunity_rec                     IN  JTF_ASSIGN_PUB.JTF_Oppor_rec_type,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_OPPR_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_OPPR_RESOURCES';
    l_api_version                         NUMBER        := 1.0;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);
    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(30)  := 'HR';

    l_current_record                      INTEGER;
    l_total_records                       INTEGER;

    l_auto_select_profile                 VARCHAR2(03);
    l_auto_select_flag                    VARCHAR2(03);
    l_workflow_profile                    VARCHAR2(60);

    l_return_code                         VARCHAR2(60);
    l_bind_data_id                        NUMBER;
    l_workflow_key                        NUMBER;

    l_assign_resources_tbl                JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_opportunity_rec                     JTF_TERRITORY_PUB.JTF_Oppor_rec_type;

    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    l_wf_return_status                    VARCHAR2(60);
    l_wf_msg_count                        NUMBER;
    l_wf_msg_data                         VARCHAR2(2000);

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    /*
    l_dynamic_sql                         VARCHAR2(2000);
    l_column_list                         VARCHAR2(2000);
    TYPE OPPR_CUR_TYP IS REF CURSOR;
    cur_oppr  OPPR_CUR_TYP;
    */

    --Bug# 4455803 MOAC.
    CURSOR check_date_cur(l_resource_id in number,
                          l_resource_type in varchar2)
        IS
     SELECT 'Y'
       --FROM  jtf_rs_all_resources_vl
       FROM  jtf_task_resources_vl
      where   resource_id = l_resource_id
        and   resource_type = l_resource_type
        and   nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);

    l_value varchar2(100);

    l_count number := 0;
    l_temp_table   JTF_ASSIGN_PUB.AssignResources_tbl_type;

  BEGIN

    SAVEPOINT get_assign_oppr_resources;

    -- Started Assignment Manager API for OPPORTUNITIES


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;



    /* Getting the Auto Select Profile value defined for the Assignment Manager */

    --l_auto_select_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_AUTO_SELECT' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_auto_select_profile := FND_PROFILE.VALUE ( 'ACTIVATE_AUTO_SELECT' ); -- Added by SBARAT on 12/10/2004, Bug-3830061



    /* Assigning the DEFAULT value to the Auto Select Parameter */


    IF (p_auto_select_flag IS NULL) THEN
      l_auto_select_flag  := l_auto_select_profile;
                             -- PROFILE VALUE is the default value
    ELSE
      l_auto_select_flag  := p_auto_select_flag;
    END IF;



    /* Query the Opportunities View to get the data into
       the Record Type to pass it to the Territory API */

    /*
    IF (p_column_list IS NULL) THEN
      l_column_list := '*';
    ELSE
      l_column_list := p_column_list;
    END IF;


    l_dynamic_sql :=  'SELECT '||
                       l_column_list||
                       ' FROM jtf_terr_opportunities_v'||
                       ' WHERE lead_id = :1';

    OPEN cur_oppr FOR l_dynamic_sql USING p_opportunity_id;
    FETCH cur_oppr INTO l_assign_resources_rec;
    IF (cur_oppr%NOTFOUND) THEN
      fnd_message.set_name('JTF', 'JTF_AM_INVALID_OPPR_ID');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE cur_oppr;
    */



    /* Defaulting the variable values to IN parameters,
       if the IN paramaters have values given */

    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;



    /* Assigning values to the Opportunity Record Type */


    l_opportunity_rec.LEAD_ID                        := p_opportunity_rec.LEAD_ID;
    l_opportunity_rec.LEAD_LINE_ID                   := p_opportunity_rec.LEAD_LINE_ID;
    l_opportunity_rec.CITY                           := p_opportunity_rec.CITY;
    l_opportunity_rec.POSTAL_CODE                    := p_opportunity_rec.POSTAL_CODE;
    l_opportunity_rec.STATE                          := p_opportunity_rec.STATE;
    l_opportunity_rec.PROVINCE                       := p_opportunity_rec.PROVINCE;
    l_opportunity_rec.COUNTY                         := p_opportunity_rec.COUNTY;
    l_opportunity_rec.COUNTRY                        := p_opportunity_rec.COUNTRY;
    l_opportunity_rec.INTEREST_TYPE_ID               := p_opportunity_rec.INTEREST_TYPE_ID;
    l_opportunity_rec.PRIMARY_INTEREST_ID            := p_opportunity_rec.PRIMARY_INTEREST_ID;
    l_opportunity_rec.SECONDARY_INTEREST_ID          := p_opportunity_rec.SECONDARY_INTEREST_ID;
    l_opportunity_rec.CONTACT_INTEREST_TYPE_ID       := p_opportunity_rec.CONTACT_INTEREST_TYPE_ID;
    l_opportunity_rec.CONTACT_PRIMARY_INTEREST_ID    := p_opportunity_rec.CONTACT_PRIMARY_INTEREST_ID;
    l_opportunity_rec.CONTACT_SECONDARY_INTEREST_ID  := p_opportunity_rec.CONTACT_SECONDARY_INTEREST_ID;
    l_opportunity_rec.PARTY_SITE_ID                  := p_opportunity_rec.PARTY_SITE_ID;
    l_opportunity_rec.AREA_CODE                      := p_opportunity_rec.AREA_CODE;
    l_opportunity_rec.PARTY_ID                       := p_opportunity_rec.PARTY_ID;
    l_opportunity_rec.COMP_NAME_RANGE                := p_opportunity_rec.COMP_NAME_RANGE;
    l_opportunity_rec.PARTNER_ID                     := p_opportunity_rec.PARTNER_ID;
    l_opportunity_rec.NUM_OF_EMPLOYEES               := p_opportunity_rec.NUM_OF_EMPLOYEES;
    l_opportunity_rec.CATEGORY_CODE                  := p_opportunity_rec.CATEGORY_CODE;
    l_opportunity_rec.PARTY_RELATIONSHIP_ID          := p_opportunity_rec.PARTY_RELATIONSHIP_ID;
    l_opportunity_rec.SIC_CODE                       := p_opportunity_rec.SIC_CODE;
    l_opportunity_rec.TARGET_SEGMENT_CURRENT         := p_opportunity_rec.TARGET_SEGMENT_CURRENT;
    l_opportunity_rec.TOTAL_AMOUNT                   := p_opportunity_rec.TOTAL_AMOUNT;
    l_opportunity_rec.CURRENCY_CODE                  := p_opportunity_rec.CURRENCY_CODE;
    l_opportunity_rec.PRICING_DATE                   := p_opportunity_rec.PRICING_DATE;
    l_opportunity_rec.CHANNEL_CODE                   := p_opportunity_rec.CHANNEL_CODE;
    l_opportunity_rec.INVENTORY_ITEM_ID              := p_opportunity_rec.INVENTORY_ITEM_ID;
    l_opportunity_rec.OPP_INTEREST_TYPE_ID           := p_opportunity_rec.OPP_INTEREST_TYPE_ID;
    l_opportunity_rec.OPP_PRIMARY_INTEREST_ID        := p_opportunity_rec.OPP_PRIMARY_INTEREST_ID;
    l_opportunity_rec.OPP_SECONDARY_INTEREST_ID      := p_opportunity_rec.OPP_SECONDARY_INTEREST_ID;
    l_opportunity_rec.OPCLSS_INTEREST_TYPE_ID        := p_opportunity_rec.OPCLSS_INTEREST_TYPE_ID;
    l_opportunity_rec.OPCLSS_PRIMARY_INTEREST_ID     := p_opportunity_rec.OPCLSS_PRIMARY_INTEREST_ID;
    l_opportunity_rec.OPCLSS_SECONDARY_INTEREST_ID   := p_opportunity_rec.OPCLSS_SECONDARY_INTEREST_ID;
    l_opportunity_rec.ATTRIBUTE1                     := p_opportunity_rec.ATTRIBUTE1;
    l_opportunity_rec.ATTRIBUTE2                     := p_opportunity_rec.ATTRIBUTE2;
    l_opportunity_rec.ATTRIBUTE3                     := p_opportunity_rec.ATTRIBUTE3;
    l_opportunity_rec.ATTRIBUTE4                     := p_opportunity_rec.ATTRIBUTE4;
    l_opportunity_rec.ATTRIBUTE5                     := p_opportunity_rec.ATTRIBUTE5;
    l_opportunity_rec.ATTRIBUTE6                     := p_opportunity_rec.ATTRIBUTE6;
    l_opportunity_rec.ATTRIBUTE7                     := p_opportunity_rec.ATTRIBUTE7;
    l_opportunity_rec.ATTRIBUTE8                     := p_opportunity_rec.ATTRIBUTE8;
    l_opportunity_rec.ATTRIBUTE9                     := p_opportunity_rec.ATTRIBUTE9;
    l_opportunity_rec.ATTRIBUTE10                    := p_opportunity_rec.ATTRIBUTE10;
    l_opportunity_rec.ATTRIBUTE11                    := p_opportunity_rec.ATTRIBUTE11;
    l_opportunity_rec.ATTRIBUTE12                    := p_opportunity_rec.ATTRIBUTE12;
    l_opportunity_rec.ATTRIBUTE13                    := p_opportunity_rec.ATTRIBUTE13;
    l_opportunity_rec.ATTRIBUTE14                    := p_opportunity_rec.ATTRIBUTE14;
    l_opportunity_rec.ATTRIBUTE15                    := p_opportunity_rec.ATTRIBUTE15;
    l_opportunity_rec.ORG_ID                         := p_opportunity_rec.ORG_ID;





    /* Actual Flow of Assignment Manager */


    IF (p_territory_flag = 'Y') THEN

      -- change the API Name temporarily so that in case of unexpected error
      -- it is properly caught
      l_api_name := l_api_name||'-JTF_TERR_SALES_PUB';

      JTF_TERR_SALES_PUB.Get_WinningTerrMembers
        (
          p_api_version_number  => l_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_TerrOppor_Rec       => l_opportunity_rec,
          p_Resource_Type       => p_resource_type,
          p_Role                => p_role,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_TerrResource_tbl    => l_assign_resources_tbl
        );

        -- set back the API name to original name
        l_api_name := l_api_name_1;


      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
        -- Unexpected Execution Error from call to Territory Manager
        fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
        fnd_msg_pub.add;
        IF (x_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;


       -- added 2 april 2003 by sudarsana to conver RS_SUPPLIER TO RS_SUPPLIER_CONTACT

          IF(l_assign_resources_tbl.COUNT > 0)
          THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;

        IF l_assign_resources_tbl.COUNT > 0 THEN

          l_current_record := l_assign_resources_tbl.FIRST;

        -- removed the calendar check here. calling the procedure for calendar check in the next step
        -- calendar check removed 29th September 2003

          WHILE l_current_record <= l_assign_resources_tbl.LAST
          LOOP
            -- Check the calendar for resource availability
            -- Call Calendar API
            -- IF the resource is available then accept the values and
            -- check for the WORKFLOW profile option

            -- The following IF statement is to implement Auto Select Feature
              open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                                  l_assign_resources_tbl(l_current_record).resource_type);
              fetch check_date_cur into l_value;
              if (check_date_cur%found)
              then

                  l_count := l_count + 1;
                  x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                     l_assign_resources_tbl(l_current_record).terr_rsc_id;
                  x_assign_resources_tbl(l_count).resource_id           :=
                                     l_assign_resources_tbl(l_current_record).resource_id;
                  x_assign_resources_tbl(l_count).resource_type         :=
                                     l_assign_resources_tbl(l_current_record).resource_type;
                  x_assign_resources_tbl(l_count).role                  :=
                                     l_assign_resources_tbl(l_current_record).role;
                  x_assign_resources_tbl(l_count).start_date            :=
                                     l_assign_resources_tbl(l_current_record).start_date;
                  x_assign_resources_tbl(l_count).end_date              :=
                                     l_assign_resources_tbl(l_current_record).end_date;
                  x_assign_resources_tbl(l_count).shift_construct_id    := NULL;
                  x_assign_resources_tbl(l_count).terr_id               :=
                                     l_assign_resources_tbl(l_current_record).terr_id;
                  x_assign_resources_tbl(l_count).terr_name             :=
                                     l_assign_resources_tbl(l_current_record).terr_name;
                  x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                     l_assign_resources_tbl(l_current_record).primary_contact_flag;
                  x_assign_resources_tbl(l_count).full_access_flag      :=
                                     l_assign_resources_tbl(l_current_record).full_access_flag;
                  x_assign_resources_tbl(l_count).group_id              :=
                                     l_assign_resources_tbl(l_current_record).group_id;
                  x_assign_resources_tbl(l_count).primary_flag              :=
                                     l_assign_resources_tbl(l_current_record).primary_contact_flag;
                  x_assign_resources_tbl(l_count).resource_source       := 'TERR';

                END IF; -- end of check_date_cur
                close check_date_cur;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
        END LOOP;

      -- added calendar call out
      -- this has been done as now the calendar check is done in a seperate procedure GET_AVAILABLE_RESOURCE
      -- changed on 29th September 2003
        IF (p_calendar_flag = 'Y') THEN
             -- change the API Name temporarily so that in case of unexpected error
             -- it is properly caught
              l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
              l_return_status_1 := x_return_status ;
              -- call the api to check resource availability
              get_available_resources
              (
                p_init_msg_list                 =>  'F',
                p_calendar_flag                 =>  p_calendar_flag,
                p_effort_duration               =>  l_effort_duration,
                p_effort_uom                    =>  l_effort_uom,
                p_planned_start_date            =>  l_planned_start_date,
                p_planned_end_date              =>  l_planned_end_date,
                p_continuous_task               =>  jtf_assign_pub.g_continuous_work,
                x_return_status                 =>  x_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data,
                x_assign_resources_tbl          =>  x_assign_resources_tbl);

              -- set back the API name to original name
               l_api_name := l_api_name_1;

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
                 fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_OPPR_RESOURCES');
                 fnd_msg_pub.add;
                 IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
                 ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF; -- end of x_return_status check
        end if; -- if p_calendar_flag = Y

        IF ( p_calendar_flag = 'Y' AND
             x_assign_resources_tbl.count = 0 ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
          fnd_msg_pub.add;
--          RAISE fnd_api.g_exc_error;
        END IF;

        -- check auto assignment
        -- if auto assignment is Y then return only the number of resources that have been requested
        IF(l_auto_select_flag = 'Y')
        THEN
          l_temp_table.delete;
          l_temp_table := x_assign_resources_tbl;
          x_assign_resources_tbl.delete;
          l_count := 0;
          l_current_record := l_temp_table.FIRST;
          l_total_records := p_no_of_resources;

          WHILE l_current_record <= l_temp_table.LAST
          LOOP
             If(l_count < l_total_records)
             THEN
                 x_assign_resources_tbl(l_count) := l_temp_table(l_current_record);
                 l_count := l_count + 1;
             end if; -- end of count check
             l_current_record := l_temp_table.NEXT(l_current_record);
          END LOOP; -- end of courrent record check

         END IF; -- end of auto select flag

      ELSE   -- No resources returned from the Territory API
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE  -- Territory Flag is NO
      fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
      fnd_msg_pub.add;
--      RAISE fnd_api.g_exc_error;
    END IF;

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

      -- raise workfow event
      -- workflow test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_oppr_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_OPPR_REC	         =>  p_opportunity_rec,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_sr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_OPPR_RESOURCES');
            fnd_msg_pub.add;

        ELSE
		x_assign_resources_tbl.delete;
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;


      Exception
            When OTHERS Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/


    -- To Plugin the Workflow enabling the user
    -- to further filter the resources

    /* Getting the Workflow Profile value defined for the Assignment Manager */

    --l_workflow_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_WORKFLOW_NAME' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_workflow_profile := FND_PROFILE.VALUE ( 'ACTIVATE_WORKFLOW_NAME' ); -- Added by SBARAT on 12/10/2004, Bug-3830061

    SELECT jtf_calendars_s.NEXTVAL INTO l_workflow_key
    FROM   dual;

    IF (JTF_USR_HKS.ok_to_execute
          (
            'JTF_ASSIGN_PUB',
            'GET_ASSIGN_OPPR_RESOURCES',
            'W',
            'W'
          )
       ) THEN

      IF (JTF_ASSIGN_CUHK.ok_to_launch_workflow
            (
              p_api_version     => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data
            )
         ) THEN

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

        JTF_USR_HKS.WrkFlowLaunch
          (
            'JTF_ASSIGN_WF',
            l_workflow_profile,
            'ASSIGN WF - '|| TO_CHAR(l_workflow_key),
            l_bind_data_id,
            l_return_code
          );

        JTF_USR_HKS.purge_bind_data
          (
            l_bind_data_id,
            'W'
          );

        IF (l_return_code = fnd_api.g_ret_sts_error) THEN
          -- Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_return_code = fnd_api.g_ret_sts_unexp_error) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;  -- End of JTF_ASSIGN_CUHK

    END IF;    -- End of JTF_USR_HKS





    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_OPPR_RESOURCES;



-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_LEAD_RESOURCES (For BULK Record)
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is
--                        LEADS.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT JTF_ASSIGN_PUB.AM_FALSE
--                        p_commit              IN      VARCHAR2 optional
--                                              DEFAULT JTF_ASSIGN_PUB.AM_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N


--     This parameter contains the values of the Qualifiers
--     defined for the Sales Leads.
--     p_lead_rec                               JTF_TERRITORY_PUB.
--                                              JTF_Lead_BULK_rec_type
--                                              REQUIRED

--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--      Version         : Current version        1.0
--                        Initial version        1.0
--
--      Notes           :
--

-- End of comments

-- *********************************************************************************



--      Procedure definition with the parameters when the
--      Source Document is SALES LEADS

  PROCEDURE GET_ASSIGN_LEAD_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_lead_rec                            IN  JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type,
--      x_assign_resources_bulk_rec           OUT NOCOPY JTF_TERRITORY_PUB.WINNING_BULK_REC_TYPE,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_LEAD_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_LEAD_RESOURCES';
    l_api_version                         NUMBER        := 1.0;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);
    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(30)  := 'HR';

    l_current_record                      INTEGER;
    l_total_records                       INTEGER;

    l_auto_select_profile                 VARCHAR2(03);
    l_auto_select_flag                    VARCHAR2(03);
    l_workflow_profile                    VARCHAR2(60);

    l_return_code                         VARCHAR2(60);
    l_bind_data_id                        NUMBER;
    l_workflow_key                        NUMBER;

    l_assign_resources_bulk_rec           JTF_TERRITORY_PUB.WINNING_BULK_REC_TYPE;
    --l_lead_rec                          JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type;
    --l_assign_resources_tbl              JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;

    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    l_wf_return_status                    VARCHAR2(60);
    l_wf_msg_count                        NUMBER;
    l_wf_msg_data                         VARCHAR2(2000);

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

     --Bug# 4455803 MOAC.
     CURSOR check_date_cur(l_resource_id in number,
                          l_resource_type in varchar2)
        IS
     SELECT 'Y'
       --FROM  jtf_rs_all_resources_vl
       FROM  jtf_task_resources_vl
      where   resource_id = l_resource_id
        and   resource_type = l_resource_type
        and   nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);

    l_value varchar2(100);

    l_count number := 0;
    l_temp_table  JTF_ASSIGN_PUB.AssignResources_tbl_type;
  BEGIN

    SAVEPOINT get_assign_lead_resources;

    -- Started Assignment Manager API for SALES LEADS


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;



    /* Getting the Auto Select Profile value defined for the Assignment Manager */

    --l_auto_select_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_AUTO_SELECT' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_auto_select_profile := FND_PROFILE.VALUE ( 'ACTIVATE_AUTO_SELECT' ); -- Added by SBARAT on 12/10/2004, Bug-3830061



    /* Assigning the DEFAULT value to the Auto Select Parameter */


    IF (p_auto_select_flag IS NULL) THEN
      l_auto_select_flag  := l_auto_select_profile;
                             -- PROFILE VALUE is the default value
    ELSE
      l_auto_select_flag  := p_auto_select_flag;
    END IF;




    /* Defaulting the Calendar variable values to IN parameters,
       if the IN paramaters have values given */


    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration  := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;




    /* Actual Flow of Assignment Manager */


    IF (p_territory_flag = 'Y') THEN

      -- change the API Name temporarily so that in case of unexpected error
      -- it is properly caught
      l_api_name := l_api_name||'-JTF_TERR_SALES_PUB';

      JTF_TERR_SALES_PUB.Get_WinningTerrMembers
        (
          p_api_version_number  => l_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_TerrLead_Rec        => p_lead_rec,
          p_Resource_Type       => p_resource_type,
          p_Role                => p_role,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_winners_rec         => l_assign_resources_bulk_rec
        );

        -- set back the API name to original name
        l_api_name := l_api_name_1;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
        -- Unexpected Execution Error from call to Territory Manager
        fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
        fnd_msg_pub.add;
        IF (x_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;


      IF l_assign_resources_bulk_rec.terr_id.COUNT > 0 THEN

        l_current_record := l_assign_resources_bulk_rec.terr_id.FIRST;



        WHILE l_current_record <= l_assign_resources_bulk_rec.terr_id.LAST
        LOOP
            -- removed the calendar check here. calling the procedure for calendar check in the next step
            -- calendar check removed 29th September 2003

             open check_date_cur(l_assign_resources_bulk_rec.resource_id(l_current_record),
                              l_assign_resources_bulk_rec.resource_type(l_current_record));
             fetch check_date_cur into l_value;
             if (check_date_cur%found)
             then

               l_count := l_count + 1;
               x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                     l_assign_resources_bulk_rec.terr_rsc_id(l_current_record);
               x_assign_resources_tbl(l_count).resource_id           :=
                                     l_assign_resources_bulk_rec.resource_id(l_current_record);
               x_assign_resources_tbl(l_count).resource_type         :=
                                     l_assign_resources_bulk_rec.resource_type(l_current_record);
               x_assign_resources_tbl(l_count).role                  :=
                                     l_assign_resources_bulk_rec.role(l_current_record);

               x_assign_resources_tbl(l_count).start_date            := NULL;
--                                   l_assign_resources_bulk_rec.start_date(l_current_record);
               x_assign_resources_tbl(l_count).end_date              := NULL;
--                                   l_assign_resources_bulk_rec.end_date(l_current_record);

               x_assign_resources_tbl(l_count).shift_construct_id    := NULL;

               x_assign_resources_tbl(l_count).terr_id               :=
                                     l_assign_resources_bulk_rec.terr_id(l_current_record);
               x_assign_resources_tbl(l_count).terr_rank             :=
                                     l_assign_resources_bulk_rec.absolute_rank(l_current_record);
               x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                     l_assign_resources_bulk_rec.primary_contact_flag(l_current_record);
               x_assign_resources_tbl(l_count).full_access_flag      :=
                                     l_assign_resources_bulk_rec.full_access_flag(l_current_record);
               x_assign_resources_tbl(l_count).group_id              :=
                                     l_assign_resources_bulk_rec.group_id(l_current_record);
               x_assign_resources_tbl(l_count).trans_object_id       :=
                                     l_assign_resources_bulk_rec.trans_object_id(l_current_record);
               x_assign_resources_tbl(l_count).primary_flag       :=
                                     l_assign_resources_bulk_rec.primary_contact_flag(l_current_record);
               x_assign_resources_tbl(l_count).resource_source       := 'TERR';

              END IF;
              close check_date_cur;
              l_current_record := l_current_record+1;
          --l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
        END LOOP;


      -- added calendar call out
      -- this has been done as now the calendar check is done in a seperate procedure GET_AVAILABLE_RESOURCE
      -- changed on 29th September 2003
      IF (p_calendar_flag = 'Y') THEN
             -- change the API Name temporarily so that in case of unexpected error
             -- it is properly caught
              l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
              l_return_status_1 := x_return_status ;
              -- call the api to check resource availability
              get_available_resources
              (
                p_init_msg_list                 =>  'F',
                p_calendar_flag                 =>  p_calendar_flag,
                p_effort_duration               =>  l_effort_duration,
                p_effort_uom                    =>  l_effort_uom,
                p_planned_start_date            =>  l_planned_start_date,
                p_planned_end_date              =>  l_planned_end_date,
                p_continuous_task               =>  jtf_assign_pub.g_continuous_work,
                x_return_status                 =>  x_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data,
                x_assign_resources_tbl          =>  x_assign_resources_tbl);

              -- set back the API name to original name
               l_api_name := l_api_name_1;

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
                 fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_LEAD_RESOURCES');
                 fnd_msg_pub.add;
                 IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
                 ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF; -- end of x_return_status check
        end if; -- if p_calendar_flag = Y

        IF ( p_calendar_flag = 'Y' AND
             x_assign_resources_tbl.count = 0 ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
          fnd_msg_pub.add;
--          RAISE fnd_api.g_exc_error;
        END IF;


       -- If auto_select is Y then ensure correct number of resources are returned
       IF(l_auto_select_flag = 'Y')
        THEN
          l_temp_table.delete;
          l_temp_table := x_assign_resources_tbl;
          x_assign_resources_tbl.delete;
          l_count := 0;
          l_current_record := l_temp_table.FIRST;
          l_total_records := p_no_of_resources;

          WHILE l_current_record <= l_temp_table.LAST
          LOOP
             If(l_count < l_total_records)
             THEN
                 x_assign_resources_tbl(l_count) := l_temp_table(l_current_record);
                 l_count := l_count + 1;
             end if; -- end of count check
             l_current_record := l_temp_table.NEXT(l_current_record);
          END LOOP; -- end of courrent record check

         END IF; -- end of auto select flag

      ELSE   -- No resources returned from the Territory API
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE  -- Territory Flag is NO
      fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
      fnd_msg_pub.add;
--      RAISE fnd_api.g_exc_error;
    END IF;

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

      -- raise workfow event
      -- workflow test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_lead_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_LEAD_REC              =>  Null,
                     P_LEAD_BULK_REC	   =>  p_lead_rec,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_sr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_LEAD_RESOURCES');
            fnd_msg_pub.add;

        ELSE
		x_assign_resources_tbl.delete;
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;


      Exception
            When OTHERS Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    -- To Plugin the Workflow enabling the user
    -- to further filter the resources

    /* Getting the Workflow Profile value defined for the Assignment Manager */

    --l_workflow_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_WORKFLOW_NAME' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_workflow_profile := FND_PROFILE.VALUE ( 'ACTIVATE_WORKFLOW_NAME' ); -- Added by SBARAT on 12/10/2004, Bug-3830061

    SELECT jtf_calendars_s.NEXTVAL INTO l_workflow_key
    FROM   dual;

    IF (JTF_USR_HKS.ok_to_execute
          (
            'JTF_ASSIGN_PUB',
            'GET_ASSIGN_LEAD_RESOURCES',
            'W',
            'W'
          )
       ) THEN

      IF (JTF_ASSIGN_CUHK.ok_to_launch_workflow
            (
              p_api_version     => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data
            )
         ) THEN

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

        JTF_USR_HKS.WrkFlowLaunch
          (
            'JTF_ASSIGN_WF',
            l_workflow_profile,
            'ASSIGN WF - '|| TO_CHAR(l_workflow_key),
            l_bind_data_id,
            l_return_code
          );

        JTF_USR_HKS.purge_bind_data
          (
            l_bind_data_id,
            'W'
          );

        IF (l_return_code = fnd_api.g_ret_sts_error) THEN
          -- Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_return_code = fnd_api.g_ret_sts_unexp_error) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;  -- End of JTF_ASSIGN_CUHK

    END IF;    -- End of JTF_USR_HKS




    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_LEAD_RESOURCES;



-- *******************************************************************************

-- PLEASE DO NOT USE THIS API
-- BEING SUPPORTED ONLY FOR BACKWARD COMPATIBILITY

--      API name        : GET_ASSIGN_LEAD_RESOURCES (For SINGLE Record)
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is
--                        LEADS.
--     This parameter contains the values of the Qualifiers
--     defined for the Sales Leads.
--     p_lead_rec                               JTF_ASSIGN_PUB.
--                                              JTF_Lead_rec_type
--                                              REQUIRED

--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--      Version         : Current version        1.0
--                        Initial version        1.0
--
--      Notes           :
--

-- End of comments

-- *********************************************************************************

--      Procedure definition with the parameters when the
--      Source Document is SALES LEADS

  PROCEDURE GET_ASSIGN_LEAD_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2 ,
        p_calendar_flag                       IN  VARCHAR2 ,
        p_lead_rec                            IN  JTF_ASSIGN_PUB.JTF_Lead_rec_type,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_LEAD_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_LEAD_RESOURCES';
    l_api_version                         NUMBER        := 1.0;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);
    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(30)  := 'HR';

    l_current_record                      INTEGER;
    l_total_records                       INTEGER;

    l_auto_select_profile                 VARCHAR2(03);
    l_auto_select_flag                    VARCHAR2(03);
    l_workflow_profile                    VARCHAR2(60);

    l_return_code                         VARCHAR2(60);
    l_bind_data_id                        NUMBER;
    l_workflow_key                        NUMBER;

    l_assign_resources_tbl                JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_lead_rec                            JTF_TERRITORY_PUB.JTF_Lead_rec_type;

    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    l_wf_return_status                    VARCHAR2(60);
    l_wf_msg_count                        NUMBER;
    l_wf_msg_data                         VARCHAR2(2000);

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/


  BEGIN

    SAVEPOINT get_assign_lead_resources;

    -- Started Assignment Manager API for SALES LEADS


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;


    /* Getting the Auto Select Profile value defined for the Assignment Manager */

    --l_auto_select_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_AUTO_SELECT' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_auto_select_profile := FND_PROFILE.VALUE ( 'ACTIVATE_AUTO_SELECT' ); -- Added by SBARAT on 12/10/2004, Bug-3830061



    /* Assigning the DEFAULT value to the Auto Select Parameter */


    IF (p_auto_select_flag IS NULL) THEN
      l_auto_select_flag  := l_auto_select_profile;
                             -- PROFILE VALUE is the default value
    ELSE
      l_auto_select_flag  := p_auto_select_flag;
    END IF;


    /* Defaulting the Calendar variable values to IN parameters,
       if the IN paramaters have values given */


    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration  := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;



    /* Assigning values to the Lead Record Type */


    l_lead_rec.SALES_LEAD_ID                 :=  p_lead_rec.SALES_LEAD_ID;
    l_lead_rec.SALES_LEAD_LINE_ID            :=  p_lead_rec.SALES_LEAD_LINE_ID;
    l_lead_rec.CITY                          :=  p_lead_rec.CITY;
    l_lead_rec.POSTAL_CODE                   :=  p_lead_rec.POSTAL_CODE;
    l_lead_rec.STATE                         :=  p_lead_rec.STATE;
    l_lead_rec.PROVINCE                      :=  p_lead_rec.PROVINCE;
    l_lead_rec.COUNTY                        :=  p_lead_rec.COUNTY;
    l_lead_rec.COUNTRY                       :=  p_lead_rec.COUNTRY;
    l_lead_rec.INTEREST_TYPE_ID              :=  p_lead_rec.INTEREST_TYPE_ID;
    l_lead_rec.PRIMARY_INTEREST_ID           :=  p_lead_rec.PRIMARY_INTEREST_ID;
    l_lead_rec.SECONDARY_INTEREST_ID         :=  p_lead_rec.SECONDARY_INTEREST_ID;
    l_lead_rec.CONTACT_INTEREST_TYPE_ID      :=  p_lead_rec.CONTACT_INTEREST_TYPE_ID;
    l_lead_rec.CONTACT_PRIMARY_INTEREST_ID   :=  p_lead_rec.CONTACT_PRIMARY_INTEREST_ID;
    l_lead_rec.CONTACT_SECONDARY_INTEREST_ID :=  p_lead_rec.CONTACT_SECONDARY_INTEREST_ID;
    l_lead_rec.PARTY_SITE_ID                 :=  p_lead_rec.PARTY_SITE_ID;
    l_lead_rec.AREA_CODE                     :=  p_lead_rec.AREA_CODE;
    l_lead_rec.PARTY_ID                      :=  p_lead_rec.PARTY_ID;
    l_lead_rec.COMP_NAME_RANGE               :=  p_lead_rec.COMP_NAME_RANGE;
    l_lead_rec.PARTNER_ID                    :=  p_lead_rec.PARTNER_ID;
    l_lead_rec.NUM_OF_EMPLOYEES              :=  p_lead_rec.NUM_OF_EMPLOYEES;
    l_lead_rec.CATEGORY_CODE                 :=  p_lead_rec.CATEGORY_CODE;
    l_lead_rec.PARTY_RELATIONSHIP_ID         :=  p_lead_rec.PARTY_RELATIONSHIP_ID;
    l_lead_rec.SIC_CODE                      :=  p_lead_rec.SIC_CODE;
    l_lead_rec.BUDGET_AMOUNT                 :=  p_lead_rec.BUDGET_AMOUNT;
    l_lead_rec.CURRENCY_CODE                 :=  p_lead_rec.CURRENCY_CODE;
    l_lead_rec.PRICING_DATE                  :=  p_lead_rec.PRICING_DATE;
    l_lead_rec.SOURCE_PROMOTION_ID           :=  p_lead_rec.SOURCE_PROMOTION_ID;
    l_lead_rec.INVENTORY_ITEM_ID             :=  p_lead_rec.INVENTORY_ITEM_ID;
    l_lead_rec.LEAD_INTEREST_TYPE_ID         :=  p_lead_rec.LEAD_INTEREST_TYPE_ID;
    l_lead_rec.LEAD_PRIMARY_INTEREST_ID      :=  p_lead_rec.LEAD_PRIMARY_INTEREST_ID;
    l_lead_rec.LEAD_SECONDARY_INTEREST_ID    :=  p_lead_rec.LEAD_SECONDARY_INTEREST_ID;
    l_lead_rec.PURCHASE_AMOUNT               :=  p_lead_rec.PURCHASE_AMOUNT;
    l_lead_rec.ATTRIBUTE1                    :=  p_lead_rec.ATTRIBUTE1;
    l_lead_rec.ATTRIBUTE2                    :=  p_lead_rec.ATTRIBUTE2;
    l_lead_rec.ATTRIBUTE3                    :=  p_lead_rec.ATTRIBUTE3;
    l_lead_rec.ATTRIBUTE4                    :=  p_lead_rec.ATTRIBUTE4;
    l_lead_rec.ATTRIBUTE5                    :=  p_lead_rec.ATTRIBUTE5;
    l_lead_rec.ATTRIBUTE6                    :=  p_lead_rec.ATTRIBUTE6;
    l_lead_rec.ATTRIBUTE7                    :=  p_lead_rec.ATTRIBUTE7;
    l_lead_rec.ATTRIBUTE8                    :=  p_lead_rec.ATTRIBUTE8;
    l_lead_rec.ATTRIBUTE9                    :=  p_lead_rec.ATTRIBUTE9;
    l_lead_rec.ATTRIBUTE10                   :=  p_lead_rec.ATTRIBUTE10;
    l_lead_rec.ATTRIBUTE11                   :=  p_lead_rec.ATTRIBUTE11;
    l_lead_rec.ATTRIBUTE12                   :=  p_lead_rec.ATTRIBUTE12;
    l_lead_rec.ATTRIBUTE13                   :=  p_lead_rec.ATTRIBUTE13;
    l_lead_rec.ATTRIBUTE14                   :=  p_lead_rec.ATTRIBUTE14;
    l_lead_rec.ATTRIBUTE15                   :=  p_lead_rec.ATTRIBUTE15;



    /* Actual Flow of Assignment Manager */


    IF (p_territory_flag = 'Y') THEN

      -- change the API Name temporarily so that in case of unexpected error
      -- it is properly caught
      l_api_name := l_api_name||'-JTF_TERR_SALES_PUB';

      JTF_TERR_SALES_PUB.Get_WinningTerrMembers
        (
          p_api_version_number  => l_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_TerrLead_Rec        => l_lead_rec,
          p_Resource_Type       => p_resource_type,
          p_Role                => p_role,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_TerrResource_tbl    => l_assign_resources_tbl
        );

        -- set back the API name to original name
        l_api_name := l_api_name_1;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
        -- Unexpected Execution Error from call to Territory Manager
        fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
        fnd_msg_pub.add;
        IF (x_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      -- added 2 april 2003 by sudarsana to conver RS_SUPPLIER TO RS_SUPPLIER_CONTACT

          IF(l_assign_resources_tbl.COUNT > 0)
          THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;

      IF l_assign_resources_tbl.COUNT > 0 THEN

        l_current_record := l_assign_resources_tbl.FIRST;


        IF (l_auto_select_flag = 'Y') THEN
          l_total_records := p_no_of_resources;
        ELSE
          l_total_records := l_assign_resources_tbl.LAST;
        END IF;


        WHILE l_current_record <= l_assign_resources_tbl.LAST
        LOOP
          -- Check the calendar for resource availability
            -- Call Calendar API
            -- IF the resource is available then accept the values and
            -- check for the WORKFLOW profile option

          IF (p_calendar_flag = 'Y') THEN

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_CALENDAR_PUB';
          l_return_status_1 := x_return_status ;

            JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT
              (
                P_API_VERSION        => l_api_version,
                P_INIT_MSG_LIST      => p_init_msg_list,
                P_RESOURCE_ID        => l_assign_resources_tbl(l_current_record).resource_id,
                P_RESOURCE_TYPE      => l_assign_resources_tbl(l_current_record).resource_type,
                P_START_DATE_TIME    => l_planned_start_date,
                P_END_DATE_TIME      => l_planned_end_date,
                P_DURATION           => l_effort_duration,
                X_RETURN_STATUS      => x_return_status,
                X_MSG_COUNT          => x_msg_count,
                X_MSG_DATA           => x_msg_data,
                X_SLOT_START_DATE    => l_x_planned_start_date,
                X_SLOT_END_DATE      => l_x_planned_end_date,
                X_SHIFT_CONSTRUCT_ID => l_x_shift_construct_id,
                X_AVAILABILITY_TYPE  => l_x_availability_type
              );

            -- set back the API name to original name
            l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Calendar
              fnd_message.set_name('JTF', 'JTF_AM_ERROR_CAL_API');
              fnd_msg_pub.add;
              IF (x_return_status = fnd_api.g_ret_sts_error) THEN
			  	 --  12/22/05 ** MPADHIAR ** Manas padhiary **
				 --  Removed Comment to Show error message Bug # 2919389
                RAISE fnd_api.g_exc_error;
              ELSE
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF;


            IF (l_x_shift_construct_id IS NOT NULL) THEN

              -- The following IF statement is to implement Auto Select Feature
              IF (l_current_record <= l_total_records) THEN

                x_assign_resources_tbl(l_current_record).terr_rsc_id           :=
                                       l_assign_resources_tbl(l_current_record).terr_rsc_id;
                x_assign_resources_tbl(l_current_record).resource_id           :=
                                       l_assign_resources_tbl(l_current_record).resource_id;
                x_assign_resources_tbl(l_current_record).resource_type         :=
                                       l_assign_resources_tbl(l_current_record).resource_type;
                x_assign_resources_tbl(l_current_record).role                  :=
                                       l_assign_resources_tbl(l_current_record).role;

                IF (l_travel_uom like 'HR%') THEN
                  x_assign_resources_tbl(l_current_record).start_date      :=
                                         l_x_planned_start_date + l_travel_time/24;
                  x_assign_resources_tbl(l_current_record).end_date        :=
                                         l_x_planned_end_date   + l_travel_time/24;
                ELSIF (l_travel_uom like 'MI%') THEN
                  x_assign_resources_tbl(l_current_record).start_date      :=
                                         l_x_planned_start_date + l_travel_time/1440;
                  x_assign_resources_tbl(l_current_record).end_date        :=
                                         l_x_planned_end_date   + l_travel_time/1440;
                ELSIF (l_travel_uom like 'S%') THEN
                  x_assign_resources_tbl(l_current_record).start_date      :=
                                         l_x_planned_start_date + l_travel_time/86400;
                  x_assign_resources_tbl(l_current_record).end_date        :=
                                         l_x_planned_end_date   + l_travel_time/86400;
                END IF;

                x_assign_resources_tbl(l_current_record).shift_construct_id    := l_x_shift_construct_id;
                x_assign_resources_tbl(l_current_record).terr_id               :=
                                       l_assign_resources_tbl(l_current_record).terr_id;
                x_assign_resources_tbl(l_current_record).terr_name             :=
                                       l_assign_resources_tbl(l_current_record).terr_name;
                x_assign_resources_tbl(l_current_record).primary_contact_flag  :=
                                       l_assign_resources_tbl(l_current_record).primary_contact_flag;
                x_assign_resources_tbl(l_current_record).full_access_flag      :=
                                       l_assign_resources_tbl(l_current_record).full_access_flag;
                x_assign_resources_tbl(l_current_record).group_id              :=
                                       l_assign_resources_tbl(l_current_record).group_id;
                x_assign_resources_tbl(l_current_record).resource_source       := 'TERR';

              END IF;
            END IF;

          ELSE    -- Calendar Flag is NO

            -- The following IF statement is to implement Auto Select Feature
            IF (l_current_record <= l_total_records) THEN
              x_assign_resources_tbl(l_current_record).terr_rsc_id           :=
                                     l_assign_resources_tbl(l_current_record).terr_rsc_id;
              x_assign_resources_tbl(l_current_record).resource_id           :=
                                     l_assign_resources_tbl(l_current_record).resource_id;
              x_assign_resources_tbl(l_current_record).resource_type         :=
                                     l_assign_resources_tbl(l_current_record).resource_type;
              x_assign_resources_tbl(l_current_record).role                  :=
                                     l_assign_resources_tbl(l_current_record).role;
              x_assign_resources_tbl(l_current_record).start_date            :=
                                     l_assign_resources_tbl(l_current_record).start_date;
              x_assign_resources_tbl(l_current_record).end_date              :=
                                     l_assign_resources_tbl(l_current_record).end_date;
              x_assign_resources_tbl(l_current_record).shift_construct_id    := NULL;
              x_assign_resources_tbl(l_current_record).terr_id               :=
                                     l_assign_resources_tbl(l_current_record).terr_id;
              x_assign_resources_tbl(l_current_record).terr_name             :=
                                     l_assign_resources_tbl(l_current_record).terr_name;
              x_assign_resources_tbl(l_current_record).primary_contact_flag  :=
                                      l_assign_resources_tbl(l_current_record).primary_contact_flag;
              x_assign_resources_tbl(l_current_record).full_access_flag      :=
                                     l_assign_resources_tbl(l_current_record).full_access_flag;
              x_assign_resources_tbl(l_current_record).group_id              :=
                                     l_assign_resources_tbl(l_current_record).group_id;
            END IF;

          END IF; -- End of Calendar Flag

          l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
        END LOOP;


        IF ( p_calendar_flag = 'Y' AND
             x_assign_resources_tbl.count = 0 ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
          fnd_msg_pub.add;
--          RAISE fnd_api.g_exc_error;
        END IF;

      ELSE   -- No resources returned from the Territory API
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE  -- Territory Flag is NO
      fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
      fnd_msg_pub.add;
--      RAISE fnd_api.g_exc_error;
    END IF;

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

      -- raise workfow event
      -- workflow test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_lead_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_LEAD_REC              =>  p_lead_rec,
                     P_LEAD_BULK_REC	   =>  Null,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_sr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_LEAD_RESOURCES');
            fnd_msg_pub.add;

        ELSE
		x_assign_resources_tbl.delete;
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;


      Exception
            When OTHERS Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    -- To Plugin the Workflow enabling the user
    -- to further filter the resources

    /* Getting the Workflow Profile value defined for the Assignment Manager */

    --l_workflow_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_WORKFLOW_NAME' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_workflow_profile := FND_PROFILE.VALUE ( 'ACTIVATE_WORKFLOW_NAME' ); -- Added by SBARAT on 12/10/2004, Bug-3830061

    SELECT jtf_calendars_s.NEXTVAL INTO l_workflow_key
    FROM   dual;

    IF (JTF_USR_HKS.ok_to_execute
          (
            'JTF_ASSIGN_PUB',
            'GET_ASSIGN_LEAD_RESOURCES',
            'W',
            'W'
          )
       ) THEN

      IF (JTF_ASSIGN_CUHK.ok_to_launch_workflow
            (
              p_api_version     => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data
            )
         ) THEN

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

        JTF_USR_HKS.WrkFlowLaunch
          (
            'JTF_ASSIGN_WF',
            l_workflow_profile,
            'ASSIGN WF - '|| TO_CHAR(l_workflow_key),
            l_bind_data_id,
            l_return_code
          );

        JTF_USR_HKS.purge_bind_data
          (
            l_bind_data_id,
            'W'
          );


        IF (l_return_code = fnd_api.g_ret_sts_error) THEN
          -- Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_return_code = fnd_api.g_ret_sts_unexp_error) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;  -- End of JTF_ASSIGN_CUHK

    END IF;    -- End of JTF_USR_HKS



    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_LEAD_RESOURCES;








-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_ACCOUNT_RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is
--                        ACCOUNTS.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT JTF_ASSIGN_PUB.AM_FALSE
--                        p_commit              IN      VARCHAR2 optional
--                                              DEFAULT JTF_ASSIGN_PUB.AM_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,
--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N


--     This parameter contains the values of the Qualifiers
--     defined for the Accounts.
--     p_account_rec                            JTF_ASSIGN_PUB.
--                                              JTF_Account_rec_type
--                                              REQUIRED

--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--      Version         : Current version        1.0
--                        Initial version        1.0
--
--      Notes           :
--

-- End of comments

-- *********************************************************************************



--      Procedure definition with the parameters when the
--      Source Document is ACCOUNTS


  PROCEDURE GET_ASSIGN_ACCOUNT_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2 ,
        p_account_rec                         IN  JTF_ASSIGN_PUB.JTF_Account_rec_type,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_ACCOUNT_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_ACCOUNT_RESOURCES';
    l_api_version                         NUMBER        := 1.0;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);
    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(30)  := 'HR';

    l_current_record                      INTEGER;
    l_total_records                       INTEGER;

    l_auto_select_profile                 VARCHAR2(03);
    l_auto_select_flag                    VARCHAR2(03);
    l_workflow_profile                    VARCHAR2(60);

    l_return_code                         VARCHAR2(60);
    l_bind_data_id                        NUMBER;
    l_workflow_key                        NUMBER;

    l_assign_resources_tbl                JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_account_rec                         JTF_TERRITORY_PUB.JTF_Account_rec_type;

    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    l_wf_return_status                    VARCHAR2(60);
    l_wf_msg_count                        NUMBER;
    l_wf_msg_data                         VARCHAR2(2000);

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

     --Bug# 4455803 MOAC.
     CURSOR check_date_cur(l_resource_id in number,
                          l_resource_type in varchar2)
        IS
     SELECT 'Y'
       --FROM  jtf_rs_all_resources_vl
       FROM  jtf_task_resources_vl
      where   resource_id = l_resource_id
        and   resource_type = l_resource_type
        and   nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);

    l_value varchar2(100);

    l_count        number := 0;
    l_temp_table   JTF_ASSIGN_PUB.AssignResources_tbl_type;

  BEGIN

    SAVEPOINT get_assign_account_resources;

    -- Started Assignment Manager API for ACCOUNTS


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;



    /* Getting the Auto Select Profile value defined for the Assignment Manager */

    --l_auto_select_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_AUTO_SELECT' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_auto_select_profile := FND_PROFILE.VALUE ( 'ACTIVATE_AUTO_SELECT' ); -- Added by SBARAT on 12/10/2004, Bug-3830061



    /* Assigning the DEFAULT value to the Auto Select Parameter */


    IF (p_auto_select_flag IS NULL) THEN
      l_auto_select_flag  := l_auto_select_profile;
                             -- PROFILE VALUE is the default value
    ELSE
      l_auto_select_flag  := p_auto_select_flag;
    END IF;




    /* Defaulting the Calendar variable values to IN parameters,
       if the IN paramaters have values given */


    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration  := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;


    /* Assigning values to the Account Record Type */


    l_account_rec.CITY                          :=  p_account_rec.CITY;
    l_account_rec.POSTAL_CODE                   :=  p_account_rec.POSTAL_CODE;
    l_account_rec.STATE                         :=  p_account_rec.STATE;
    l_account_rec.PROVINCE                      :=  p_account_rec.PROVINCE;
    l_account_rec.COUNTY                        :=  p_account_rec.COUNTY;
    l_account_rec.COUNTRY                       :=  p_account_rec.COUNTRY;
    l_account_rec.INTEREST_TYPE_ID              :=  p_account_rec.INTEREST_TYPE_ID;
    l_account_rec.PRIMARY_INTEREST_ID           :=  p_account_rec.PRIMARY_INTEREST_ID;
    l_account_rec.SECONDARY_INTEREST_ID         :=  p_account_rec.SECONDARY_INTEREST_ID;
    l_account_rec.CONTACT_INTEREST_TYPE_ID      :=  p_account_rec.CONTACT_INTEREST_TYPE_ID;
    l_account_rec.CONTACT_PRIMARY_INTEREST_ID   :=  p_account_rec.CONTACT_PRIMARY_INTEREST_ID;
    l_account_rec.CONTACT_SECONDARY_INTEREST_ID :=  p_account_rec.CONTACT_SECONDARY_INTEREST_ID;
    l_account_rec.PARTY_SITE_ID                 :=  p_account_rec.PARTY_SITE_ID;
    l_account_rec.AREA_CODE                     :=  p_account_rec.AREA_CODE;
    l_account_rec.PARTY_ID                      :=  p_account_rec.PARTY_ID;
    l_account_rec.COMP_NAME_RANGE               :=  p_account_rec.COMP_NAME_RANGE;
    l_account_rec.PARTNER_ID                    :=  p_account_rec.PARTNER_ID;
    l_account_rec.NUM_OF_EMPLOYEES              :=  p_account_rec.NUM_OF_EMPLOYEES;
    l_account_rec.CATEGORY_CODE                 :=  p_account_rec.CATEGORY_CODE;
    l_account_rec.PARTY_RELATIONSHIP_ID         :=  p_account_rec.PARTY_RELATIONSHIP_ID;
    l_account_rec.SIC_CODE                      :=  p_account_rec.SIC_CODE;
    l_account_rec.ATTRIBUTE1                    :=  p_account_rec.ATTRIBUTE1;
    l_account_rec.ATTRIBUTE2                    :=  p_account_rec.ATTRIBUTE2;
    l_account_rec.ATTRIBUTE3                    :=  p_account_rec.ATTRIBUTE3;
    l_account_rec.ATTRIBUTE4                    :=  p_account_rec.ATTRIBUTE4;
    l_account_rec.ATTRIBUTE5                    :=  p_account_rec.ATTRIBUTE5;
    l_account_rec.ATTRIBUTE6                    :=  p_account_rec.ATTRIBUTE6;
    l_account_rec.ATTRIBUTE7                    :=  p_account_rec.ATTRIBUTE7;
    l_account_rec.ATTRIBUTE8                    :=  p_account_rec.ATTRIBUTE8;
    l_account_rec.ATTRIBUTE9                    :=  p_account_rec.ATTRIBUTE9;
    l_account_rec.ATTRIBUTE10                   :=  p_account_rec.ATTRIBUTE10;
    l_account_rec.ATTRIBUTE11                   :=  p_account_rec.ATTRIBUTE11;
    l_account_rec.ATTRIBUTE12                   :=  p_account_rec.ATTRIBUTE12;
    l_account_rec.ATTRIBUTE13                   :=  p_account_rec.ATTRIBUTE13;
    l_account_rec.ATTRIBUTE14                   :=  p_account_rec.ATTRIBUTE14;
    l_account_rec.ATTRIBUTE15                   :=  p_account_rec.ATTRIBUTE15;
    l_account_rec.ORG_ID                        :=  p_account_rec.ORG_ID;



    /* Actual Flow of Assignment Manager */


    IF (p_territory_flag = 'Y') THEN

     -- change the API Name temporarily so that in case of unexpected error
     -- it is properly caught
     l_api_name := l_api_name||'-JTF_TERR_SALES_PUB';

      JTF_TERR_SALES_PUB.Get_WinningTerrMembers
        (
          p_api_version_number  => l_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_TerrAccount_Rec     => l_account_rec,
          p_Resource_Type       => p_resource_type,
          p_Role                => p_role,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_TerrResource_tbl    => l_assign_resources_tbl
        );

      -- set back the API name to original name
      l_api_name := l_api_name_1;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
        -- Unexpected Execution Error from call to Territory Manager
        fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
        fnd_msg_pub.add;
        IF (x_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;


       -- added 2 april 2003 by sudarsana to conver RS_SUPPLIER TO RS_SUPPLIER_CONTACT

      IF(l_assign_resources_tbl.COUNT > 0)
      THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
       END IF;

      IF l_assign_resources_tbl.COUNT > 0 THEN

        l_current_record := l_assign_resources_tbl.FIRST;


        IF (l_auto_select_flag = 'Y') THEN
          l_total_records := p_no_of_resources;
        ELSE
          l_total_records := l_assign_resources_tbl.LAST;
        END IF;

        -- removed the calendar check here. calling the procedure for calendar check in the next step
        -- calendar check removed 29th September 2003

        WHILE l_current_record <= l_assign_resources_tbl.LAST
        LOOP
          -- Check the calendar for resource availability
            -- Call Calendar API
            -- IF the resource is available then accept the values and
            -- check for the WORKFLOW profile option
            open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
            fetch check_date_cur into l_value;
            if (check_date_cur%found)
            then

               l_count := l_count + 1;
               x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                     l_assign_resources_tbl(l_current_record).terr_rsc_id;
               x_assign_resources_tbl(l_count).resource_id           :=
                                      l_assign_resources_tbl(l_current_record).resource_id;
               x_assign_resources_tbl(l_count).resource_type         :=
                                     l_assign_resources_tbl(l_current_record).resource_type;
               x_assign_resources_tbl(l_count).role                  :=
                                     l_assign_resources_tbl(l_current_record).role;
               x_assign_resources_tbl(l_count).start_date            :=
                                     l_assign_resources_tbl(l_current_record).start_date;
               x_assign_resources_tbl(l_count).end_date              :=
                                     l_assign_resources_tbl(l_current_record).end_date;
               x_assign_resources_tbl(l_count).shift_construct_id    := NULL;
               x_assign_resources_tbl(l_count).terr_id               :=
                                     l_assign_resources_tbl(l_current_record).terr_id;
               x_assign_resources_tbl(l_count).terr_name             :=
                                     l_assign_resources_tbl(l_current_record).terr_name;
               x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                      l_assign_resources_tbl(l_current_record).primary_contact_flag;
               x_assign_resources_tbl(l_count).full_access_flag      :=
                                     l_assign_resources_tbl(l_current_record).full_access_flag;
               x_assign_resources_tbl(l_count).group_id              :=
                                     l_assign_resources_tbl(l_current_record).group_id;
               x_assign_resources_tbl(l_count).primary_flag              :=
                                     l_assign_resources_tbl(l_current_record).primary_contact_flag;
               x_assign_resources_tbl(l_count).resource_source       := 'TERR';

              end if;
              close check_date_cur;

             l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
        END LOOP;

       -- added calendar call out
       -- this has been done as now the calendar check is done in a seperate procedure GET_AVAILABLE_RESOURCE
       -- changed on 29th September 2003
        IF (p_calendar_flag = 'Y') THEN
             -- change the API Name temporarily so that in case of unexpected error
             -- it is properly caught
              l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
              l_return_status_1 := x_return_status ;
              -- call the api to check resource availability
              get_available_resources
              (
                p_init_msg_list                 =>  'F',
                p_calendar_flag                 =>  p_calendar_flag,
                p_effort_duration               =>  l_effort_duration,
                p_effort_uom                    =>  l_effort_uom,
                p_planned_start_date            =>  l_planned_start_date,
                p_planned_end_date              =>  l_planned_end_date,
                p_continuous_task               =>  jtf_assign_pub.g_continuous_work,
                x_return_status                 =>  x_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data,
                x_assign_resources_tbl          =>  x_assign_resources_tbl);

              -- set back the API name to original name
               l_api_name := l_api_name_1;

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
                 fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_ACCOUNT_RESOURCES');
                 fnd_msg_pub.add;
                 IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
                 ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF; -- end of x_return_status check
            end if; -- if p_calendar_flag = Y

        IF ( p_calendar_flag = 'Y' AND
             x_assign_resources_tbl.count = 0 ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
          fnd_msg_pub.add;
--          RAISE fnd_api.g_exc_error;
        END IF;

       -- to implement auto selection
       IF(l_auto_select_flag = 'Y')
        THEN
          l_temp_table.delete;
          l_temp_table := x_assign_resources_tbl;
          x_assign_resources_tbl.delete;
          l_count := 0;
          l_current_record := l_temp_table.FIRST;
          l_total_records := p_no_of_resources;

          WHILE l_current_record <= l_temp_table.LAST
          LOOP
             If(l_count < l_total_records)
             THEN
                 x_assign_resources_tbl(l_count) := l_temp_table(l_current_record);
                 l_count := l_count + 1;
             end if; -- end of count check
             l_current_record := l_temp_table.NEXT(l_current_record);
          END LOOP; -- end of courrent record check

         END IF; -- end of auto select flag
      ELSE   -- No resources returned from the Territory API
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE  -- Territory Flag is NO
      fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
      fnd_msg_pub.add;
--      RAISE fnd_api.g_exc_error;
    END IF;

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

      -- raise workfow event
      -- workflow test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_acc_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_ACCOUNT_REC           =>  p_account_rec,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_sr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_ACCOUNT_RESOURCES');
            fnd_msg_pub.add;

        ELSE
		x_assign_resources_tbl.delete;
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;


      Exception
            When OTHERS Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/


    -- To Plugin the Workflow enabling the user
    -- to further filter the resources

    /* Getting the Workflow Profile value defined for the Assignment Manager */

    --l_workflow_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_WORKFLOW_NAME' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_workflow_profile := FND_PROFILE.VALUE ( 'ACTIVATE_WORKFLOW_NAME' ); -- Added by SBARAT on 12/10/2004, Bug-3830061

    SELECT jtf_calendars_s.NEXTVAL INTO l_workflow_key
    FROM   dual;

    IF (JTF_USR_HKS.ok_to_execute
          (
            'JTF_ASSIGN_PUB',
            'GET_ASSIGN_ACCOUNT_RESOURCES',
            'W',
            'W'
          )
       ) THEN

      IF (JTF_ASSIGN_CUHK.ok_to_launch_workflow
            (
              p_api_version     => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data
            )
         ) THEN

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

        l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

        JTF_USR_HKS.WrkFlowLaunch
          (
            'JTF_ASSIGN_WF',
            l_workflow_profile,
            'ASSIGN WF - '|| TO_CHAR(l_workflow_key),
            l_bind_data_id,
            l_return_code
          );

        JTF_USR_HKS.purge_bind_data
          (
            l_bind_data_id,
            'W'
          );

        IF (l_return_code = fnd_api.g_ret_sts_error) THEN
          -- Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_return_code = fnd_api.g_ret_sts_unexp_error) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;  -- End of JTF_ASSIGN_CUHK

    END IF;    -- End of JTF_USR_HKS




    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

  END GET_ASSIGN_ACCOUNT_RESOURCES;












-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_DEFECT_RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability. This is when the calling doc is
--                        DEFECT MANAGEMENT SYSTEM.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT = FND_API.G_FALSE
--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N


--     This parameter contains the Qualifier Values
--     of the Calling Document
--     p_defect_rec                             JTF_TERRITORY_PUB.
--                                              JTF_DEF_MGMT_rec_type


--     OUT             : x_return_status        OUT     VARCHAR2(1)
--                       x_msg_count            OUT     NUMBER
--                       x_msg_data             OUT     VARCHAR2(2000)
--                       x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                      AssignResources_tbl_type


--      Version        : Current version        1.0
--                       Initial version        1.0
--
--      Notes          :
--

-- End of comments
-- *********************************************************************************



--      Procedure definition with the parameters when the
--      Source Document is DEFECT MANAGEMENT SYSTEM

  PROCEDURE GET_ASSIGN_DEFECT_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2,
        p_resource_type                       IN  VARCHAR2,
        p_role                                IN  VARCHAR2,
        p_no_of_resources                     IN  NUMBER,
        p_auto_select_flag                    IN  VARCHAR2,
        p_effort_duration                     IN  NUMBER,
        p_effort_uom                          IN  VARCHAR2,
        p_start_date                          IN  DATE,
        p_end_date                            IN  DATE,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_defect_rec                          IN  JTF_TERRITORY_PUB.JTF_DEF_MGMT_rec_type,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    )
  IS
    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_DEFECT_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_DEFECT_RESOURCES';
    l_api_version                         NUMBER        := 1.0;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_travel_time                         NUMBER        := 0;
    l_travel_uom                          VARCHAR2(30)  := 'HR';

    l_current_record                      INTEGER;
    l_total_records                       INTEGER;

    l_assign_resources_tbl                JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
--  l_assign_resources_rec                JTF_TERRITORY_PUB.JTF_DEF_MGMT_rec_type;

    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

    l_count                               NUMBER := 1;



  BEGIN
    SAVEPOINT get_assign_defect_resources;

    -- Started Assignment Manager API for DEFECT MANAGEMENT SYSTEM



    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;



    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;




    /* Defaulting the variable values to IN parameters,
       if the IN paramaters have values given */


    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    ELSE
      l_planned_start_date := SYSDATE;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    ELSE
      l_planned_end_date := SYSDATE;
    END IF;




    /* Actual Flow of Assignment Manager */


    IF (p_territory_flag = 'Y') THEN

      -- change the API Name temporarily so that in case of unexpected error
      -- it is properly caught
      l_api_name := l_api_name||'-JTF_TERR_DEF_MGMT_PUB';

      JTF_TERR_DEF_MGMT_PUB.Get_WinningTerrMembers
        (
          p_api_version_number  => l_api_version,
          p_init_msg_list       => p_init_msg_list,
          p_TerrDefMgmt_Rec     => p_defect_rec,
          p_Resource_Type       => p_resource_type,
          p_Role                => p_role,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_TerrResource_tbl    => l_assign_resources_tbl
        );

        -- set back the API name to original name
        l_api_name := l_api_name_1;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
        -- Unexpected Execution Error from call to Territory Manager
        fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
        fnd_msg_pub.add;
        IF (x_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

    ELSE  -- Territory Flag is NO
      fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
      fnd_msg_pub.add;
--      RAISE fnd_api.g_exc_error;
    END IF;

     -- added 2 april 2003 by sudarsana to conver RS_SUPPLIER TO RS_SUPPLIER_CONTACT

      IF(l_assign_resources_tbl.COUNT > 0)
      THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE l_current_record <= l_assign_resources_tbl.LAST
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
      END IF;

    IF l_assign_resources_tbl.COUNT > 0 THEN


      x_assign_resources_tbl.delete;

      l_current_record := l_assign_resources_tbl.FIRST;

      IF (p_auto_select_flag = 'Y') THEN
        l_total_records := p_no_of_resources;
      ELSE
        l_total_records := l_assign_resources_tbl.LAST;
      END IF;

      -- added processing with l_count to fix bug for Defects 2490634
      -- on 6th aug 2002

      WHILE l_current_record <= l_assign_resources_tbl.LAST
      LOOP

        -- removed the calendar check here. calling the procedure for calendar check in the next step
        -- calendar check removed 29th September 2003
        -- removed the autoselect check. This will be done in the GET_ASSIGN_RESOURCES api
        --IF (l_count <= l_total_records) THEN
            x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_count).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_count).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;

            x_assign_resources_tbl(l_count).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
            x_assign_resources_tbl(l_count).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
            x_assign_resources_tbl(l_count).shift_construct_id    := NULL;

            x_assign_resources_tbl(l_count).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
            x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;

            x_assign_resources_tbl(l_count).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_count).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
            x_assign_resources_tbl(l_count).terr_rank             :=
                                   l_assign_resources_tbl(l_current_record).absolute_rank;
            x_assign_resources_tbl(l_count).primary_flag             :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_count).resource_source       := 'TERR';

            l_count := l_count + 1;
          --END IF;
          l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;

      -- added calendar call out
      -- this has been done as now the calendar check is done in a seperate procedure GET_AVAILABLE_RESOURCE
      -- changed on 29th September 2003
      IF (p_calendar_flag = 'Y') THEN
          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
          l_return_status_1 := x_return_status ;
           -- call the api to check resource availability
           get_available_resources
            (
              p_init_msg_list                 =>  'F',
              p_calendar_flag                 =>   p_calendar_flag,
              p_effort_duration               =>  p_effort_duration,
              p_effort_uom                    =>  p_effort_uom,
              p_planned_start_date            =>  l_planned_start_date,
              p_planned_end_date              =>  l_planned_end_date,
              p_continuous_task               =>   jtf_assign_pub.g_continuous_work,
              x_return_status                 =>   x_return_status,
              x_msg_count                     =>   x_msg_count,
              x_msg_data                      =>   x_msg_data,
              x_assign_resources_tbl          =>   x_assign_resources_tbl);

          -- set back the API name to original name
          l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
               fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
               fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
               fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_DEFECT_RESOURCES');
               fnd_msg_pub.add;
               IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
               ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
             END IF; -- end of x_return_status check
      end if; -- if p_calendar_flag = Y


      IF ( p_calendar_flag = 'Y' AND
           x_assign_resources_tbl.count = 0 ) THEN
        fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;

    ELSE   -- No resources returned from the Territory API
      fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
      fnd_msg_pub.add;
--      RAISE fnd_api.g_exc_error;
    END IF;


    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_DEFECT_RESOURCES;






-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_ESC_RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the
--                        territory preferences and the availability.
--                        This is when the calling doc is ESCALATIONS.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                        p_commit              IN      VARCHAR2 optional

--     Assignment Manager Specific Parameters

--     This determines the Resource Type required by the
--     calling document
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form. Defaulted to the PROFILE value
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N


--     This parameter contains the values of the Qualifiers
--     defined for the Escalations.
--     p_esc_tbl                                JTF_ASSIGN_PUB.
--                                              Escalations_tbl_type
--                                              REQUIRED


--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--      Version         : Current version        1.0
--                        Initial version        1.0
--
--      Notes           :
--

-- End of comments

-- *********************************************************************************


  /* Procedure Body with the parameters when the
     Source Document is ESCALATIONS */


  PROCEDURE GET_ASSIGN_ESC_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2 ,
        p_calendar_flag                       IN  VARCHAR2 ,
        p_web_availability_flag               IN  VARCHAR2 ,
        p_esc_tbl                             IN  JTF_ASSIGN_PUB.Escalations_tbl_type,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    )
    IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name                            VARCHAR2(100)  := 'GET_ASSIGN_ESC_RESOURCES';
    l_api_name_1                          VARCHAR2(60)  := 'GET_ASSIGN_ESC_RESOURCES';
    l_api_version                         NUMBER        := 1.0;
    l_planned_start_date                  DATE;
    l_planned_end_date                    DATE;
    l_effort_duration                     NUMBER;
    l_effort_uom                          VARCHAR2(30);

    l_esc_source_code                     JTF_TASKS_VL.SOURCE_OBJECT_TYPE_CODE%TYPE;
    l_esc_source_id                       JTF_TASKS_VL.SOURCE_OBJECT_ID%TYPE;
    l_reference_code                      JTF_TASK_REFERENCES_VL.REFERENCE_CODE%TYPE;

    l_territory_id                        NUMBER;
    l_esc_territory_id                    NUMBER;

    l_object_type_code                    JTF_TASK_REFERENCES_VL.OBJECT_TYPE_CODE%TYPE;
    l_object_id                           JTF_TASK_REFERENCES_VL.OBJECT_ID%TYPE;

    l_travel_time                         NUMBER       := 0;
    l_travel_uom                          VARCHAR2(30) := 'HR';

    l_current_record                      INTEGER;
    l_current_esc_record                  INTEGER DEFAULT 0;
    l_esc_record                          INTEGER;
    l_total_records                       INTEGER;

    l_auto_select_profile                 VARCHAR2(03);
    l_auto_select_flag                    VARCHAR2(03);
    l_workflow_profile                    VARCHAR2(60);

    l_return_code                         VARCHAR2(60);
    l_bind_data_id                        NUMBER;
    l_workflow_key                        NUMBER;

    l_dynamic_sql                         VARCHAR2(2000);
    l_dynamic_sql1                        VARCHAR2(2000);

    l_assign_resources_tbl                JTF_TERRITORY_GET_PUB.QualifyingRsc_out_tbl_type;

    l_x_planned_start_date                DATE;
    l_x_planned_end_date                  DATE;
    l_x_shift_construct_id                NUMBER;
    l_x_availability_type                 VARCHAR2(60);

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

    l_wf_return_status                    VARCHAR2(60);
    l_wf_msg_count                        NUMBER;
    l_wf_msg_data                         VARCHAR2(2000);
    l_esc_count					NUMBER;

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/


    /*
    CURSOR cur_esc_id IS
      SELECT source_object_type_code,
             source_object_id,
             planned_start_date,
             planned_end_date,
             planned_effort,
             planned_effort_uom
      FROM   jtf_tasks_vl
      WHERE  task_id = l_esc_id;
    l_cur_esc_id cur_esc_id%ROWTYPE;


    CURSOR cur_reference_code IS
      SELECT reference_code,
             object_type_code,
             object_id
      FROM   jtf_task_references_vl
      WHERE  task_id = l_esc_id;
    l_cur_reference_code cur_reference_code%ROWTYPE;
    */


    CURSOR cur_source_task IS
      SELECT owner_territory_id
      FROM   jtf_tasks_vl
      WHERE  task_id = l_object_id;


    TYPE DYNAMIC_CUR_TYP IS REF CURSOR;

    cur_source_sr               DYNAMIC_CUR_TYP;
    cur_source_defect           DYNAMIC_CUR_TYP;

    cur_support_site_name       DYNAMIC_CUR_TYP;

    l_support_site              VARCHAR2(15) := 'SUPPORT_SITE';
    l_rsc_type                  VARCHAR2(30);
    l_rsc_id                    NUMBER;
    l_web_availability_flag     VARCHAR2(1)   := p_web_availability_flag;


    CURSOR cur_support_site_id (p_rsc_id NUMBER, p_rsc_type VARCHAR2) IS
      SELECT support_site_id
      FROM   jtf_rs_resource_extns_vl
      WHERE  resource_id = p_rsc_id AND
             category    = p_rsc_type;


    CURSOR cur_web_availability (p_res_id NUMBER, p_res_type VARCHAR2) IS
      SELECT resource_id
      FROM   jtf_rs_web_available_v
      WHERE  resource_id = p_res_id AND
             category    = p_res_type;

   --Bug# 4455803 MOAC.
   CURSOR check_date_cur(l_resource_id in number,
                          l_resource_type in varchar2)
        IS
     SELECT 'Y'
       --FROM  jtf_rs_all_resources_vl
       FROM  jtf_task_resources_vl
      where   resource_id = l_resource_id
        and   resource_type = l_resource_type
        and   nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);

    l_value varchar2(100);

    l_count number := 0;
    l_temp_table    JTF_ASSIGN_PUB.AssignResources_tbl_type;

  BEGIN

    SAVEPOINT get_assign_esc_resources;

    -- Started Assignment Manager API for ESCALATIONS


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;



    /* Get TASK source and the related information */

    /*
    OPEN  cur_esc_id;
    FETCH cur_esc_id INTO l_cur_esc_id;
    IF  ( cur_esc_id%NOTFOUND ) THEN
      fnd_message.set_name('JTF', 'JTF_AM_INVALID_ESC_ID');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    ELSE
      l_esc_source_code     := l_cur_esc_id.source_object_type_code;
      l_esc_source_id       := l_cur_esc_id.source_object_id;
      l_planned_start_date  := l_cur_esc_id.planned_start_date;
      l_planned_end_date    := l_cur_esc_id.planned_end_date;
      l_effort_duration     := l_cur_esc_id.planned_effort;
      l_effort_uom          := l_cur_esc_id.planned_effort_uom;
    END IF;
    CLOSE cur_esc_id;


    IF  ( l_esc_source_code <> 'ESC' ) THEN
      fnd_message.set_name('JTF', 'JTF_AM_INVALID_ESC_ID');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    ELSE
      OPEN  cur_reference_code;
      FETCH cur_reference_code INTO l_cur_reference_code;
      IF (  cur_reference_code%NOTFOUND) THEN
        fnd_message.set_name('JTF', 'JTF_AM_INVALID_ESC_ID');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      ELSE
        l_reference_code   := l_cur_reference_code.reference_code;
        l_object_type_code := l_cur_reference_code.object_type_code;
        l_object_id        := l_cur_reference_code.object_id;

        IF ( l_reference_code <> 'ESC' ) THEN
          fnd_message.set_name('JTF', 'JTF_AM_INVALID_ESC_REF');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
      CLOSE cur_reference_code;
    END IF;

    */


    /* Getting the Auto Select Profile value defined for the Assignment Manager */

    --l_auto_select_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_AUTO_SELECT' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_auto_select_profile := FND_PROFILE.VALUE ( 'ACTIVATE_AUTO_SELECT' ); -- Added by SBARAT on 12/10/2004, Bug-3830061



    /* Assigning the DEFAULT value to the Auto Select Parameter */


    IF (p_auto_select_flag IS NULL) THEN
      l_auto_select_flag  := l_auto_select_profile;
                             -- PROFILE VALUE is the default value
    ELSE
      l_auto_select_flag  := p_auto_select_flag;
    END IF;


    IF ( p_web_availability_flag IS NULL) THEN
      l_web_availability_flag  := 'Y';
    ELSE
      l_web_availability_flag  := p_web_availability_flag;
    END IF;


    /* Defaulting the values for variables to pass to the
       Calendar, to ensure that the resource is working */

    l_planned_start_date  := SYSDATE;
    l_planned_end_date    := SYSDATE;
    l_effort_duration     := NULL;
    l_effort_uom          := NULL;


    /* Defaulting the variable values to IN parameters,
       if the IN paramaters have values given */

    IF (p_start_date IS NOT NULL) THEN
      l_planned_start_date := p_start_date;
    END IF;

    IF (p_end_date IS NOT NULL) THEN
      l_planned_end_date := p_end_date;
    END IF;

    IF (p_effort_duration IS NOT NULL) THEN
      l_effort_duration := p_effort_duration;
    END IF;

    IF (p_effort_uom IS NOT NULL) THEN
      l_effort_uom := p_effort_uom;
    END IF;



    /* Actual Flow of Assignment Manager */


    IF ( p_esc_tbl.count > 0 ) THEN

      l_esc_record := p_esc_tbl.FIRST;

      WHILE (l_esc_record <= p_esc_tbl.LAST)
      LOOP

        l_object_type_code := p_esc_tbl(l_esc_record).source_object_type;
        l_object_id        := p_esc_tbl(l_esc_record).source_object_id;


        IF (l_object_type_code = 'TASK') THEN

          /* Since the Object Code is TASK, OPEN the appropriate cursor
             to get the Territory ID to pass it to the Territory API */

          OPEN  cur_source_task;
          FETCH cur_source_task INTO l_territory_id;

          IF  ( cur_source_task%NOTFOUND ) THEN
            fnd_message.set_name('JTF', 'JTF_AM_INVALID_TASK_ID');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;

          CLOSE cur_source_task;

        ELSIF (l_object_type_code = 'SR') THEN

          /* Since the Object Code is SERVICE REQUEST, OPEN the appropriate
             cursor to get the Territory ID to pass it to the Territory API */

          l_dynamic_sql  :=  ' SELECT territory_id'||
                             ' FROM   cs_incidents_all_vl'||
                             ' WHERE  incident_id = :1';


          OPEN  cur_source_sr FOR l_dynamic_sql USING l_object_id;
          FETCH cur_source_sr INTO l_territory_id;

          IF  ( cur_source_sr%NOTFOUND ) THEN
            fnd_message.set_name('JTF', 'JTF_AM_INVALID_SR_ID');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;

          CLOSE cur_source_sr;


        ELSIF (l_object_type_code = 'DF') THEN

          /* Since the Object Code is DEFECTS, OPEN the appropriate cursor
             to get the Territory ID to pass it to the Territory API */


          l_dynamic_sql  :=  ' SELECT territory_id'||
                             ' FROM   css_def_defects_all'||
                             ' WHERE  defect_id = :1';

          -- dbms_output.put_line('Select is : '||l_dynamic_sql);

          OPEN  cur_source_defect FOR l_dynamic_sql USING l_object_id;
          FETCH cur_source_defect INTO l_territory_id;

          IF  ( cur_source_defect%NOTFOUND ) THEN
            fnd_message.set_name('JTF', 'JTF_AM_INVALID_DEFECT_ID');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
          END IF;

          CLOSE cur_source_defect;


        END IF; -- End of l_object_type_code = 'TASK'




        IF (p_territory_flag = 'Y') THEN

          IF (l_territory_id IS NOT NULL) THEN

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_TERRITORY_GET_PUB';

            JTF_TERRITORY_GET_PUB.Get_Escalation_Territory
              (
                p_api_version         => l_api_version,
                p_init_msg_list       => p_init_msg_list,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_terr_id             => l_territory_id,
                x_escalation_terr_id  => l_esc_territory_id
              );

           -- set back the API name to original name
           l_api_name := l_api_name_1;


            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Territory Manager
              fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
              fnd_msg_pub.add;
              IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE fnd_api.g_exc_error;
              ELSE
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF;

            l_assign_resources_tbl.DELETE;

           IF ( l_esc_territory_id IS NOT NULL) THEN

            -- change the API Name temporarily so that in case of unexpected error
            -- it is properly caught
            l_api_name := l_api_name||'-JTF_TERRITORY_GET_PUB';

              JTF_TERRITORY_GET_PUB.Get_Escalation_TerrMembers
                (
                  p_api_version_number     => l_api_version,
                  p_init_msg_list          => p_init_msg_list,
                  p_commit                 => NULL,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data,
                  p_terr_id                => l_esc_territory_id,
                  x_QualifyingRsc_out_tbl  => l_assign_resources_tbl
                );

            -- set back the API name to original name
            l_api_name := l_api_name_1;

              IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
                -- Unexpected Execution Error from call to Territory Manager
                fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
                fnd_msg_pub.add;
                IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
                ELSE
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              END IF;

            --ELSE
              --fnd_message.set_name('JTF', 'JTF_AM_NO_ESC_TERR');
              --fnd_msg_pub.add;
              --RAISE fnd_api.g_exc_error;
            END IF;

          END IF;  -- IF (l_territory_id IS NOT NULL) THEN


          IF ( l_assign_resources_tbl.COUNT = 0 ) THEN

          -- change the API Name temporarily so that in case of unexpected error
          -- it is properly caught
          l_api_name := l_api_name||'-JTF_TERRITORY_GET_PUB';

            JTF_TERRITORY_GET_PUB.Get_Escalation_TerrMembers
              (
                p_api_version_number     => l_api_version,
                p_init_msg_list          => p_init_msg_list,
                p_commit                 => NULL,
                x_return_status          => x_return_status,
                x_msg_count              => x_msg_count,
                x_msg_data               => x_msg_data,
                p_terr_id                => 1,
                x_QualifyingRsc_out_tbl  => l_assign_resources_tbl
              );

            -- set back the API name to original name
            l_api_name := l_api_name_1;

            IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Territory Manager
              fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
              fnd_msg_pub.add;
              IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                RAISE fnd_api.g_exc_error;
              ELSE
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END IF;
          END IF;



           -- added 2 april 2003 by sudarsana to conver RS_SUPPLIER TO RS_SUPPLIER_CONTACT

          IF(l_assign_resources_tbl.COUNT > 0)
          THEN
             l_current_record := l_assign_resources_tbl.FIRST;
             WHILE (l_current_record <= l_assign_resources_tbl.LAST)
             LOOP
                IF(l_assign_resources_tbl(l_current_record).resource_type = 'RS_SUPPLIER')
                THEN
                   l_assign_resources_tbl(l_current_record).resource_type := 'RS_SUPPLIER_CONTACT';
                END IF;
                l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
             END LOOP;
          END IF;


          IF l_assign_resources_tbl.COUNT > 0 THEN

            l_current_record := l_assign_resources_tbl.FIRST;


            IF (l_auto_select_flag = 'Y') THEN
              l_total_records := p_no_of_resources;
            ELSE
              l_total_records := l_assign_resources_tbl.LAST;
            END IF;

           -- removed the calendar check here. calling the procedure for calendar check in the next step
           -- calendar check removed 29th September 2003
            WHILE l_current_record <= l_assign_resources_tbl.LAST
            LOOP

              -- removed the calendar check here. calling the procedure for calendar check in the next step
              -- calendar check removed 29th September 2003
                open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
                 fetch check_date_cur into l_value;
                 if (check_date_cur%found)
                 then

                   l_count := l_count + 1;

                   x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                         l_assign_resources_tbl(l_current_record).terr_rsc_id;
                   x_assign_resources_tbl(l_count).resource_id           :=
                                         l_assign_resources_tbl(l_current_record).resource_id;
                   x_assign_resources_tbl(l_count).resource_type         :=
                                         l_assign_resources_tbl(l_current_record).resource_type;
                   x_assign_resources_tbl(l_count).role                  :=
                                         l_assign_resources_tbl(l_current_record).role;
                   x_assign_resources_tbl(l_count).start_date            := NULL;
                   x_assign_resources_tbl(l_count).end_date              := NULL;
                   x_assign_resources_tbl(l_count).shift_construct_id    := NULL;
                   x_assign_resources_tbl(l_count).terr_id               :=
                                         l_assign_resources_tbl(l_current_record).terr_id;
                   x_assign_resources_tbl(l_count).terr_name             :=
                                         l_assign_resources_tbl(l_current_record).terr_name;
                   x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                         l_assign_resources_tbl(l_current_record).primary_contact_flag;
                   x_assign_resources_tbl(l_count).primary_flag  :=
                                         l_assign_resources_tbl(l_current_record).primary_contact_flag;
                   x_assign_resources_tbl(l_count).resource_source       := 'TERR';
                 END IF;
                 close check_date_cur;
              l_current_esc_record := l_current_esc_record + 1;
              l_current_record     := l_assign_resources_tbl.NEXT(l_current_record);
            END LOOP;

          -- added calendar call out
          -- this has been done as now the calendar check is done in a seperate procedure GET_AVAILABLE_RESOURCE
          -- changed on 29th September 2003
          -- The calendar flag check will not be done any more. The first available slot will be fetched
          -- This is for the preformance bug 3301417. If the calendar flag is Y then the resources will
          -- filtered based on availability in the procedure get_available_slot. This change is being done on
          -- 16 June 2004
          --IF (p_calendar_flag = 'Y') THEN
             -- change the API Name temporarily so that in case of unexpected error
             -- it is properly caught
              l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
              l_return_status_1 := x_return_status ;
              -- call the api to check resource availability
              get_available_resources
              (
                p_init_msg_list                 =>  'F',
                p_calendar_flag                 =>  p_calendar_flag,
                p_effort_duration               =>  l_effort_duration,
                p_effort_uom                    =>  l_effort_uom,
                p_planned_start_date            =>  l_planned_start_date,
                p_planned_end_date              =>  l_planned_end_date,
                p_breakdown                     =>   null,
                p_breakdown_uom                 =>   null,
                p_continuous_task               =>  jtf_assign_pub.g_continuous_work,
                x_return_status                 =>  x_return_status,
                x_msg_count                     =>  x_msg_count,
                x_msg_data                      =>  x_msg_data,
                x_assign_resources_tbl          =>  x_assign_resources_tbl);

              -- set back the API name to original name
               l_api_name := l_api_name_1;

               IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
              -- Unexpected Execution Error from call to Get_contracts_resources
                 fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
                 fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
                 fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_ESC_RESOURCES');
                 fnd_msg_pub.add;
                 IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                  RAISE fnd_api.g_exc_error;
                 ELSE
                   RAISE fnd_api.g_exc_unexpected_error;
                 END IF;
              END IF; -- end of x_return_status check
           -- end if; -- if p_calendar_flag = Y

            IF ( p_calendar_flag = 'Y' AND
                 x_assign_resources_tbl.count = 0 ) THEN
              fnd_message.set_name('JTF', 'JTF_AM_RESOURCE_NOT_AVAILABLE');
              fnd_msg_pub.add;
--              RAISE fnd_api.g_exc_error;
            END IF;

              -- to implement auto selection
            IF(l_auto_select_flag = 'Y')
            THEN
               l_temp_table.delete;
               l_temp_table := x_assign_resources_tbl;
               x_assign_resources_tbl.delete;
               l_count := 0;
               l_current_record := l_temp_table.FIRST;
               l_total_records := p_no_of_resources;

               WHILE l_current_record <= l_temp_table.LAST
               LOOP
                 If(l_count < l_total_records)
                 THEN
                    x_assign_resources_tbl(l_count) := l_temp_table(l_current_record);
                    l_count := l_count + 1;
                 end if; -- end of count check
                 l_current_record := l_temp_table.NEXT(l_current_record);
               END LOOP; -- end of courrent record check

            END IF; -- end of auto select flag

          ELSE   -- No resources returned from the Territory API
            fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
            fnd_msg_pub.add;
--            RAISE fnd_api.g_exc_error;
          END IF;

        ELSE  -- Territory Flag is NO
          fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
          fnd_msg_pub.add;
--          RAISE fnd_api.g_exc_error;
        END IF;

        l_esc_record := p_esc_tbl.NEXT(l_esc_record);

      END LOOP;

    ELSE -- p_esc_tbl.count <= 0

      -- change the API Name temporarily so that in case of unexpected error
      -- it is properly caught
      l_api_name := l_api_name||'-JTF_TERRITORY_GET_PUB';

      JTF_TERRITORY_GET_PUB.Get_Escalation_TerrMembers
        (
          p_api_version_number     => l_api_version,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => NULL,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          p_terr_id                => 1,
          x_QualifyingRsc_out_tbl  => l_assign_resources_tbl
        );

        -- set back the API name to original name
        l_api_name := l_api_name_1;

      IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
         -- Unexpected Execution Error from call to Territory Manager
         fnd_message.set_name('JTF', 'JTF_AM_ERROR_TERR_API');
         fnd_msg_pub.add;
         IF (x_return_status = fnd_api.g_ret_sts_error) THEN
           RAISE fnd_api.g_exc_error;
         ELSE
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;


      IF l_assign_resources_tbl.COUNT > 0 THEN

        l_current_record     := l_assign_resources_tbl.FIRST;
        l_current_esc_record := 0;


        IF (l_auto_select_flag = 'Y') THEN
          l_total_records := p_no_of_resources;
        ELSE
          l_total_records := l_assign_resources_tbl.LAST;
        END IF;


        WHILE (l_current_record <= l_assign_resources_tbl.LAST ) AND
              (l_count < l_total_records)
        LOOP
          open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
          fetch check_date_cur into l_value;
          if (check_date_cur%found)
          then

            l_count := l_count + 1;

            x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                 l_assign_resources_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_count).resource_id           :=
                                 l_assign_resources_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_count).resource_type         :=
                                 l_assign_resources_tbl(l_current_record).resource_type;
            x_assign_resources_tbl(l_count).role                  :=
                                 l_assign_resources_tbl(l_current_record).role;
            x_assign_resources_tbl(l_count).start_date            := NULL;
            x_assign_resources_tbl(l_count).end_date              := NULL;
            x_assign_resources_tbl(l_count).shift_construct_id    := NULL;
            x_assign_resources_tbl(l_count).terr_id               :=
                                 l_assign_resources_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_count).terr_name             :=
                                 l_assign_resources_tbl(l_current_record).terr_name;
            x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                 l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_count).primary_flag  :=
                                 l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_count).resource_source       := 'TERR';

           end if;
           close check_date_cur;
          l_current_esc_record := l_current_esc_record + 1;
          l_current_record     := l_assign_resources_tbl.NEXT(l_current_record);

        END LOOP;

      ELSE  -- l_assign_resources_tbl.COUNT <= 0
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;


      /*
      fnd_message.set_name('JTF', 'JTF_AM_EMPTY_ESC_TBL');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
      */

    END IF; -- End of l_esc_tbl.count > 0




    -- Start of enhancement to add SUPPORT SITE ID and NAME to the OUT Table

    l_dynamic_sql1 := ' SELECT a.city city '||
                      ' FROM   hz_locations a, hz_party_sites b,  hz_party_site_uses c '||
                      ' WHERE  c.site_use_type = :1  AND '||
                      ' b.party_site_id        = :2  AND '||
                      ' a.location_id          = b.location_id   AND '||
                      ' c.party_site_id        = b.party_site_id ';

    IF x_assign_resources_tbl.COUNT > 0 THEN

      l_current_record := x_assign_resources_tbl.FIRST;

      WHILE l_current_record <= x_assign_resources_tbl.LAST
      LOOP

        l_rsc_type := resource_type_change(x_assign_resources_tbl(l_current_record).resource_type);

        OPEN  cur_support_site_id (x_assign_resources_tbl(l_current_record).resource_id,
                                   l_rsc_type);

        FETCH cur_support_site_id INTO x_assign_resources_tbl(l_current_record).support_site_id;

        IF (x_assign_resources_tbl(l_current_record).support_site_id IS NOT NULL) THEN

          OPEN  cur_support_site_name FOR l_dynamic_sql1
                USING l_support_site,
                      x_assign_resources_tbl(l_current_record).support_site_id;

          FETCH cur_support_site_name INTO x_assign_resources_tbl(l_current_record).support_site_name;
          IF (  cur_support_site_name % NOTFOUND ) THEN
            x_assign_resources_tbl(l_current_record).support_site_name := NULL;
          END IF;
          CLOSE cur_support_site_name;
        ELSE
          x_assign_resources_tbl(l_current_record).support_site_id   := NULL;
          x_assign_resources_tbl(l_current_record).support_site_name := NULL;

        END IF;

        CLOSE cur_support_site_id;

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;

    -- End of enhancement




    -- Start of enhancement to add Web Availability to the OUT Table


    IF (x_assign_resources_tbl.COUNT > 0) THEN

      l_current_record := x_assign_resources_tbl.FIRST;

      WHILE l_current_record <= x_assign_resources_tbl.LAST
      LOOP

        IF ( UPPER(l_web_availability_flag) = 'Y') THEN
          l_rsc_type := resource_type_change(x_assign_resources_tbl(l_current_record).resource_type);

          OPEN  cur_web_availability (x_assign_resources_tbl(l_current_record).resource_id,
                                      l_rsc_type);
          FETCH cur_web_availability INTO l_rsc_id;

          IF (cur_web_availability%FOUND) THEN
            x_assign_resources_tbl(l_current_record).web_availability_flag := 'Y';
          ELSE
            x_assign_resources_tbl(l_current_record).web_availability_flag := 'N';
          END IF;

          CLOSE cur_web_availability;
        ELSE
          x_assign_resources_tbl(l_current_record).web_availability_flag := NULL;
        END IF; --l_web_availability_flag = 'Y'

        l_current_record := x_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;
    END IF;

    -- End of enhancement

/********************** Start of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/

      -- raise workfow event
      -- workflow test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;

	   IF (p_esc_tbl.count>0) THEN

 		l_esc_count := p_esc_tbl.FIRST;

		WHILE (l_esc_count <= p_esc_tbl.LAST)
		LOOP
	         jtf_am_wf_events_pub.assign_esc_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_ESC_REC           	   =>  p_esc_tbl(l_esc_count),
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        		IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            		-- Unexpected Execution Error from call to assign_sr_resource
            		fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            		fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            		fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ESC_RESOURCES');
            		fnd_msg_pub.add;
        		ELSE
				x_assign_resources_tbl.delete;
            		x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;

			END IF;

			l_esc_count := p_esc_tbl.NEXT(l_esc_count);

		END LOOP;
	   ELSE

	     	jtf_am_wf_events_pub.assign_esc_resource
            	  (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_ESC_REC           	   =>  NULL,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        	IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            	-- Unexpected Execution Error from call to assign_sr_resource
            	fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            	fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            	fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ESC_RESOURCES');
            	fnd_msg_pub.add;
        	ELSE
			x_assign_resources_tbl.delete;
            	x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
		END IF;

   	   END IF;

      Exception
            When OTHERS Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;

/********************** End of Addition for Enh. No 3076744 by SBARAT, 23/09/2004 ************************/


    -- To Plugin the Workflow enabling the user
    -- to further filter the resources


    /* Getting the Workflow Profile value defined for the Assignment Manager */

    --l_workflow_profile := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_WORKFLOW_NAME' ); -- Commented out by SBARAT on 12/10/2004, Bug-3830061
    l_workflow_profile := FND_PROFILE.VALUE ( 'ACTIVATE_WORKFLOW_NAME' ); -- Added by SBARAT on 12/10/2004, Bug-3830061


    SELECT jtf_calendars_s.NEXTVAL INTO l_workflow_key
    FROM   dual;

    IF (JTF_USR_HKS.ok_to_execute
          (
            'JTF_ASSIGN_PUB',
            'GET_ASSIGN_ESC_RESOURCES',
            'W',
            'W'
          )
       ) THEN

      IF (JTF_ASSIGN_CUHK.ok_to_launch_workflow
            (
              p_api_version     => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data
            )
         ) THEN

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;


        l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

        JTF_USR_HKS.WrkFlowLaunch
          (
            'JTF_ASSIGN_WF',
            l_workflow_profile,
            'ASSIGN WF - '|| TO_CHAR(l_workflow_key),
            l_bind_data_id,
            l_return_code
          );

        JTF_USR_HKS.purge_bind_data
          (
            l_bind_data_id,
            'W'
          );


        IF (l_return_code = fnd_api.g_ret_sts_error) THEN
          -- Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_return_code = fnd_api.g_ret_sts_unexp_error) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;  -- End of JTF_ASSIGN_CUHK

    END IF;    -- End of JTF_USR_HKS



    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_ESC_RESOURCES;



-- *******************************************************************************

-- Start of comments

--      API name        : GET_ASSIGN_RESOURCES
--      Type            : Public
--      Function        : Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability.
--      Pre-reqs        : None

--      Parameters      :

--      IN              : p_api_version         IN      NUMBER  Required
--                        p_init_msg_list       IN      VARCHAR2 Optional
--                                              DEFAULT JTF_ASSIGN_PUB.AM_FALSE
--                        p_commit              IN      VARCHAR2 optional
--                                              DEFAULT JTF_ASSIGN_PUB.AM_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource, Resource Type
--     and Resource Role required by the calling document
--     p_resource_id                            NUMBER
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     Defaulted to 1
--     p_no_of_resources                        NUMBER

--     This is for sending out the qualified resource directly
--     to the calling form.
--     Defaulted to 'Y'(Profile Value)
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of CONTRACTS PREFERRED ENGINEERS
--     Defaulted to 'N'(Profile Value)
--     p_contracts_preferred_engineer           VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of INSTALL BASE PREFERRED ENGINEERS
--     Defaulted to 'N'(Profile Value)
--     p_ib_preferred_engineer                  VARCHAR2(1)
--                                              : value of  Y or N

--     This is to fetch the CONTRACTS PREFERRED ENGINEERS
--     p_contract_id                            NUMBER

--     This is to fetch the INSTALL BASE PREFERRED ENGINEERS
--     p_customer_product_id                    NUMBER

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required,
--     is determined by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE

--     The Territory Manager is accessed based on the value set
--     Defaulted to Y
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     Defaulted to Y
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N

--     This parameter contains the Calling Document ID
--     which could be a TASK_ID or a SERVICE_REQUEST_ID
--     or a OPPORTUNITY_ID or a LEAD_ID etc.
--     p_calling_doc_id                         NUMBER  -- REQUIRED

--     This parameter contains the Calling Document Type
--     which could be :
--        'TASK' when the calling doc is TASK
--     or 'SR'   when the calling doc is SERVICE REQUEST
--     or 'DEF'  when the calling doc is DEFECT MANAGEMENT
--     or 'OPPR' when the calling doc is OPPORTUNITIES
--     It is mandatory to enter a value for this parameter
--     to find proper qualified resources
--     p_calling_doc_type                        VARCHAR2

--     This parameter contains list of qualifier columns from the
--     UI which have been selected to re-query the resources.
--     Strictly for the use of User Interface of Assignment Manager.
--     p_column_list                             VARCHAR2

--     These parameters contain the Qualifier Values for
--     the Calling Document
--     p_sr_rec                                  JTF_ASSIGN_PUB.
--                                               JTF_Serv_Req_rec_type
--     p_sr_task_rec                             JTF_ASSIGN_PUB.
--                                               JTF_Srv_Task_rec_type
--     p_defect_rec                              JTF_ASSIGN_PUB.
--                                               JTF_Def_Mgmt_rec_type

--     OUT              : x_return_status        OUT     VARCHAR2(1)
--                        x_msg_count            OUT     NUMBER
--                        x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--     Version          : Current version        1.0
--                        Initial version        1.0
--
--     Notes            :
--

-- End of comments

-- *********************************************************************************



  /*  Main Procedure definition with the parameters
      This procedure in turn calls the relevant procedure to
      process the requests for assignment of resources */


  PROCEDURE GET_ASSIGN_RESOURCES
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_commit                              IN  VARCHAR2 ,
        p_resource_id                         IN  NUMBER   ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_contracts_preferred_engineer        IN  VARCHAR2 ,
        p_ib_preferred_engineer               IN  VARCHAR2 ,
        p_contract_id                         IN  NUMBER   ,
        p_customer_product_id                 IN  NUMBER   ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2 ,
        p_calendar_flag                       IN  VARCHAR2 ,
        p_web_availability_flag               IN  VARCHAR2 ,
        p_category_id                         IN  NUMBER   ,
        p_inventory_item_id                   IN  NUMBER   ,
        p_inventory_org_id                    IN  NUMBER   ,
 	p_problem_code                        IN  VARCHAR2 ,
        p_calling_doc_id                      IN  NUMBER,
        p_calling_doc_type                    IN  VARCHAR2,
        p_column_list                         IN  VARCHAR2 ,
        p_sr_rec                              IN  JTF_ASSIGN_PUB.JTF_Serv_Req_rec_type ,
        p_sr_task_rec                         IN  JTF_ASSIGN_PUB.JTF_Srv_Task_rec_type ,
        p_defect_rec                          IN  JTF_ASSIGN_PUB.JTF_Def_Mgmt_rec_type ,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        p_filter_excluded_resource            IN  VARCHAR2,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5386560
	p_inventory_component_id              IN  NUMBER DEFAULT NULL,
	--Added for Bug # 5386560 Ends here
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    )
  IS

    l_return_status_1                     VARCHAR2(10);
    l_api_name			                         VARCHAR2(100)	:= 'GET_ASSIGN_RESOURCES';
    l_api_name_1  	                       VARCHAR2(60)	:= 'GET_ASSIGN_RESOURCES';
    l_api_version           	             NUMBER        := 1.0;
    l_no_of_resources                     NUMBER        := p_no_of_resources;
    l_auto_select_flag                    VARCHAR2(1)   := p_auto_select_flag;
    l_contracts_preferred_engineer        VARCHAR2(1)   := p_contracts_preferred_engineer;
    l_ib_preferred_engineer               VARCHAR2(1)   := p_ib_preferred_engineer;
    l_territory_flag                      VARCHAR2(1)   := p_territory_flag;
    l_calendar_flag                       VARCHAR2(1)   := p_calendar_flag;
    l_calling_doc_type                    VARCHAR2(10)  := p_calling_doc_type;

    l_web_availability_flag               VARCHAR2(1)   := p_web_availability_flag;

    l_contracts_profile                   VARCHAR2(1);
    l_ib_profile                          VARCHAR2(1);
    l_auto_select_profile                 VARCHAR2(1);
    l_workflow_profile                    VARCHAR2(60);

    l_current_record                      INTEGER;
    l_dynamic_cursor                      INTEGER;
    l_dynamic_sql                         VARCHAR2(4000);

    l_return_code                         VARCHAR2(60);
    l_wf_return_status                    VARCHAR2(60);
    l_wf_msg_count                        NUMBER;
    l_wf_msg_data                         VARCHAR2(2000);

    l_bind_data_id                        NUMBER;
    l_workflow_key                        NUMBER;

    l_sr_rec                              JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type;
    l_sr_task_rec                         JTF_TERRITORY_PUB.JTF_Srv_Task_rec_type;
    l_defect_rec                          JTF_TERRITORY_PUB.JTF_Def_Mgmt_rec_type;
    l_assign_resources_tbl                JTF_ASSIGN_PUB.AssignResources_tbl_type;
    t_assign_resources_tbl                JTF_ASSIGN_PUB.AssignResources_tbl_type; --6453896



    CURSOR cur_resource_type IS
      SELECT object_code
      FROM   jtf_object_usages
      WHERE  object_user_code = 'RESOURCES' AND
             object_code      = p_resource_type;
    l_cur_resource_type cur_resource_type%ROWTYPE;


    CURSOR cur_res_location(p_rid NUMBER, p_rtype VARCHAR2) IS
      SELECT DECODE(source_postal_code, NULL, '00000', source_postal_code)
      FROM   jtf_rs_resource_extns_vl
      WHERE  resource_id     = p_rid AND
             'RS_'||category = p_rtype;


    /*
    CURSOR cur_effort_uom IS
      SELECT uom_code
      FROM   mtl_units_of_measure_vl
      WHERE  uom_code = p_effort_uom;
    l_cur_effort_uom cur_effort_uom%ROWTYPE;
    */

    --Bug# 4455803 MOAC.
    CURSOR check_date_cur(l_resource_id in number,
                          l_resource_type in varchar2)
        IS
     SELECT 'Y'
       --FROM  jtf_rs_all_resources_vl
       FROM  jtf_task_resources_vl
      where   resource_id = l_resource_id
        and   resource_type = l_resource_type
        and   nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);

    l_value varchar2(100);

    l_count number := 0;

    l_usage varchar2(2000);
     -- new variable to handle uom code issue for effort durations
    l_effort_duration                    NUMBER;
    l_uom_hour                           VARCHAR2(2000);
    l_sort_profile			 VARCHAR2(2);

 /*procedure ts(v varchar2)
    is
      pragma autonomous_transaction;
    begin
      insert into test_values values(v);
      commit;
    end;*/
  BEGIN
    SAVEPOINT jtf_assign_pub;

    -- Started Assignment Manager Public API


    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;



    /* Paramater Validation */


    IF (p_resource_type IS NOT NULL) THEN
      OPEN  cur_resource_type;
      FETCH cur_resource_type INTO l_cur_resource_type;
      IF ( cur_resource_type%NOTFOUND) THEN
        fnd_message.set_name('JTF', 'JTF_AM_INVALID_RESOURCE_TYPE');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE cur_resource_type;
    END IF;


    /*
    IF (p_effort_uom IS NOT NULL) THEN
      OPEN  cur_effort_uom;
      FETCH cur_effort_uom INTO l_cur_effort_uom;
      IF ( cur_effort_uom%NOTFOUND) THEN
        fnd_message.set_name('JTF', 'JTF_AM_INVALID_EFFORT_UOM');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE cur_effort_uom;
    END IF;
    */


    /* Getting the Profile values defined for the Assignment Manager */


    /**************Start of commenting out by SBARAT on 12/10/2004, Bug-3830061***************/

    /*
    l_contracts_profile       := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_CONTRACTS_PREFERRED_ENGINEERS' );
    l_auto_select_profile     := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_AUTO_SELECT' );
    l_workflow_profile        := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_WORKFLOW_NAME' );
    l_ib_profile              := FND_PROFILE.VALUE_SPECIFIC ( 'ACTIVATE_IB_PREFERRED_ENGINEERS');
    */

    /**************End of commenting out by SBARAT on 12/10/2004, Bug-3830061**************/

    /**************Start of addition by SBARAT on 12/10/2004, Bug-3830061****************/

    l_contracts_profile       := FND_PROFILE.VALUE ( 'ACTIVATE_CONTRACTS_PREFERRED_ENGINEERS' );
    l_auto_select_profile     := FND_PROFILE.VALUE ( 'ACTIVATE_AUTO_SELECT' );
    l_workflow_profile        := FND_PROFILE.VALUE ( 'ACTIVATE_WORKFLOW_NAME' );
    l_ib_profile              := FND_PROFILE.VALUE ( 'ACTIVATE_IB_PREFERRED_ENGINEERS');

    /**************End of addition by SBARAT on 12/10/2004, Bug-3830061****************/

    -- get the profile value for usage
    l_usage                   := fnd_profile.value('JTF_AM_USAGE');

    /* Assigning the DEFAULT values for the Parameters */


    IF (p_auto_select_flag IS NULL) THEN
      l_auto_select_flag  := l_auto_select_profile;
                             -- PROFILE VALUE is the default value
    ELSE
      l_auto_select_flag  := p_auto_select_flag;
    END IF;


    IF (p_contracts_preferred_engineer IS NULL) THEN
      l_contracts_preferred_engineer  := l_contracts_profile;
                                         -- PROFILE VALUE is the default value
    ELSE
      l_contracts_preferred_engineer  := p_contracts_preferred_engineer;
    END IF;


    IF (p_ib_preferred_engineer IS NULL) THEN
      l_ib_preferred_engineer  := l_ib_profile;
                                  -- PROFILE VALUE is the default value
    ELSE
      l_ib_preferred_engineer  := p_ib_preferred_engineer;
    END IF;


    IF (p_no_of_resources IS NULL) THEN
      l_no_of_resources  := 1;  -- 1 is the default value
    ELSE
      l_no_of_resources  := p_no_of_resources;
    END IF;


    IF ( (UPPER(p_territory_flag) = 'N')
       -- added this line to handle null value as N
         OR (p_territory_flag IS NULL)) THEN
      l_territory_flag  := 'N';
    ELSE
      l_territory_flag  := 'Y';  -- YES is the default value
    END IF;


    IF ( (UPPER(p_calendar_flag) = 'N')
      -- added this line to handle null value as N
         OR (p_calendar_flag IS NULL)) THEN
      l_calendar_flag  := 'N';
    ELSE
      l_calendar_flag  := 'Y';  -- YES is the default value
    END IF;


    IF ( p_web_availability_flag IS NULL) THEN
      l_web_availability_flag  := 'Y';
    ELSE
      l_web_availability_flag  := p_web_availability_flag;
    END IF;


     /* to handle the conversion of duration to hour */
    l_uom_hour  := nvl(fnd_profile.value('JTF_AM_TASK_HOUR'), 'HR');


   --Commented out by SBARAT on 21/04/2005 for Bug-4300801
   --It was causing double conversion since same conversion is being done
   --in the overloaded procedure GET_AVAILABLE_RESOURCES
  /*if(nvl(p_effort_uom, l_uom_hour) <> l_uom_hour)
    then
         l_effort_duration :=  inv_convert.inv_um_convert(
                                   item_id => NULL,
                                   precision => 2,
                                   from_quantity => p_effort_duration,
                                   from_unit => p_effort_uom,
                                   to_unit   => l_uom_hour, --'HR',
                                   from_name => NULL,
                                   to_name   => NULL);
    else
        l_effort_duration := p_effort_duration;
    end if;*/

    l_effort_duration := p_effort_duration;    --Added by SBARAT on 21/04/2005 for Bug-4300801

    /* This assigning is being done because of the limitation for
       the direct use of the variables FND_API.MISS_NUM, MISS_CHAR etc. */


    /* Assigning values to the Service Request Record Type */

/**************** Start of addition by SBARAT on 11/01/2005 for Enh 4112155**************/

    Terr_Qual_Dyn_Assign(p_sr_rec, p_sr_task_rec);

    l_sr_rec:=JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type;
    l_sr_task_rec:=JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type;

    JTF_ASSIGN_PUB.G_Terr_Serv_Req_Rec_Type:=Null;
    JTF_ASSIGN_PUB.G_Terr_Srv_Task_Rec_Type:=Null;

/**************** End of addition by SBARAT on 11/01/2005 for Enh 4112155**************/

    l_sr_rec.SERVICE_REQUEST_ID   :=  p_sr_rec.SERVICE_REQUEST_ID;
    l_sr_rec.PARTY_ID             :=  p_sr_rec.PARTY_ID;
    l_sr_rec.COUNTRY              :=  p_sr_rec.COUNTRY;
    l_sr_rec.PARTY_SITE_ID        :=  p_sr_rec.PARTY_SITE_ID;
    l_sr_rec.CITY                 :=  p_sr_rec.CITY;
    l_sr_rec.POSTAL_CODE          :=  p_sr_rec.POSTAL_CODE;
    l_sr_rec.STATE                :=  p_sr_rec.STATE;
    l_sr_rec.AREA_CODE            :=  p_sr_rec.AREA_CODE;
    l_sr_rec.COUNTY               :=  p_sr_rec.COUNTY;
    l_sr_rec.COMP_NAME_RANGE      :=  p_sr_rec.COMP_NAME_RANGE;
    l_sr_rec.PROVINCE             :=  p_sr_rec.PROVINCE;
    l_sr_rec.NUM_OF_EMPLOYEES     :=  p_sr_rec.NUM_OF_EMPLOYEES;
    l_sr_rec.INCIDENT_TYPE_ID     :=  p_sr_rec.INCIDENT_TYPE_ID;
    l_sr_rec.INCIDENT_SEVERITY_ID :=  p_sr_rec.INCIDENT_SEVERITY_ID;
    l_sr_rec.INCIDENT_URGENCY_ID  :=  p_sr_rec.INCIDENT_URGENCY_ID;
    l_sr_rec.PROBLEM_CODE         :=  p_sr_rec.PROBLEM_CODE;
    l_sr_rec.INCIDENT_STATUS_ID   :=  p_sr_rec.INCIDENT_STATUS_ID;
    l_sr_rec.PLATFORM_ID          :=  p_sr_rec.PLATFORM_ID;
    l_sr_rec.SUPPORT_SITE_ID      :=  p_sr_rec.SUPPORT_SITE_ID;
    l_sr_rec.CUSTOMER_SITE_ID     :=  p_sr_rec.CUSTOMER_SITE_ID;
    l_sr_rec.SR_CREATION_CHANNEL  :=  p_sr_rec.SR_CREATION_CHANNEL;
    l_sr_rec.INVENTORY_ITEM_ID    :=  p_sr_rec.INVENTORY_ITEM_ID;
    l_sr_rec.ATTRIBUTE1           :=  p_sr_rec.ATTRIBUTE1;
    l_sr_rec.ATTRIBUTE2           :=  p_sr_rec.ATTRIBUTE2;
    l_sr_rec.ATTRIBUTE3           :=  p_sr_rec.ATTRIBUTE3;
    l_sr_rec.ATTRIBUTE4           :=  p_sr_rec.ATTRIBUTE4;
    l_sr_rec.ATTRIBUTE5           :=  p_sr_rec.ATTRIBUTE5;
    l_sr_rec.ATTRIBUTE6           :=  p_sr_rec.ATTRIBUTE6;
    l_sr_rec.ATTRIBUTE7           :=  p_sr_rec.ATTRIBUTE7;
    l_sr_rec.ATTRIBUTE8           :=  p_sr_rec.ATTRIBUTE8;
    l_sr_rec.ATTRIBUTE9           :=  p_sr_rec.ATTRIBUTE9;
    l_sr_rec.ATTRIBUTE10          :=  p_sr_rec.ATTRIBUTE10;
    l_sr_rec.ATTRIBUTE11          :=  p_sr_rec.ATTRIBUTE11;
    l_sr_rec.ATTRIBUTE12          :=  p_sr_rec.ATTRIBUTE12;
    l_sr_rec.ATTRIBUTE13          :=  p_sr_rec.ATTRIBUTE13;
    l_sr_rec.ATTRIBUTE14          :=  p_sr_rec.ATTRIBUTE14;
    l_sr_rec.ATTRIBUTE15          :=  p_sr_rec.ATTRIBUTE15;
    l_sr_rec.ORGANIZATION_ID      :=  p_sr_rec.ORGANIZATION_ID;
    l_sr_rec.SQUAL_NUM12          :=  p_sr_rec.SQUAL_NUM12;
    l_sr_rec.SQUAL_NUM13          :=  p_sr_rec.SQUAL_NUM13;
    l_sr_rec.SQUAL_NUM14          :=  p_sr_rec.SQUAL_NUM14;
    l_sr_rec.SQUAL_NUM15          :=  p_sr_rec.SQUAL_NUM15;
    l_sr_rec.SQUAL_NUM16          :=  p_sr_rec.SQUAL_NUM16;
    l_sr_rec.SQUAL_NUM17          :=  p_sr_rec.SQUAL_NUM17;
    l_sr_rec.SQUAL_NUM18          :=  p_sr_rec.SQUAL_NUM18;
    l_sr_rec.SQUAL_NUM19          :=  p_sr_rec.SQUAL_NUM19;
    l_sr_rec.SQUAL_NUM30          :=  p_sr_rec.SQUAL_NUM30;
    l_sr_rec.SQUAL_CHAR11         :=  p_sr_rec.SQUAL_CHAR11;
    l_sr_rec.SQUAL_CHAR12         :=  p_sr_rec.SQUAL_CHAR12;
    l_sr_rec.SQUAL_CHAR13         :=  p_sr_rec.SQUAL_CHAR13;
    l_sr_rec.DAY_OF_WEEK          :=  p_sr_rec.DAY_OF_WEEK;
    l_sr_rec.TIME_OF_DAY          :=  p_sr_rec.TIME_OF_DAY;

    -- added by sudarsana for terr rec type change
    l_sr_rec.SQUAL_CHAR20         :=  p_sr_rec.SQUAL_CHAR20;
    -- Added by vvuyyuru for Contracts Coverage Type
    l_sr_rec.SQUAL_CHAR21         :=  p_sr_rec.SQUAL_CHAR21;




    /* Assigning values to the Service Request + Task Record Type */

    l_sr_task_rec.TASK_ID              :=  p_sr_task_rec.TASK_ID;
    l_sr_task_rec.SERVICE_REQUEST_ID   :=  p_sr_task_rec.SERVICE_REQUEST_ID;
    l_sr_task_rec.PARTY_ID             :=  p_sr_task_rec.PARTY_ID;
    l_sr_task_rec.COUNTRY              :=  p_sr_task_rec.COUNTRY;
    l_sr_task_rec.PARTY_SITE_ID        :=  p_sr_task_rec.PARTY_SITE_ID;
    l_sr_task_rec.CITY                 :=  p_sr_task_rec.CITY;
    l_sr_task_rec.POSTAL_CODE          :=  p_sr_task_rec.POSTAL_CODE;
    l_sr_task_rec.STATE                :=  p_sr_task_rec.STATE;
    l_sr_task_rec.AREA_CODE            :=  p_sr_task_rec.AREA_CODE;
    l_sr_task_rec.COUNTY               :=  p_sr_task_rec.COUNTY;
    l_sr_task_rec.COMP_NAME_RANGE      :=  p_sr_task_rec.COMP_NAME_RANGE;
    l_sr_task_rec.PROVINCE             :=  p_sr_task_rec.PROVINCE;
    l_sr_task_rec.NUM_OF_EMPLOYEES     :=  p_sr_task_rec.NUM_OF_EMPLOYEES;
    l_sr_task_rec.TASK_TYPE_ID         :=  p_sr_task_rec.TASK_TYPE_ID;
    l_sr_task_rec.TASK_STATUS_ID       :=  p_sr_task_rec.TASK_STATUS_ID;
    l_sr_task_rec.TASK_PRIORITY_ID     :=  p_sr_task_rec.TASK_PRIORITY_ID;
    l_sr_task_rec.INCIDENT_TYPE_ID     :=  p_sr_task_rec.INCIDENT_TYPE_ID;
    l_sr_task_rec.INCIDENT_SEVERITY_ID :=  p_sr_task_rec.INCIDENT_SEVERITY_ID;
    l_sr_task_rec.INCIDENT_URGENCY_ID  :=  p_sr_task_rec.INCIDENT_URGENCY_ID;
    l_sr_task_rec.PROBLEM_CODE         :=  p_sr_task_rec.PROBLEM_CODE;
    l_sr_task_rec.INCIDENT_STATUS_ID   :=  p_sr_task_rec.INCIDENT_STATUS_ID;
    l_sr_task_rec.PLATFORM_ID          :=  p_sr_task_rec.PLATFORM_ID;
    l_sr_task_rec.SUPPORT_SITE_ID      :=  p_sr_task_rec.SUPPORT_SITE_ID;
    l_sr_task_rec.CUSTOMER_SITE_ID     :=  p_sr_task_rec.CUSTOMER_SITE_ID;
    l_sr_task_rec.SR_CREATION_CHANNEL  :=  p_sr_task_rec.SR_CREATION_CHANNEL;
    l_sr_task_rec.INVENTORY_ITEM_ID    :=  p_sr_task_rec.INVENTORY_ITEM_ID;
    l_sr_task_rec.ATTRIBUTE1           :=  p_sr_task_rec.ATTRIBUTE1;
    l_sr_task_rec.ATTRIBUTE2           :=  p_sr_task_rec.ATTRIBUTE2;
    l_sr_task_rec.ATTRIBUTE3           :=  p_sr_task_rec.ATTRIBUTE3;
    l_sr_task_rec.ATTRIBUTE4           :=  p_sr_task_rec.ATTRIBUTE4;
    l_sr_task_rec.ATTRIBUTE5           :=  p_sr_task_rec.ATTRIBUTE5;
    l_sr_task_rec.ATTRIBUTE6           :=  p_sr_task_rec.ATTRIBUTE6;
    l_sr_task_rec.ATTRIBUTE7           :=  p_sr_task_rec.ATTRIBUTE7;
    l_sr_task_rec.ATTRIBUTE8           :=  p_sr_task_rec.ATTRIBUTE8;
    l_sr_task_rec.ATTRIBUTE9           :=  p_sr_task_rec.ATTRIBUTE9;
    l_sr_task_rec.ATTRIBUTE10          :=  p_sr_task_rec.ATTRIBUTE10;
    l_sr_task_rec.ATTRIBUTE11          :=  p_sr_task_rec.ATTRIBUTE11;
    l_sr_task_rec.ATTRIBUTE12          :=  p_sr_task_rec.ATTRIBUTE12;
    l_sr_task_rec.ATTRIBUTE13          :=  p_sr_task_rec.ATTRIBUTE13;
    l_sr_task_rec.ATTRIBUTE14          :=  p_sr_task_rec.ATTRIBUTE14;
    l_sr_task_rec.ATTRIBUTE15          :=  p_sr_task_rec.ATTRIBUTE15;
    l_sr_task_rec.ORGANIZATION_ID      :=  p_sr_task_rec.ORGANIZATION_ID;
    l_sr_task_rec.SQUAL_NUM12          :=  p_sr_task_rec.SQUAL_NUM12;
    l_sr_task_rec.SQUAL_NUM13          :=  p_sr_task_rec.SQUAL_NUM13;
    l_sr_task_rec.SQUAL_NUM14          :=  p_sr_task_rec.SQUAL_NUM14;
    l_sr_task_rec.SQUAL_NUM15          :=  p_sr_task_rec.SQUAL_NUM15;
    l_sr_task_rec.SQUAL_NUM16          :=  p_sr_task_rec.SQUAL_NUM16;
    l_sr_task_rec.SQUAL_NUM17          :=  p_sr_task_rec.SQUAL_NUM17;
    l_sr_task_rec.SQUAL_NUM18          :=  p_sr_task_rec.SQUAL_NUM18;
    l_sr_task_rec.SQUAL_NUM19          :=  p_sr_task_rec.SQUAL_NUM19;
    l_sr_task_rec.SQUAL_NUM30          :=  p_sr_task_rec.SQUAL_NUM30;
    l_sr_task_rec.SQUAL_CHAR11         :=  p_sr_task_rec.SQUAL_CHAR11;
    l_sr_task_rec.SQUAL_CHAR12         :=  p_sr_task_rec.SQUAL_CHAR12;
    l_sr_task_rec.SQUAL_CHAR13         :=  p_sr_task_rec.SQUAL_CHAR13;
    -- added by sudarsana for terr rec type change
    l_sr_task_rec.SQUAL_CHAR20         :=  p_sr_task_rec.SQUAL_CHAR20;
    -- Added by vvuyyuru for Contracts Coverage Type
    l_sr_task_rec.SQUAL_CHAR21         :=  p_sr_task_rec.SQUAL_CHAR21;
    l_sr_task_rec.DAY_OF_WEEK          :=  p_sr_task_rec.DAY_OF_WEEK;
    l_sr_task_rec.TIME_OF_DAY          :=  p_sr_task_rec.TIME_OF_DAY;




    /* Assigning values to the Defect Record Type */

    l_defect_rec.SQUAL_CHAR01          :=  p_defect_rec.SQUAL_CHAR01;
    l_defect_rec.SQUAL_CHAR02          :=  p_defect_rec.SQUAL_CHAR02;
    l_defect_rec.SQUAL_CHAR03          :=  p_defect_rec.SQUAL_CHAR03;
    l_defect_rec.SQUAL_CHAR04          :=  p_defect_rec.SQUAL_CHAR04;
    l_defect_rec.SQUAL_CHAR05          :=  p_defect_rec.SQUAL_CHAR05;
    l_defect_rec.SQUAL_CHAR06          :=  p_defect_rec.SQUAL_CHAR06;
    l_defect_rec.SQUAL_CHAR07          :=  p_defect_rec.SQUAL_CHAR07;
    l_defect_rec.SQUAL_CHAR08          :=  p_defect_rec.SQUAL_CHAR08;
    l_defect_rec.SQUAL_CHAR09          :=  p_defect_rec.SQUAL_CHAR09;
    l_defect_rec.SQUAL_CHAR10          :=  p_defect_rec.SQUAL_CHAR10;
    l_defect_rec.SQUAL_CHAR11          :=  p_defect_rec.SQUAL_CHAR11;
    l_defect_rec.SQUAL_CHAR12          :=  p_defect_rec.SQUAL_CHAR12;
    l_defect_rec.SQUAL_CHAR13          :=  p_defect_rec.SQUAL_CHAR13;
    l_defect_rec.SQUAL_CHAR14          :=  p_defect_rec.SQUAL_CHAR14;
    l_defect_rec.SQUAL_CHAR15          :=  p_defect_rec.SQUAL_CHAR15;
    l_defect_rec.SQUAL_CHAR16          :=  p_defect_rec.SQUAL_CHAR16;
    l_defect_rec.SQUAL_CHAR17          :=  p_defect_rec.SQUAL_CHAR17;
    l_defect_rec.SQUAL_CHAR18          :=  p_defect_rec.SQUAL_CHAR18;
    l_defect_rec.SQUAL_CHAR19          :=  p_defect_rec.SQUAL_CHAR19;
    l_defect_rec.SQUAL_CHAR20          :=  p_defect_rec.SQUAL_CHAR20;
    l_defect_rec.SQUAL_CHAR21          :=  p_defect_rec.SQUAL_CHAR21;
    l_defect_rec.SQUAL_CHAR22          :=  p_defect_rec.SQUAL_CHAR22;
    l_defect_rec.SQUAL_CHAR23          :=  p_defect_rec.SQUAL_CHAR23;
    l_defect_rec.SQUAL_CHAR24          :=  p_defect_rec.SQUAL_CHAR24;
    l_defect_rec.SQUAL_CHAR25          :=  p_defect_rec.SQUAL_CHAR25;

    l_defect_rec.SQUAL_NUM01           :=  p_defect_rec.SQUAL_NUM01;
    l_defect_rec.SQUAL_NUM02           :=  p_defect_rec.SQUAL_NUM02;
    l_defect_rec.SQUAL_NUM03           :=  p_defect_rec.SQUAL_NUM03;
    l_defect_rec.SQUAL_NUM04           :=  p_defect_rec.SQUAL_NUM04;
    l_defect_rec.SQUAL_NUM05           :=  p_defect_rec.SQUAL_NUM05;
    l_defect_rec.SQUAL_NUM06           :=  p_defect_rec.SQUAL_NUM06;
    l_defect_rec.SQUAL_NUM07           :=  p_defect_rec.SQUAL_NUM07;
    l_defect_rec.SQUAL_NUM08           :=  p_defect_rec.SQUAL_NUM08;
    l_defect_rec.SQUAL_NUM09           :=  p_defect_rec.SQUAL_NUM09;
    l_defect_rec.SQUAL_NUM10           :=  p_defect_rec.SQUAL_NUM10;
    l_defect_rec.SQUAL_NUM11           :=  p_defect_rec.SQUAL_NUM11;
    l_defect_rec.SQUAL_NUM12           :=  p_defect_rec.SQUAL_NUM12;
    l_defect_rec.SQUAL_NUM13           :=  p_defect_rec.SQUAL_NUM13;
    l_defect_rec.SQUAL_NUM14           :=  p_defect_rec.SQUAL_NUM14;
    l_defect_rec.SQUAL_NUM15           :=  p_defect_rec.SQUAL_NUM15;
    l_defect_rec.SQUAL_NUM16           :=  p_defect_rec.SQUAL_NUM16;
    l_defect_rec.SQUAL_NUM17           :=  p_defect_rec.SQUAL_NUM17;
    l_defect_rec.SQUAL_NUM18           :=  p_defect_rec.SQUAL_NUM18;
    l_defect_rec.SQUAL_NUM19           :=  p_defect_rec.SQUAL_NUM19;
    l_defect_rec.SQUAL_NUM20           :=  p_defect_rec.SQUAL_NUM20;
    l_defect_rec.SQUAL_NUM21           :=  p_defect_rec.SQUAL_NUM21;
    l_defect_rec.SQUAL_NUM22           :=  p_defect_rec.SQUAL_NUM22;
    l_defect_rec.SQUAL_NUM23           :=  p_defect_rec.SQUAL_NUM23;
    l_defect_rec.SQUAL_NUM24           :=  p_defect_rec.SQUAL_NUM24;
    l_defect_rec.SQUAL_NUM25           :=  p_defect_rec.SQUAL_NUM25;

    l_defect_rec.ATTRIBUTE1              :=  p_defect_rec.ATTRIBUTE1;
    l_defect_rec.ATTRIBUTE2              :=  p_defect_rec.ATTRIBUTE2;
    l_defect_rec.ATTRIBUTE3              :=  p_defect_rec.ATTRIBUTE3;
    l_defect_rec.ATTRIBUTE4              :=  p_defect_rec.ATTRIBUTE4;
    l_defect_rec.ATTRIBUTE5              :=  p_defect_rec.ATTRIBUTE5;
    l_defect_rec.ATTRIBUTE6              :=  p_defect_rec.ATTRIBUTE6;
    l_defect_rec.ATTRIBUTE7              :=  p_defect_rec.ATTRIBUTE7;
    l_defect_rec.ATTRIBUTE8              :=  p_defect_rec.ATTRIBUTE8;
    l_defect_rec.ATTRIBUTE9              :=  p_defect_rec.ATTRIBUTE9;
    l_defect_rec.ATTRIBUTE10             :=  p_defect_rec.ATTRIBUTE10;
    l_defect_rec.ATTRIBUTE11             :=  p_defect_rec.ATTRIBUTE11;
    l_defect_rec.ATTRIBUTE12             :=  p_defect_rec.ATTRIBUTE12;
    l_defect_rec.ATTRIBUTE13             :=  p_defect_rec.ATTRIBUTE13;
    l_defect_rec.ATTRIBUTE14             :=  p_defect_rec.ATTRIBUTE14;
    l_defect_rec.ATTRIBUTE15             :=  p_defect_rec.ATTRIBUTE15;




    /* Actual Flow of Assignment Manager
       Calls to be made now to get the qualified resources */

    IF ( UPPER ( p_calling_doc_type ) NOT IN (
                                                'TASK',
                                                'SR'  ,
                                                'DEF'
                                             )
       ) THEN

      fnd_message.set_name('JTF', 'JTF_AM_INVALID_DOC_TYPE');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;

    END IF;


    IF ( UPPER(l_calling_doc_type) = 'SR' ) THEN
      GET_ASSIGN_SR_RESOURCES
        (
          p_api_version                    => l_api_version,
          p_init_msg_list                  => p_init_msg_list,
          p_resource_type                  => p_resource_type,
          p_role                           => p_role,
          p_no_of_resources                => l_no_of_resources,
          p_auto_select_flag               => l_auto_select_flag,
          p_contracts_preferred_engineer   => l_contracts_preferred_engineer,
          p_ib_preferred_engineer          => l_ib_preferred_engineer,
          p_contract_id                    => p_contract_id,
          p_customer_product_id            => p_customer_product_id,
          p_effort_duration                => l_effort_duration, --p_effort_duration,
          p_effort_uom                     => p_effort_uom,
          p_start_date                     => p_start_date,
          p_end_date                       => p_end_date,
          p_territory_flag                 => l_territory_flag,
          p_calendar_flag                  => l_calendar_flag,
          p_web_availability_flag          => l_web_availability_flag,
          p_category_id                    => p_category_id,
          p_inventory_item_id              => p_inventory_item_id,
          p_inventory_org_id               => p_inventory_org_id,
          --Added for Bug # 5386560
	  p_inventory_component_id         => p_inventory_component_id,
          --Added for Bug # 5386560 Ends here
	  p_problem_code                   => p_problem_code ,
          p_sr_id                          => p_calling_doc_id,
          p_sr_rec                         => l_sr_rec,
          p_sr_task_rec                    => l_sr_task_rec,
          p_business_process_id            => p_business_process_id,
          p_business_process_date          => p_business_process_date,
          p_filter_excluded_resource       => p_filter_excluded_resource,
          x_assign_resources_tbl           => l_assign_resources_tbl,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data,
	  --Added for Bug # 5573916
	  p_calendar_check                 => p_calendar_check
	  --Added for Bug # 5573916 Ends here
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
          fnd_message.set_token('P_PROC_NAME','GET_ASSIGN_SR_RESOURCES');
          fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_RESOURCES');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

      -- added this to filter by usage
      IF ((l_assign_resources_tbl.count > 0 ) AND
          (nvl(l_usage, fnd_api.g_miss_char)  <> 'ALL' ) AND
          (l_usage is not null)
         )
      THEN
          get_usage_resource(l_usage ,
                             l_assign_resources_tbl);
      END IF;


      IF l_assign_resources_tbl.COUNT > 0 THEN

        l_current_record := l_assign_resources_tbl.FIRST;

        IF ( UPPER(l_auto_select_flag) = 'Y' ) THEN

          --l_no_of_resources := l_assign_resources_tbl.count;
          -- added this condition to avoid pl/sql numeric error. if no of resources was greater than table count
          -- it still used to go into loop . 13 july 2004
            l_no_of_resources := least(nvl(l_assign_resources_tbl.count, 0),l_no_of_resources) ;

          --WHILE (l_current_record <= l_no_of_resources)
          WHILE (l_count < l_no_of_resources)
          LOOP

             -- add check to see whether the resource is end dated or not
          -- added by sudarsana 21 feb 02
          open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
          fetch check_date_cur into l_value;
          if (check_date_cur%found)
          then

            l_count := l_count + 1;

            x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_count).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_count).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;
            x_assign_resources_tbl(l_count).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
            x_assign_resources_tbl(l_count).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
            x_assign_resources_tbl(l_count).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
            x_assign_resources_tbl(l_count).shift_construct_id    :=
                                   l_assign_resources_tbl(l_current_record).shift_construct_id;
            x_assign_resources_tbl(l_count).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_count).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
	    -- ================code added for bug 6453896=============
	    x_assign_resources_tbl(l_count).terr_rank             :=
                                l_assign_resources_tbl(l_current_record).terr_rank;
            -- ================End for addition of code===============
            x_assign_resources_tbl(l_count).preference_type       :=
                                   l_assign_resources_tbl(l_current_record).preference_type;
            x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_count).group_id              :=
                                   l_assign_resources_tbl(l_current_record).group_id;

            x_assign_resources_tbl(l_count).support_site_id       :=
                                   l_assign_resources_tbl(l_current_record).support_site_id;
            x_assign_resources_tbl(l_count).support_site_name     :=
                                   l_assign_resources_tbl(l_current_record).support_site_name;
            x_assign_resources_tbl(l_count).web_availability_flag :=
                                   l_assign_resources_tbl(l_current_record).web_availability_flag;

            x_assign_resources_tbl(l_count).skill_level           :=
                                   l_assign_resources_tbl(l_current_record).skill_level;
            x_assign_resources_tbl(l_count).skill_name            :=
                                   l_assign_resources_tbl(l_current_record).skill_name;
            x_assign_resources_tbl(l_count).primary_flag            :=
                                   l_assign_resources_tbl(l_current_record).primary_flag;
            x_assign_resources_tbl(l_count).resource_source       :=
                                   l_assign_resources_tbl(l_current_record).resource_source;
            end if;
            close check_date_cur;
            l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
          END LOOP;

        ELSE  -- Auto Select Flag is NO

          WHILE l_current_record <= l_assign_resources_tbl.LAST
          LOOP
             -- add check to see whether the resource is end dated or not
             -- added by sudarsana 21 feb 02
             open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
             fetch check_date_cur into l_value;
             if (check_date_cur%found)
             then
               l_count := l_count + 1;

               x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
               x_assign_resources_tbl(l_count).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
               x_assign_resources_tbl(l_count).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;
               x_assign_resources_tbl(l_count).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
               x_assign_resources_tbl(l_count).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
               x_assign_resources_tbl(l_count).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
               x_assign_resources_tbl(l_count).shift_construct_id    :=
                                   l_assign_resources_tbl(l_current_record).shift_construct_id;
               x_assign_resources_tbl(l_count).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
               x_assign_resources_tbl(l_count).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
	       -- ================code added for bug 6453896=============
	       x_assign_resources_tbl(l_count).terr_rank             :=
                                l_assign_resources_tbl(l_current_record).terr_rank;
	       -- ================End for addition of code===============
               x_assign_resources_tbl(l_count).preference_type       :=
                                   l_assign_resources_tbl(l_current_record).preference_type;
               x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
               x_assign_resources_tbl(l_count).group_id              :=
                                   l_assign_resources_tbl(l_current_record).group_id;

               x_assign_resources_tbl(l_count).support_site_id       :=
                                   l_assign_resources_tbl(l_current_record).support_site_id;
               x_assign_resources_tbl(l_count).support_site_name     :=
                                   l_assign_resources_tbl(l_current_record).support_site_name;
               x_assign_resources_tbl(l_count).web_availability_flag :=
                                   l_assign_resources_tbl(l_current_record).web_availability_flag;

               x_assign_resources_tbl(l_count).skill_level           :=
                                   l_assign_resources_tbl(l_current_record).skill_level;
               x_assign_resources_tbl(l_count).skill_name            :=
                                   l_assign_resources_tbl(l_current_record).skill_name;
               x_assign_resources_tbl(l_count).primary_flag            :=
                                   l_assign_resources_tbl(l_current_record).primary_flag;
               x_assign_resources_tbl(l_count).resource_source       :=
                                   l_assign_resources_tbl(l_current_record).resource_source;
               end if;
               close check_date_cur;
               l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
          END LOOP;
        END IF;   -- Auto Select Flag

      ELSE
        -- No resources returned from the Assignment Manager API for SERVICE REQUESTS
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;


      -- raise workfow event
      -- workflow test
      begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_sr_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_CONTRACT_ID           =>  p_contract_id   ,
                     P_CUSTOMER_PRODUCT_ID   =>  p_customer_product_id   ,
                     P_CATEGORY_ID           =>  p_category_id   ,
                     P_INVENTORY_ITEM_ID     =>  p_inventory_item_id   ,
                     P_INVENTORY_ORG_ID      =>  p_inventory_org_id   ,
		     --Added for Bug # 5386560
		     P_INVENTORY_COMPONENT_ID =>  p_inventory_component_id   ,
		     --Added for Bug # 5386560 Ends here
                     P_PROBLEM_CODE          =>  p_problem_code ,
                     P_SR_REC                =>  p_sr_rec,
                     P_SR_TASK_REC           =>  p_sr_task_rec,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


         IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_sr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_RESOURCES');
            fnd_msg_pub.add;
            /* Not raising the errors as req by tele service team
             IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            */
        ELSE
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;


         exception
            when others then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      end;

      -- ================code added for bug 6453896==========================
      -- =============== This code is added for sorting table based on territory ranking===========
      l_sort_profile := nvl(fnd_profile.value('JTF_AM_SORT_TERR_RANK'),'N');
      If l_sort_profile ='Y'
      then
		t_assign_resources_tbl :=x_assign_resources_tbl;
		x_assign_resources_tbl.delete;

		quick_sort_terr_rank
		(
		 t_assign_resources_tbl.FIRST,
		 t_assign_resources_tbl.LAST,
		 t_assign_resources_tbl
		);
		x_assign_resources_tbl:=t_assign_resources_tbl;
      End If;
      -- ================End for addition of code===============

    ELSIF ( UPPER(l_calling_doc_type) = 'TASK' ) THEN

      GET_ASSIGN_TASK_RESOURCES
        (
          p_api_version                    => l_api_version,
          p_init_msg_list                  => p_init_msg_list,
          p_resource_type                  => p_resource_type,
          p_role                           => p_role,
          p_no_of_resources                => l_no_of_resources,
          p_auto_select_flag               => l_auto_select_flag,
          p_contracts_preferred_engineer   => l_contracts_preferred_engineer,
          p_ib_preferred_engineer          => l_ib_preferred_engineer,
          p_effort_duration                => l_effort_duration, --p_effort_duration,
          p_effort_uom                     => p_effort_uom,
          p_start_date                     => p_start_date,
          p_end_date                       => p_end_date,
          p_territory_flag                 => l_territory_flag,
          p_calendar_flag                  => l_calendar_flag,
          p_web_availability_flag          => l_web_availability_flag,
          p_task_id                        => p_calling_doc_id,
          p_column_list                    => p_column_list,
          p_business_process_id            => p_business_process_id,
          p_business_process_date          => p_business_process_date,
          x_assign_resources_tbl           => l_assign_resources_tbl,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data,
	  --Added for Bug # 5573916
	  p_calendar_check                 => p_calendar_check
	  --Added for Bug # 5573916 Ends here
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
          fnd_message.set_token('P_PROC_NAME','GET_ASSIGN_TASK_RESOURCES');
          fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_RESOURCES');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

      /* Begin code to implement the sorting of resources by postal code */
      -- added this to filter by usage
      IF ((l_assign_resources_tbl.count > 0 ) AND
          (nvl(l_usage, fnd_api.g_miss_char)  <> 'ALL' ) AND
          (l_usage is not null)
          --(l_usage is not null or l_usage <> 'ALL')
         )
      THEN
          get_usage_resource(l_usage ,
                             l_assign_resources_tbl);
      END IF;

      /* This LOOP is to add the resource postal code to the
         list of qualified resources */

      l_current_record   := l_assign_resources_tbl.FIRST;

      WHILE (l_current_record <= l_assign_resources_tbl.LAST)
      LOOP

        OPEN  cur_res_location(l_assign_resources_tbl(l_current_record).resource_id,
                               l_assign_resources_tbl(l_current_record).resource_type);
        FETCH cur_res_location INTO l_assign_resources_tbl(l_current_record).location;
        CLOSE cur_res_location;

        l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
      END LOOP;



      /* Calling the procedure to sort PL SQL table rows */

     /*
      quick_sort_resource_loc
      (
        l_assign_resources_tbl.FIRST,
        l_assign_resources_tbl.LAST,
        l_assign_resources_tbl
      );
     */

      /* End of the code for the sorting by Resource Location */



      IF l_assign_resources_tbl.COUNT > 0 THEN

        l_current_record := l_assign_resources_tbl.FIRST;

        IF ( UPPER(l_auto_select_flag) = 'Y' ) THEN

          -- added this condition to avoid pl/sql numeric error. if no of resources was greater than table count
          -- it still used to go into loop . 13 july 2004
            l_no_of_resources := least(nvl(l_assign_resources_tbl.count, 0),l_no_of_resources) ;

          --WHILE (l_current_record <= l_no_of_resources)
          WHILE (l_count < l_no_of_resources)
          LOOP
          -- add check to see whether the resource is end dated or not
          -- added by sudarsana 21 feb 02
          open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
          fetch check_date_cur into l_value;
          if (check_date_cur%found)
          then
            l_count := l_count + 1;
            x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_count).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_count).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;
            x_assign_resources_tbl(l_count).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
            x_assign_resources_tbl(l_count).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
            x_assign_resources_tbl(l_count).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
            x_assign_resources_tbl(l_count).shift_construct_id    :=
                                   l_assign_resources_tbl(l_current_record).shift_construct_id;
            x_assign_resources_tbl(l_count).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_count).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
	    -- ================code added for bug 6453896=============
            x_assign_resources_tbl(l_count).terr_rank             :=
                                l_assign_resources_tbl(l_current_record).terr_rank;
	    -- ================End for addition of code===============
            x_assign_resources_tbl(l_count).preference_type       :=
                                   l_assign_resources_tbl(l_current_record).preference_type;
            x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_count).location              :=
                                   l_assign_resources_tbl(l_current_record).location;

            x_assign_resources_tbl(l_count).support_site_id       :=
                                   l_assign_resources_tbl(l_current_record).support_site_id;
            x_assign_resources_tbl(l_count).support_site_name     :=
                                   l_assign_resources_tbl(l_current_record).support_site_name;
            x_assign_resources_tbl(l_count).web_availability_flag :=
                                   l_assign_resources_tbl(l_current_record).web_availability_flag;
            x_assign_resources_tbl(l_count).primary_flag            :=
                                   l_assign_resources_tbl(l_current_record).primary_flag;
            x_assign_resources_tbl(l_count).resource_source       :=
                                   l_assign_resources_tbl(l_current_record).resource_source;


           end if;
           close check_date_cur;
           l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
          END LOOP;

        ELSE  -- Auto Select Flag is NO

          WHILE l_current_record <= l_assign_resources_tbl.LAST
          LOOP

             -- add check to see whether the resource is end dated or not
          -- added by sudarsana 21 feb 02
          open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
          fetch check_date_cur into l_value;
          if (check_date_cur%found)
          then
            l_count := l_count + 1;
            x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                   l_assign_resources_tbl(l_current_record).terr_rsc_id;
            x_assign_resources_tbl(l_count).resource_id           :=
                                   l_assign_resources_tbl(l_current_record).resource_id;
            x_assign_resources_tbl(l_count).resource_type         :=
                                   l_assign_resources_tbl(l_current_record).resource_type;
            x_assign_resources_tbl(l_count).role                  :=
                                   l_assign_resources_tbl(l_current_record).role;
            x_assign_resources_tbl(l_count).start_date            :=
                                   l_assign_resources_tbl(l_current_record).start_date;
            x_assign_resources_tbl(l_count).end_date              :=
                                   l_assign_resources_tbl(l_current_record).end_date;
            x_assign_resources_tbl(l_count).shift_construct_id    :=
                                   l_assign_resources_tbl(l_current_record).shift_construct_id;
            x_assign_resources_tbl(l_count).terr_id               :=
                                   l_assign_resources_tbl(l_current_record).terr_id;
            x_assign_resources_tbl(l_count).terr_name             :=
                                   l_assign_resources_tbl(l_current_record).terr_name;
	    -- ================code added for bug 6453896=============
            x_assign_resources_tbl(l_count).terr_rank             :=
                                l_assign_resources_tbl(l_current_record).terr_rank;
	    -- ================End for addition of code===============
            x_assign_resources_tbl(l_count).preference_type       :=
                                   l_assign_resources_tbl(l_current_record).preference_type;
            x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                   l_assign_resources_tbl(l_current_record).primary_contact_flag;
            x_assign_resources_tbl(l_count).location              :=
                                   l_assign_resources_tbl(l_current_record).location;

            x_assign_resources_tbl(l_count).support_site_id       :=
                                   l_assign_resources_tbl(l_current_record).support_site_id;
            x_assign_resources_tbl(l_count).support_site_name     :=
                                   l_assign_resources_tbl(l_current_record).support_site_name;
            x_assign_resources_tbl(l_count).web_availability_flag :=
                                   l_assign_resources_tbl(l_current_record).web_availability_flag;
            x_assign_resources_tbl(l_count).primary_flag            :=
                                   l_assign_resources_tbl(l_current_record).primary_flag;
            x_assign_resources_tbl(l_count).resource_source            :=
                                   l_assign_resources_tbl(l_current_record).resource_source;
            end if;
            close check_date_cur;
            l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
          END LOOP;
        END IF;   -- Auto Select Flag

      ELSE   -- No resources returned from the Assignment Manager API for TASKS
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;

      -- raise workfow event
      -- workflow test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_task_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     P_TASK_ID		   =>  p_calling_doc_id,
                     P_CONTRACT_ID           =>  p_contract_id   ,
                     P_CUSTOMER_PRODUCT_ID   =>  p_customer_product_id   ,
                     P_CATEGORY_ID           =>  p_category_id   ,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_sr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_RESOURCES');
            fnd_msg_pub.add;

        ELSE
		x_assign_resources_tbl.delete;
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;

      Exception
            When OTHERS Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;

      -- ================code added for bug 6453896==========================
      -- =============== This code is added for sorting table based on territory ranking===========
      l_sort_profile := nvl(fnd_profile.value('JTF_AM_SORT_TERR_RANK'),'N');
      If l_sort_profile ='Y'
      then
		t_assign_resources_tbl :=x_assign_resources_tbl;
		x_assign_resources_tbl.delete;

		quick_sort_terr_rank
		(
		 t_assign_resources_tbl.FIRST,
		 t_assign_resources_tbl.LAST,
		 t_assign_resources_tbl
		);
		x_assign_resources_tbl:=t_assign_resources_tbl;
      End If;
      -- ================End for addition of code===============

    ELSIF ( UPPER(l_calling_doc_type) = 'DEF' ) THEN
      GET_ASSIGN_DEFECT_RESOURCES
        (
          p_api_version                    => l_api_version,
          p_init_msg_list                  => p_init_msg_list,
          p_resource_type                  => p_resource_type,
          p_role                           => p_role,
          p_no_of_resources                => l_no_of_resources,
          p_auto_select_flag               => l_auto_select_flag,
          p_effort_duration                => l_effort_duration, --p_effort_duration,
          p_effort_uom                     => p_effort_uom,
          p_start_date                     => p_start_date,
          p_end_date                       => p_end_date,
          p_territory_flag                 => l_territory_flag,
          p_calendar_flag                  => l_calendar_flag,
          p_defect_rec                     => l_defect_rec,
          p_business_process_id            => p_business_process_id,
          p_business_process_date          => p_business_process_date,
          x_assign_resources_tbl           => l_assign_resources_tbl,
          x_return_status                  => x_return_status,
          x_msg_count                      => x_msg_count,
          x_msg_data                       => x_msg_data
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
          fnd_message.set_token('P_PROC_NAME','GET_ASSIGN_DEFECT_RESOURCES');
          fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_RESOURCES');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;

      -- added this to filter by usage
      IF ((l_assign_resources_tbl.count > 0 ) AND
          (nvl(l_usage, fnd_api.g_miss_char)  <> 'ALL' ) AND
          (l_usage is not null)
          --(l_usage is not null or l_usage <> 'ALL')
         )
      THEN
          get_usage_resource(l_usage ,
                             l_assign_resources_tbl);
      END IF;

      IF l_assign_resources_tbl.COUNT > 0 THEN


        l_current_record := l_assign_resources_tbl.FIRST;

        -- added the autoselect check here after removing from the GET_ASSIGN_DEFECT_RESOURCES api
        -- on 29th september 2003
         IF (p_auto_select_flag = 'Y') THEN
              l_no_of_resources  := p_no_of_resources;
         ELSE
              l_no_of_resources  := l_assign_resources_tbl.LAST;
         END IF;

        -- added processing with l_count to fix defect bug 2490634
        -- on 6th aug 2002
        x_assign_resources_tbl.delete;
        l_count := l_current_record;
        WHILE l_current_record <= l_assign_resources_tbl.LAST
        LOOP

          IF(l_count <= l_no_of_resources)
          THEN
          -- add check to see whether the resource is end dated or not
          -- added by sudarsana 21 feb 02
             open check_date_cur(l_assign_resources_tbl(l_current_record).resource_id,
                              l_assign_resources_tbl(l_current_record).resource_type);
             fetch check_date_cur into l_value;
             if (check_date_cur%found)
             then
                x_assign_resources_tbl(l_count).terr_rsc_id           :=
                                 l_assign_resources_tbl(l_current_record).terr_rsc_id;
                x_assign_resources_tbl(l_count).resource_id           :=
                                 l_assign_resources_tbl(l_current_record).resource_id;
                x_assign_resources_tbl(l_count).resource_type         :=
                                 l_assign_resources_tbl(l_current_record).resource_type;

                x_assign_resources_tbl(l_count).start_date            :=
                                 l_assign_resources_tbl(l_current_record).start_date;
                x_assign_resources_tbl(l_count).end_date              :=
                                 l_assign_resources_tbl(l_current_record).end_date;
                x_assign_resources_tbl(l_count).shift_construct_id    :=
                                 l_assign_resources_tbl(l_current_record).shift_construct_id;

                x_assign_resources_tbl(l_count).role                  :=
                                 l_assign_resources_tbl(l_current_record).role;
                x_assign_resources_tbl(l_count).preference_type       :=
                                 l_assign_resources_tbl(l_current_record).preference_type;
                x_assign_resources_tbl(l_count).primary_contact_flag  :=
                                 l_assign_resources_tbl(l_current_record).primary_contact_flag;

                x_assign_resources_tbl(l_count).terr_id               :=
                                 l_assign_resources_tbl(l_current_record).terr_id;
                x_assign_resources_tbl(l_count).terr_name             :=
                                 l_assign_resources_tbl(l_current_record).terr_name;
                x_assign_resources_tbl(l_count).terr_rank             :=
                                 l_assign_resources_tbl(l_current_record).terr_rank;
                x_assign_resources_tbl(l_count).primary_flag            :=
                                   l_assign_resources_tbl(l_current_record).primary_flag;
                x_assign_resources_tbl(l_count).resource_source            :=
                                   l_assign_resources_tbl(l_current_record).resource_source;
                l_count := l_count + 1;
             end if; -- end of check_date_cur found check
             close check_date_cur;
          END IF; -- end of check l_count against l_no_of_resources
          l_current_record := l_assign_resources_tbl.NEXT(l_current_record);
        END LOOP;

      ELSE   -- No resources returned from the Assignment Manager API for DEFECTS
        fnd_message.set_name('JTF', 'JTF_AM_NO_RESOURCES_FOUND');
        fnd_msg_pub.add;
--        RAISE fnd_api.g_exc_error;
      END IF;

      -- raise workfow event
      -- workflow test
      Begin
         jtf_assign_pub.g_assign_resources_tbl.delete;
         jtf_assign_pub.g_assign_resources_tbl := x_assign_resources_tbl;
         jtf_am_wf_events_pub.assign_def_resource
                    (P_API_VERSION           =>  1.0,
                     P_INIT_MSG_LIST         =>  'F',
                     P_COMMIT                =>  'F',
                     P_CONTRACT_ID           =>  p_contract_id   ,
                     P_CUSTOMER_PRODUCT_ID   =>  p_customer_product_id   ,
                     P_CATEGORY_ID           =>  p_category_id   ,
                     P_DEF_MGMT_REC          =>  p_defect_rec,
                     P_BUSINESS_PROCESS_ID   =>  p_business_process_id,
                     P_BUSINESS_PROCESS_DATE =>  p_business_process_date,
                     X_RETURN_STATUS         =>  l_wf_return_status,
                     X_MSG_COUNT             =>  l_wf_msg_count,
                     X_MSG_DATA              =>  l_wf_msg_data
                     );


        IF NOT (l_wf_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to assign_sr_resource
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','JTF_AM_WF_EVENTS_PUB');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_RESOURCES');
            fnd_msg_pub.add;

        ELSE
		x_assign_resources_tbl.delete;
            x_assign_resources_tbl := jtf_assign_pub.g_assign_resources_tbl;
        END IF;


      Exception
            When OTHERS Then
               fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
               fnd_message.set_token('P_SQLCODE',SQLCODE);
               fnd_message.set_token('P_SQLERRM',SQLERRM);
               fnd_message.set_token('P_API_NAME',l_api_name);
               FND_MSG_PUB.add;
      End;


    END IF;  -- End of UPPER(l_calling_doc_type)= 'SR'- 'TASK'- 'DEF'



    -- To Plugin the Workflow enabling the user
    -- to further filter the resources

    SELECT jtf_calendars_s.NEXTVAL INTO l_workflow_key
    FROM   dual;

    IF (JTF_USR_HKS.ok_to_execute
          (
            'JTF_ASSIGN_PUB',
            'GET_ASSIGN_RESOURCES',
            'W',
            'W'
          )
       ) THEN

      IF (JTF_ASSIGN_CUHK.ok_to_launch_workflow
            (
              p_api_version     => l_api_version,
              p_init_msg_list   => p_init_msg_list,
              x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data
            )
         ) THEN


        IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
            RAISE fnd_api.g_exc_error;
          ELSE
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;


        l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

        JTF_USR_HKS.WrkFlowLaunch
          (
            'JTF_ASSIGN_WF',
            l_workflow_profile,
            'ASSIGN WF - '|| TO_CHAR(l_workflow_key),
            l_bind_data_id,
            l_return_code
          );

        JTF_USR_HKS.purge_bind_data
          (
            l_bind_data_id,
            'W'
          );


        IF (l_return_code = fnd_api.g_ret_sts_error) THEN
          -- Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        ELSIF (l_return_code = fnd_api.g_ret_sts_unexp_error) THEN
          -- Unexpected Execution Error from call to Assignment Manager Workflow Hook
          fnd_message.set_name('JTF', 'JTF_AM_ERROR_WF_API');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;  -- End of JTF_ASSIGN_CUHK

    END IF;    -- End of JTF_USR_HKS


    /* Standard call to get message count and
       the message information */

    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count,
      p_data  => x_msg_data
    );


    x_return_status := fnd_api.g_ret_sts_success;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

  END GET_ASSIGN_RESOURCES;

 -- this is a procedure added on 2nd July 2002 to get the Excluded Resources for the AM UI
 -- when working in assisted Mode
 PROCEDURE GET_EXCLUDED_RESOURCES
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
        p_commit                              IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
        p_contract_id                         IN  NUMBER   DEFAULT NULL,
        p_customer_product_id                 IN  NUMBER   DEFAULT NULL,
        p_calling_doc_id                      IN  NUMBER,
        p_calling_doc_type                    IN  VARCHAR2,
        p_sr_rec                              IN  JTF_ASSIGN_PUB.JTF_Serv_Req_rec_type DEFAULT pkg_sr_rec,
        p_sr_task_rec                         IN  JTF_ASSIGN_PUB.JTF_Srv_Task_rec_type DEFAULT pkg_sr_task_rec,
        p_dr_rec                              IN  JTF_ASSIGN_PUB.JTF_DR_rec_type DEFAULT pkg_dr_rec, --Added by SBARAT on  01/11/2004 for Enh-3919046
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        x_excluded_resouurce_tbl              OUT NOCOPY JTF_ASSIGN_PUB.excluded_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    )
 IS
   l_return_status_1                     VARCHAR2(10);
   l_api_name                            VARCHAR2(100)  := 'GET_EXCLUDED_RESOURCES';
   l_api_name_1                          VARCHAR2(60)  := 'GET_EXCLUDED_RESOURCES';
   l_api_version                         NUMBER        := 1.0;

    -- tables to habdle excluded resource feature
    l_excluded_resource_tbl               JTF_ASSIGN_PUB.excluded_tbl_type;
    l_contracts_tbl                       JTF_ASSIGN_PUB.AssignResources_tbl_type;
    l_ib_tbl                              JTF_ASSIGN_PUB.AssignResources_tbl_type;

    l_contract_id                         NUMBER := p_contract_id;
    l_cp_id                               NUMBER := p_customer_product_id;

    l_sr_id                               NUMBER;
    l_task_id                             NUMBER;
    l_dr_id                               NUMBER;
    l_task_source_code                    JTF_TASKS_VL.SOURCE_OBJECT_TYPE_CODE%TYPE;
    l_task_source_id                      JTF_TASKS_VL.SOURCE_OBJECT_ID%TYPE;

    l_return_status                       VARCHAR2(10);
    l_msg_count                           NUMBER;
    l_msg_data                            VARCHAR2(2000);

     l_dynamic_sql1                        VARCHAR2(2000);

     TYPE DYNAMIC_CUR_TYP   IS REF CURSOR;
     cur_cs_contacts   DYNAMIC_CUR_TYP;
     cur_cs_incidents  DYNAMIC_CUR_TYP;

      CURSOR cur_task_id IS
      SELECT source_object_type_code,
             source_object_id,
             planned_start_date,
             planned_end_date,
             planned_effort,
             planned_effort_uom
      FROM   jtf_tasks_vl
      WHERE  task_id = l_task_id;

      l_cur_task_id cur_task_id%ROWTYPE;

BEGIN

    /* Standard call to check for call compatibility */

    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */

    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    -- If p_document_type = TASK then get the contract_service_id and the customer_product_id from the table
    IF(p_calling_doc_type = 'TASK')
    THEN
      l_task_id := p_calling_doc_id;
      If(l_task_id IS NOT NULL)
      -- this has been added as in form startup we now do a autoquery. So if no task id is passed instead of throwing the
      -- message that invalid id has been passed in we will just not do any processing
      THEN
         OPEN  cur_task_id;
         FETCH cur_task_id INTO l_cur_task_id;
         IF  ( cur_task_id%NOTFOUND )
         THEN
             null;
         ELSE
             l_task_source_code    := l_cur_task_id.source_object_type_code;
             l_task_source_id      := l_cur_task_id.source_object_id;
         END IF;
         CLOSE cur_task_id;


         IF (l_task_source_id IS NOT NULL AND l_task_source_code = 'SR')
         THEN
              l_dynamic_sql1 :=  ' SELECT contract_service_id, customer_product_id'||
                                 ' FROM   cs_incidents_all_vl'||
                                 ' WHERE  incident_id = :1';

              OPEN  cur_cs_incidents FOR  l_dynamic_sql1 USING l_task_source_id;
              FETCH cur_cs_incidents INTO l_contract_id,
                                          l_cp_id;
          END IF;

       ELSIF(p_calling_doc_type = 'SR')
         -- If document type = SR then get the contract_service_id and customer_product_id from the parameters if passed
         -- Else get it from the cs_incidents_all table
       THEN
       l_sr_id       := p_calling_doc_id;
       l_contract_id := p_contract_id;
       l_cp_id       := p_customer_product_id;
        -- Code to fetch the Preferred Resources for saved SR
         IF (l_contract_id IS NULL AND
             l_cp_id       IS NULL AND
             l_sr_id       IS NOT NULL) THEN

            l_dynamic_sql1 :=  ' SELECT contract_service_id, customer_product_id'||
                               ' FROM   cs_incidents_all_vl'||
                               ' WHERE  incident_id = :1';

            OPEN  cur_cs_incidents FOR  l_dynamic_sql1 USING l_sr_id;
            FETCH cur_cs_incidents INTO l_contract_id,
                                        l_cp_id;

            IF ( cur_cs_incidents%NOTFOUND ) THEN
               null;
            END IF;

            CLOSE cur_cs_incidents;
          END IF;  -- end of l_contract_id and l_cp_id null check

       /********** Added by SBARAT on 01/11/2004 for Enh-3919046 ***********/

       ELSIF(p_calling_doc_type = 'DR')
         -- If document type = DR then get the contract_service_id and customer_product_id from the parameters if passed
         -- Else get it from the cs_incidents_all table
       THEN
       l_dr_id       := p_calling_doc_id;
       l_contract_id := p_contract_id;
       l_cp_id       := p_customer_product_id;
        -- Code to fetch the Preferred Resources for saved DR
         IF (l_contract_id IS NULL AND
             l_cp_id       IS NULL AND
             l_dr_id       IS NOT NULL) THEN

            l_dynamic_sql1 :=  ' SELECT contract_service_id, customer_product_id'||
                               ' FROM   cs_incidents_all_vl'||
                               ' WHERE  incident_id = :1';

            OPEN  cur_cs_incidents FOR  l_dynamic_sql1 USING l_dr_id;
            FETCH cur_cs_incidents INTO l_contract_id,
                                        l_cp_id;

            IF ( cur_cs_incidents%NOTFOUND ) THEN
               null;
            END IF;

            CLOSE cur_cs_incidents;
          END IF;  -- end of l_contract_id and l_cp_id null check

       /********* End of addition by SBARAT on 01/11/2004 for Enh-3919046 ********/

       END IF;

    END IF; -- end of calling doc type check



  -- call the get_contract_resources and get_ib_resources to get the excluded resources
  IF(l_contract_id is not null)
  THEN
         get_contracts_resources
          (
            p_init_msg_list           =>  p_init_msg_list,
            p_contract_id             =>  l_contract_id,
            p_calendar_flag           =>  'N',
            p_effort_duration         =>  null,
            p_effort_uom              =>  null,
            p_planned_start_date      =>  null,
            p_planned_end_date        =>  null,
            p_resource_type           =>  null,
            p_business_process_id     =>  p_business_process_id,
            p_business_process_date   =>  p_business_process_date,
            x_return_status           =>  x_return_status,
            x_msg_count               =>  x_msg_count,
            x_msg_data                =>  x_msg_data,
            x_assign_resources_tbl    =>  l_contracts_tbl,
            x_excluded_tbl            =>  l_excluded_resource_tbl
          );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_CONTRACTS_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_SR_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
   END IF;


   IF(l_cp_id is not null)
   THEN
       get_ib_resources
            (
              p_init_msg_list           =>  p_init_msg_list,
              p_customer_product_id     =>  l_cp_id,
              p_calendar_flag           =>  'N',
              p_effort_duration         =>  null,
              p_effort_uom              =>  null,
              p_planned_start_date      =>  null,
              p_planned_end_date        =>  null,
              p_resource_type           =>  null,
              x_return_status           =>  x_return_status,
              x_msg_count               =>  x_msg_count,
              x_msg_data                =>  x_msg_data,
              x_assign_resources_tbl    =>  l_ib_tbl,
              x_excluded_tbl            =>  l_excluded_resource_tbl
            );

          IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
            fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
            fnd_message.set_token('P_PROC_NAME','GET_IB_RESOURCES');
            fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_ASSIGN_TASK_RESOURCES');
            fnd_msg_pub.add;
            IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
            ELSE
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
          END IF;
    END IF;


   -- assign the excluded resources to the out table
    x_excluded_resouurce_tbl.delete;
    x_excluded_resouurce_tbl := l_excluded_resource_tbl;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );
 END  GET_EXCLUDED_RESOURCES;


 -- this is a wrapper for get_available_resource
 -- this is to be used only from AM UI to get the available slots for the resources fetched in
 -- Unassisted mode
 PROCEDURE GET_RESOURCE_AVAILABILITY
            ( p_api_version                   IN  NUMBER,
              p_init_msg_list                 IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
              p_commit                        IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
              p_calendar_flag                 IN  VARCHAR2,
              p_effort_duration               IN  NUMBER,
              p_effort_uom                    IN  VARCHAR2,
              p_breakdown                     IN  NUMBER,
              p_breakdown_uom                 IN  VARCHAR2,
              p_planned_start_date            IN  DATE,
              p_planned_end_date              IN  DATE,
              p_continuous_task               IN  VARCHAR2 DEFAULT 'N',
              x_return_status                 IN  OUT NOCOPY VARCHAR2,
              x_msg_count                     IN  OUT NOCOPY NUMBER,
              x_msg_data                      IN  OUT NOCOPY VARCHAR2,
              x_assign_resources_tbl          IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type
            )
 IS
  l_return_status_1                     VARCHAR2(10);
   l_api_name                            VARCHAR2(100)  := 'GET_EXCLUDED_RESOURCES';
   l_api_name_1                          VARCHAR2(60)  := 'GET_EXCLUDED_RESOURCES';
   l_api_version                         NUMBER        := 1.0;

 BEGIN
   /* Standard call to check for call compatibility */
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
    THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF fnd_api.to_boolean (p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    l_api_name := l_api_name||'-GET_AVAILABLE_RESOURCE';
    l_return_status_1 := x_return_status ;
    -- call the api to check resource availability
     get_available_resources
      (
       p_init_msg_list                 =>  'F',
       p_calendar_flag                 =>   p_calendar_flag,
       p_effort_duration               =>   p_effort_duration,
       p_effort_uom                    =>   p_effort_uom,
       p_breakdown                     =>   p_breakdown,
       p_breakdown_uom                 =>   p_breakdown_uom,
       p_planned_start_date            =>   p_planned_start_date,
       p_planned_end_date              =>   p_planned_end_date,
       p_continuous_task               =>   jtf_assign_pub.g_continuous_work,
       x_return_status                 =>   x_return_status,
       x_msg_count                     =>   x_msg_count,
       x_msg_data                      =>   x_msg_data,
       x_assign_resources_tbl          =>   x_assign_resources_tbl);

       -- set back the API name to original name
       l_api_name := l_api_name_1;

       IF NOT (x_return_status = fnd_api.g_ret_sts_success) THEN
            -- Unexpected Execution Error from call to Get_contracts_resources
          fnd_message.set_name('JTF', 'JTF_AM_GENERIC_API_ERROR');
          fnd_message.set_token('P_PROC_NAME','GET_AVAILABLE_RESOURCE');
          fnd_message.set_token('P_API_NAME','JTF_ASSIGN_PUB.GET_CONTRACTS_RESOURCES');
          fnd_msg_pub.add;
          IF (x_return_status = fnd_api.g_ret_sts_error) THEN
              RAISE fnd_api.g_exc_error;
          ELSE
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
      END IF; -- end of x_return_status check




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_AM_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )THEN
        FND_MSG_PUB.Add_Exc_Msg
        (
          G_PKG_NAME,
          l_api_name
        );
      END IF;

      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
       );

 END GET_RESOURCE_AVAILABILITY;

END JTF_ASSIGN_PUB;

/
