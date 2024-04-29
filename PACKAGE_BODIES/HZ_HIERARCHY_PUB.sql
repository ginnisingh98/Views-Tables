--------------------------------------------------------
--  DDL for Package Body HZ_HIERARCHY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_HIERARCHY_PUB" AS
/*$Header: ARHHINSB.pls 120.14.12010000.5 2009/08/11 12:08:10 rgokavar ship $ */

-----------------------------------------
-- declaration of private global varibles
-----------------------------------------

--G_DEBUG             BOOLEAN := FALSE;

TYPE start_date_list is table of date index by binary_integer;
TYPE end_date_list is table of date index by binary_integer;
TYPE parent_child_list is table of VARCHAR2(1) index by binary_integer;

l_bool BOOLEAN;
l_status_owner VARCHAR2(255);
l_table_owner VARCHAR2(255);
l_tmp           VARCHAR2(2000);
l_line_number   NUMBER;

l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHHINSB:HZ_HIERARCHY_PUB ';
l_module        CONSTANT VARCHAR2(30) := 'HIERARCHY_NODE';
l_debug_prefix           VARCHAR2(30) ;

--------------------------------------------------
-- declaration of private procedures and functions
--------------------------------------------------

procedure get_table_owner
is
begin
 l_bool := fnd_installation.GET_APP_INFO('AR',l_status_owner,l_tmp,l_table_owner);
end;

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_create_link(
    p_hierarchy_node_rec      IN     HIERARCHY_NODE_REC_TYPE,
    x_return_status           IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_link(
    p_hierarchy_node_rec      IN     HIERARCHY_NODE_REC_TYPE,
    x_return_status           IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_link_pvt(
    p_hierarchy_node_rec      IN     HIERARCHY_NODE_REC_TYPE
);

-----------------------------------
-- private procedures and functions
-----------------------------------

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   31-Oct-2001    Anupam Bordia       o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
       FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
    THEN
        HZ_UTILITY_V2PUB.enable_debug;
        G_DEBUG := TRUE;
    END IF;

END enable_debug;
*/

/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   31-Oct-2001    Anupam Bordia       o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        HZ_UTILITY_V2PUB.disable_debug;
        G_DEBUG := FALSE;
    END IF;

END disable_debug;
*/


/**
 *  Table sort routine
 **/
PROCEDURE sort (
    p_d1                          in out nocopy start_date_list,
    p_d2                          in out nocopy end_date_list,
    p_pc                          in out nocopy parent_child_list
) IS PRAGMA AUTONOMOUS_TRANSACTION;

    j                             number :=1;

    CURSOR c IS
    SELECT *
    FROM   hz_temp_rel_gt
    ORDER BY date1,date2;

BEGIN

    if l_bool is null or l_bool=false then
      get_table_owner;
      l_line_number := 1;
    end if;

    if l_bool then
      execute immediate  'truncate table '||l_table_owner||'.hz_temp_rel_gt';
      l_line_number := 2;

      forall i in 1..p_d1.count
        insert into hz_temp_rel_gt(date1,date2,pc_flag) values(p_d1(i),p_d2(i),p_pc(i));

      l_line_number := 3;


      open c;
      fetch c bulk collect into p_d1, p_d2, p_pc;
      close c;

      l_line_number := 4;
      commit;
    end if;

END sort;


/**
 *  MAINTAIN SELF NODES PROCEDURE
 **/

procedure maintain_self_node
(    p_node_id            number,
    p_hierarchy_type     varchar2,
    p_table_name         VARCHAR2,
    p_object_type        VARCHAR2,
    p_actual_content_source VARCHAR2
)

is

l_rowid rowid;
l_tp VARCHAR2(1) := 'N';
l_lc VARCHAR2(1) := 'N';
l_upper_date date;
l_lower_date date;
j number :=1;
i number :=1;
process_flag boolean :=true;
l_temp_flag VARCHAR2(1);
l_const number := 1/(24*3600);
l_debug_prefix		       VARCHAR2(30) := '';

l_start_date start_date_list;
l_end_date end_date_list;
l_pc_flag parent_child_list;

-- Bug 7260677
/*
cursor c_dates(p_id number,p_table_name varchar2,p_object_type varchar2,p_hierarchy_type varchar2) is
select effective_start_date,effective_end_date,'P' parent_child_flag
from hz_hierarchy_nodes
where parent_id=p_id
and parent_table_name=p_table_name
and parent_object_type=p_object_type
and hierarchy_type=p_hierarchy_type
and level_number=1
union
select effective_start_date,effective_end_date,'C' parent_child_flag
from hz_hierarchy_nodes
where child_id=p_id
and child_table_name=p_table_name
and child_object_type=p_object_type
and hierarchy_type=p_hierarchy_type
and level_number=1;
*/
cursor c_dates(p_id number,p_table_name varchar2,p_object_type varchar2,p_hierarchy_type varchar2) is
select to_date(to_char(effective_start_date,'dd/mm/yyyy')||'00:00:00','dd/mm/yyyy hh24:mi:ss'),
       to_date(to_char(effective_end_date,  'dd/mm/yyyy')||'23:59:59','dd/mm/yyyy hh24:mi:ss'),
       'P' parent_child_flag
from hz_hierarchy_nodes
where parent_id=p_id
and parent_table_name=p_table_name
and parent_object_type=p_object_type
and hierarchy_type=p_hierarchy_type
and level_number=1
union
select to_date(to_char(effective_start_date,'dd/mm/yyyy')||'00:00:00','dd/mm/yyyy hh24:mi:ss'),
       to_date(to_char(effective_end_date,  'dd/mm/yyyy')||'23:59:59','dd/mm/yyyy hh24:mi:ss'),
       'C' parent_child_flag
from hz_hierarchy_nodes
where child_id=p_id
and child_table_name=p_table_name
and child_object_type=p_object_type
and hierarchy_type=p_hierarchy_type
and level_number=1;
-- End of  Bug 7260677


begin

-- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'maintain_self_node (+) node_id = '||p_node_id||' p_hierarchy_type = '||p_hierarchy_type ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


delete from hz_hierarchy_nodes
where parent_id=p_node_id
and parent_table_name=p_table_name
and parent_object_type=p_object_type
and hierarchy_type=p_hierarchy_type
and level_number=0;

open c_dates(p_node_id,p_table_name,p_object_type,p_hierarchy_type);
fetch c_dates bulk collect into l_start_date,l_end_date,l_pc_flag;
close c_dates;

-- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'l_start_date.count = '||l_start_date.count ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


if l_start_date.count=1
then
-- Since the node is being inserted for the first time in the hierarchy it can
-- just be a parent or a child and cant be both.

  if l_pc_flag(1)='P'
  then l_tp:='Y';
  else l_lc:='Y';
  end if;

  -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_HIERARCHY_NODES_PKG.insert_row (+) l_tp = '||l_tp||' l_lc = '||l_lc ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    HZ_HIERARCHY_NODES_PKG.Insert_Row(
                X_ROWID                      => l_rowid,
                X_HIERARCHY_TYPE             => p_hierarchy_type,
                X_PARENT_ID                  => p_node_id,
                X_PARENT_TABLE_NAME          => p_table_name,
                X_PARENT_OBJECT_TYPE         => p_object_type,
                X_CHILD_ID                   => p_node_id,
                X_CHILD_TABLE_NAME           => p_table_name,
                X_CHILD_OBJECT_TYPE          => p_object_type,
                X_LEVEL_NUMBER               => 0,
                X_TOP_PARENT_FLAG            => l_tp,
                X_LEAF_CHILD_FLAG            => l_lc,
                X_EFFECTIVE_START_DATE       => l_start_date(1),
                X_EFFECTIVE_END_DATE         => l_end_date(1),
                X_STATUS                     => NULL,
                X_RELATIONSHIP_ID            => NULL,
                X_ACTUAL_CONTENT_SOURCE      => p_actual_content_source
            );
else -- multiple nodes present


  -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'before the initial sort ...' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


  l_line_number := 5;

-- sort the nodes
  sort(l_start_date,l_end_date,l_pc_flag);

  -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    for n in 1..l_start_date.count loop
	hz_utility_v2pub.debug(p_message=>'l_start_date = '||l_start_date(n)||' '||
        'l_end_date = '||l_end_date(n)||' '||
        'l_pc_flag = '||l_pc_flag(n),
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    end loop;
    END IF;

  l_line_number := 6;

-- 4 values of pc_flag are possible
-- 'B' indicates that the node is both a child and a parent during a period
-- 'C' indicates that the node is just a child during a period
-- 'P' indicates that the node is just a parent during the period
-- 'D' indicates that the node is not to be inserted.

while (process_flag = true)
  loop

  if l_pc_flag(i)='B'
     and l_end_date(i) between l_start_date(i+1) and l_end_date(i+1)
  then
     l_line_number := 7;

     -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
       hz_utility_v2pub.debug(p_message=> 'l_pc_flag(i) = B' ,
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
    END IF;
     --Bug#8744353
      --When l_pc_flag = 'B' (both) then check next record and if it falls
      --in same date range then make next record flag as 'B'.
      IF ((trunc(l_start_date(i+1)) between trunc(l_start_date(i)) and trunc(l_end_date(i))) and
         (trunc(l_end_date(i+1)) between trunc(l_start_date(i)) and trunc(l_end_date(i))))
      THEN
         l_pc_flag(i+1) := 'B';

              -- Debug info.
              IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                    hz_utility_v2pub.debug(p_message=> 'l_start_date(i+1), l_end_date(i+1) between l_start_date(i), l_end_date(i) ' ,
                          p_prefix=>l_debug_prefix,
                          p_msg_level=>fnd_log.level_procedure);
              END IF;

      ELSE
             l_start_date(i+1):=l_end_date(i);
      END IF;

     if l_start_date.exists(i+2) and l_start_date(i+1)>l_start_date(i+2)
     then
        l_line_number := 8;

        sort(l_start_date,l_end_date,l_pc_flag);

        l_line_number := 9;
     end if;

  elsif l_pc_flag(i)=l_pc_flag(i+1)
      then
        l_line_number := 10;

        -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_pc_flag(i)=l_pc_flag(i+1)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


        if (l_end_date(i) between l_start_date(i+1) and l_end_date(i+1))
        then
           l_line_number := 11;

           l_end_date(i) := l_start_date(i+1);
        elsif l_end_date(i+1)<l_end_date(i)
        then
           l_line_number := 12;

           l_start_date(i+1):=l_start_date(i); l_end_date(i+1) := l_end_date(i);
           l_pc_flag(i+1):=l_pc_flag(i); l_pc_flag(i):='D';
        end if;
  elsif (l_start_date(i)=l_start_date(i+1)
         and l_end_date(i)=l_end_date(i+1)
         and l_pc_flag(i)<>l_pc_flag(i+1))
         then
              l_line_number := 13;

              l_pc_flag(i):='D';
              l_pc_flag(i+1) :='B';
  elsif (l_end_date(i) between l_start_date(i+1) and l_end_date(i+1))
      OR (l_end_date(i)>l_end_date(i+1))
      then
        l_line_number := 14;

        -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_end_date(i) between ...' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


        if l_end_date(i+1)>l_end_date(i)
        then l_upper_date:=l_end_date(i+1); l_lower_date:=l_end_date(i); l_temp_flag:=l_pc_flag(i+1);
        else l_upper_date:=l_end_date(i); l_lower_date:=l_end_date(i+1); l_temp_flag:=l_pc_flag(i);
        end if;

        j:=i+2;

        l_end_date(i):=l_start_date(i+1);
        l_end_date(i+1) := l_lower_date; l_pc_flag(i+1):='B';

        l_line_number := 15;

        if l_start_date.exists(i+2) then
        for k in reverse j..l_end_date.last
        loop
            l_start_date(k+1):=l_start_date(k);
            l_end_date(k+1):=l_end_date(k);
            l_pc_flag(k+1):=l_pc_flag(k);
        end loop;
        end if;

        l_line_number := 16;

        l_start_date(i+2):=l_lower_date;
        l_end_Date(i+2) := l_upper_Date;
        l_pc_flag(i+2) := l_temp_flag;

        if l_start_date.exists(i+3) then
        if(l_start_date(i+3)<l_start_date(i+2) )
           or (l_start_date(i+3)=l_start_date(i+2)
               and l_end_date(i+3)<l_end_date(i+2))
        then
          sort(l_start_date,l_end_date,l_pc_flag);
        end if;
        end if;

        l_line_number := 17;
   end if;
   i:=i+1;
   if (i=l_start_date.count) then process_flag:=false;
   end if;
   end loop;

   l_line_number := 18;

   for i in l_start_date.first..l_start_date.last
   loop
   if (l_pc_flag(i)<>'D' and l_start_date(i)<>l_end_date(i))
   then
    l_tp:='N'; l_lc:='N';

    if l_pc_flag(i)='P'
    then l_tp:='Y';
    elsif l_pc_flag(i)='C'
    then  l_lc:='Y';
    end if;

    l_line_number := 19;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'HZ_HIERARCHY_NODES_PKG.insert_row (+) l_tp = '||l_tp||' l_lc = '||l_lc,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


    HZ_HIERARCHY_NODES_PKG.Insert_Row(
                X_ROWID                      => l_rowid,
                X_HIERARCHY_TYPE             => p_hierarchy_type,
                X_PARENT_ID                  => p_node_id,
                X_PARENT_TABLE_NAME          => p_table_name,
                X_PARENT_OBJECT_TYPE         => p_object_type,
                X_CHILD_ID                   => p_node_id,
                X_CHILD_TABLE_NAME           => p_table_name,
                X_CHILD_OBJECT_TYPE          => p_object_type,
                X_LEVEL_NUMBER               => 0,
                X_TOP_PARENT_FLAG            => l_tp,
                X_LEAF_CHILD_FLAG            => l_lc,
                X_EFFECTIVE_START_DATE       => l_start_date(i)+l_const,
                X_EFFECTIVE_END_DATE         => l_end_date(i),
                X_STATUS                     => NULL,
                X_RELATIONSHIP_ID            => NULL,
                X_ACTUAL_CONTENT_SOURCE      => p_actual_content_source
            );
   end if;
   end loop;

end if;

-- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'maintain_self_node (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

end maintain_self_node;

/*===========================================================================+
 | PROCEDURE
 |              do_create_link
 |
 | DESCRIPTION
 |              Creates hierarchial link
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |          IN/ OUT:
 |                    p_hierarchy_node_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_link(
    p_hierarchy_node_rec                IN     HIERARCHY_NODE_REC_TYPE,
    x_return_status                     IN OUT NOCOPY VARCHAR2
) IS
    tmp_child_id                        NUMBER(15);
    tmp_child_level_number              NUMBER(3);
    tmp_parent_id                       NUMBER(15);
    tmp_parent_level_number             NUMBER(3);
    tmp_top_parent_flag                 VARCHAR2(1);
    tmp_leaf_child_flag                 VARCHAR2(1);
    parent_exists                       NUMBER(5);
    child_exists                        NUMBER(5);
    l_level_number                      NUMBER := 0;
    l_top_parent_flag                   VARCHAR2(1) := 'N';
    l_leaf_child_flag                   VARCHAR2(1) := 'N';
    l_effective_start_date              DATE := p_hierarchy_node_rec.effective_start_date;
    l_effective_end_date                DATE := p_hierarchy_node_rec.effective_end_date;
    l_effective_start_date_tp           DATE;
    l_effective_end_date_tp             DATE;
    l_effective_start_date_lc           DATE;
    l_effective_end_date_lc             DATE;
    l_temp_start_date                   DATE;
    l_temp_end_date                     DATE;
    l_status                            VARCHAR2(1) := p_hierarchy_node_rec.status;
    l_relationship_id                   NUMBER;
    l_parent_in_hierarchy               VARCHAR2(1);
    l_child_in_hierarchy                VARCHAR2(1);
    l_parent_is_top_parent              VARCHAR2(1) := 'Y';
    l_child_is_top_parent               VARCHAR2(1) := 'N';
    l_parent_is_leaf_child              VARCHAR2(1) := 'N';
    l_child_is_leaf_child               VARCHAR2(1) := 'Y';
    l_return                            NUMBER;
    l_dummy                             VARCHAR2(1);
    l_direct_link_rowid                 ROWID;
    l_rowid                             ROWID;
    l_parent_sr_rowid                   ROWID;
    l_child_sr_rowid                    ROWID;

    l_existing_start_date               DATE;
    l_existing_end_date                 DATE;

    -- this cursor retrieves all the parents of the parent node passed.
    -- the or condition for the where clause is such to cover any parent
    -- existance with the current relationships time period and any parent's
    -- time period.
    CURSOR c_get_all_parents IS
        SELECT UNIQUE PARENT_ID,
               PARENT_TABLE_NAME,
               PARENT_OBJECT_TYPE,
               LEVEL_NUMBER
/*
               TOP_PARENT_FLAG,
               EFFECTIVE_START_DATE,
               EFFECTIVE_END_DATE
*/
        FROM   HZ_HIERARCHY_NODES
        WHERE  CHILD_ID = p_hierarchy_node_rec.parent_id
        AND    CHILD_TABLE_NAME = p_hierarchy_node_rec.parent_table_name
        AND    CHILD_OBJECT_TYPE = p_hierarchy_node_rec.parent_object_type
        AND    HIERARCHY_TYPE = p_hierarchy_node_rec.hierarchy_type

        AND    (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                OR
                l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               )
        AND    NVL(status,'A') = 'A'
        ORDER BY LEVEL_NUMBER ASC;

    r_get_all_parents     c_get_all_parents%ROWTYPE;

    -- this cursor retrieves all the children of the child node passed.
    -- the or condition for the where clause is such to cover any parent
    -- existance with the current relationships time period and any parent's
    -- time period.
    CURSOR c_get_all_children IS
        SELECT UNIQUE CHILD_ID,
               CHILD_TABLE_NAME,
               CHILD_OBJECT_TYPE,
               LEVEL_NUMBER
/*
               LEAF_CHILD_FLAG,
               EFFECTIVE_START_DATE,
               EFFECTIVE_END_DATE
*/
        FROM   HZ_HIERARCHY_NODES
        WHERE  PARENT_ID = p_hierarchy_node_rec.child_id
        AND    PARENT_TABLE_NAME = p_hierarchy_node_rec.child_table_name
        AND    PARENT_OBJECT_TYPE = p_hierarchy_node_rec.child_object_type
        AND    HIERARCHY_TYPE = p_hierarchy_node_rec.hierarchy_type

        AND    (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                OR
                l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               )
        AND    NVL(status,'A') = 'A'
        ORDER BY LEVEL_NUMBER ASC;

    r_get_all_children     c_get_all_children%ROWTYPE;

    -- this cursor returns the immediate parent information
    CURSOR c_immediate_parent (p_child_id NUMBER,
                               p_child_table_name VARCHAR2,
                               p_child_object_type VARCHAR2) IS
        SELECT PARENT_ID,
               PARENT_TABLE_NAME,
               PARENT_OBJECT_TYPE,
               EFFECTIVE_START_DATE,
               EFFECTIVE_END_DATE
        FROM   HZ_HIERARCHY_NODES a
        WHERE  CHILD_ID = p_child_id
        AND    CHILD_TABLE_NAME = p_child_table_name
        AND    CHILD_OBJECT_TYPE = p_child_object_type
        AND    HIERARCHY_TYPE = p_hierarchy_node_rec.hierarchy_type
        AND    (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                OR
                l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               )
        AND    NVL(status,'A') = 'A'
        AND    LEVEL_NUMBER = 1
        -- Fix for Bug 5662272
        -- Filter out end dated records, if there is a future record existing
        AND    NOT EXISTS (SELECT NULL FROM HZ_HIERARCHY_NODES b
                           WHERE b.PARENT_ID = a.PARENT_ID
                           AND   b.PARENT_TABLE_NAME = a.PARENT_TABLE_NAME
                           AND   b.PARENT_OBJECT_TYPE = a.PARENT_OBJECT_TYPE
                           AND   b.CHILD_ID = a.CHILD_ID
                           AND   b.CHILD_TABLE_NAME = a.CHILD_TABLE_NAME
                           AND   b.CHILD_OBJECT_TYPE = a.CHILD_OBJECT_TYPE
                           AND   b.HIERARCHY_TYPE = a.HIERARCHY_TYPE
                           AND   b.LEVEL_NUMBER = a.LEVEL_NUMBER
                           AND   NVL(b.status,'A') = 'A'
                           AND   b.EFFECTIVE_END_DATE > a.EFFECTIVE_END_DATE
               )
        ORDER BY RELATIONSHIP_ID DESC;

    r_immediate_parent     c_immediate_parent%ROWTYPE;

    CURSOR c_get_link_info (p_parent_id NUMBER,
                            p_parent_table_name VARCHAR2,
                            p_parent_object_type VARCHAR2,
                            p_child_id NUMBER,
                            p_child_table_name VARCHAR2,
                            p_child_object_type VARCHAR2) IS
        SELECT LEVEL_NUMBER,
               TOP_PARENT_FLAG,
               LEAF_CHILD_FLAG,
               EFFECTIVE_START_DATE,
               EFFECTIVE_END_DATE
        FROM   HZ_HIERARCHY_NODES a
        WHERE  PARENT_ID = p_parent_id
        AND    PARENT_TABLE_NAME = p_parent_table_name
        AND    PARENT_OBJECT_TYPE = p_parent_object_type
        AND    CHILD_ID = p_child_id
        AND    CHILD_TABLE_NAME = p_child_table_name
        AND    CHILD_OBJECT_TYPE = p_child_object_type
        AND    (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                OR
                l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               )
        AND    NVL(status,'A') = 'A'
        -- Fix for Bug 5662272
        -- For the same level, if there are 2 records, then take the latest one and filter out
        -- record with lower end date. That record may have been end dated and a new one is created
        AND    NOT EXISTS (SELECT NULL FROM HZ_HIERARCHY_NODES b
                           WHERE b.PARENT_ID = a.PARENT_ID
                           AND   b.PARENT_TABLE_NAME = a.PARENT_TABLE_NAME
                           AND   b.PARENT_OBJECT_TYPE = a.PARENT_OBJECT_TYPE
                           AND   b.CHILD_ID = a.CHILD_ID
                           AND   b.CHILD_TABLE_NAME = a.CHILD_TABLE_NAME
                           AND   b.CHILD_OBJECT_TYPE = a.CHILD_OBJECT_TYPE
                           AND   b.HIERARCHY_TYPE = a.HIERARCHY_TYPE
                           AND   b.LEVEL_NUMBER = a.LEVEL_NUMBER
                           AND   NVL(b.status,'A') = 'A'
                           AND   b.EFFECTIVE_END_DATE > a.EFFECTIVE_END_DATE
               )
		;

    r_get_link_info     c_get_link_info%ROWTYPE;

BEGIN

  	  -- Debug info.
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'do_create_link (+)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
      END IF;

    -- when this procedure is called, the request is to incorporate a relation
    -- between AAA and BBB in a hierarchy (defined by relationship type) where
    -- AAA is parent of BBB
    --                AAA (Parent)
    --                 |
    --                 |
    --                 |
    --                \|/
    --                BBB (Child)

    -------------------------
    -- INSERT THE DIRECT LINK
    -------------------------

    -- Insert the direct link between AAA->BBB.
    -- Since no duplicate record will be sent to this API, there is no need to check for the
    -- existance of a record with same parent/child, even if there is one, it will have a
    -- different period of time.
    HZ_HIERARCHY_NODES_PKG.Insert_Row(
        X_ROWID                      => l_direct_link_rowid,
        X_HIERARCHY_TYPE             => p_hierarchy_node_rec.hierarchy_type,
        X_PARENT_ID                  => p_hierarchy_node_rec.parent_id,
        X_PARENT_TABLE_NAME          => p_hierarchy_node_rec.parent_table_name,
        X_PARENT_OBJECT_TYPE         => p_hierarchy_node_rec.parent_object_type,
        X_CHILD_ID                   => p_hierarchy_node_rec.child_id,
        X_CHILD_TABLE_NAME           => p_hierarchy_node_rec.child_table_name,
        X_CHILD_OBJECT_TYPE          => p_hierarchy_node_rec.child_object_type,
        X_LEVEL_NUMBER               => 1,
        X_TOP_PARENT_FLAG            => NULL,
        X_LEAF_CHILD_FLAG            => NULL,
        X_EFFECTIVE_START_DATE       => p_hierarchy_node_rec.effective_start_date,
        X_EFFECTIVE_END_DATE         => p_hierarchy_node_rec.effective_end_date,
        X_STATUS                     => p_hierarchy_node_rec.status,
        X_RELATIONSHIP_ID            => p_hierarchy_node_rec.relationship_id,
        X_ACTUAL_CONTENT_SOURCE      => p_hierarchy_node_rec.actual_content_source
    );

    ---------------------------------
    -- PARENT'S SELF NODE MAINTENANCE
    ---------------------------------
	-- Debug info.
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'maintain_self_node for Parent(+)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
     END IF;

    maintain_self_node (
        p_node_id            => p_hierarchy_node_rec.parent_id,
        p_hierarchy_type     => p_hierarchy_node_rec.hierarchy_type,
        p_table_name         => p_hierarchy_node_rec.parent_table_name,
        p_object_type        => p_hierarchy_node_rec.parent_object_type,
        p_actual_content_source => p_hierarchy_node_rec.actual_content_source
    );

	-- Debug info.
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'maintain_self_node for Parent(-)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
     END IF;

    --------------------------------
    -- CHILD'S SELF NODE MAINTENANCE
    --------------------------------
	-- Debug info.
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'maintain_self_node for Child(+)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
     END IF;

    maintain_self_node (
        p_node_id            => p_hierarchy_node_rec.child_id,
        p_hierarchy_type     => p_hierarchy_node_rec.hierarchy_type,
        p_table_name         => p_hierarchy_node_rec.child_table_name,
        p_object_type        => p_hierarchy_node_rec.child_object_type,
        p_actual_content_source => p_hierarchy_node_rec.actual_content_source
    );

	-- Debug info.
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'maintain_self_node for child (-)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
     END IF;

    -- Bug 4902909.
    -- we'll get the parents and children of the relationship,
    -- based on the existing start dates.
    -- This is because, if the new dates are used, the data will be picked up
    -- in to the cursor only if there is some overlap between the old and new dates.
    -- If the old and new date ranges are mutually exclusive, then the where
    -- used for the cursors will prevent any data from being picked up.
    -- Also the relationship API will not pass the existing dates.
    -- these are picked up from the HZ_HIERARCHY_NODES table itself,
    -- from the level 1 recordusing the parent_id, child_i and relationship_id
    -- passed through the  p_hierarchy_node_rec.
    -- once obtained, these current dates will be used to pickup data in to the cursors.

    -- fetch existing effective start and end dates for relationship id
    BEGIN
      SELECT EFFECTIVE_START_DATE, EFFECTIVE_END_DATE
      INTO   l_existing_start_date, l_existing_end_date
      FROM   HZ_HIERARCHY_NODES
      WHERE  PARENT_ID = p_hierarchy_node_rec.parent_id
        AND  CHILD_ID = p_hierarchy_node_rec.child_id
        AND  LEVEL_NUMBER = 1
        AND  RELATIONSHIP_ID = p_hierarchy_node_rec.relationship_id ;
    EXCEPTION WHEN OTHERS THEN
      l_existing_start_date := p_hierarchy_node_rec.effective_start_date;
      l_existing_end_date   := p_hierarchy_node_rec.effective_end_date;

  	  -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Local Exception:'||SQLERRM,
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
      END IF;

    END;


    --------------------------------
    -- MAINTENANCE OF INDIRECT LINKS
    --------------------------------
	-- Debug info.
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'maintain indirect links (+)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
     END IF;

    -- first we'll get all the parents of AAA (this will include AAA itself)
    OPEN c_get_all_parents;
    FETCH c_get_all_parents INTO r_get_all_parents;


    WHILE c_get_all_parents%FOUND
    -- at this point we have got at least one parent for AAA, let's call it XXX
    LOOP
        -- we open the cursor to get all the children of BBB (this will include BBB itself)
        OPEN c_get_all_children;
        FETCH c_get_all_children INTO r_get_all_children;

        WHILE c_get_all_children%FOUND
        -- let's call it YYY
        LOOP
            -- we need to create a link XXX --> YYY
            -- get the immediate parent of YYY, let's call it III
            OPEN c_immediate_parent (r_get_all_children.child_id,
                                     r_get_all_children.child_table_name,
                                     r_get_all_children.child_object_type);
            FETCH c_immediate_parent INTO r_immediate_parent;
            CLOSE c_immediate_parent;

            -- get the link information between XXX and III
            OPEN c_get_link_info (r_get_all_parents.parent_id,
                                  r_get_all_parents.parent_table_name,
                                  r_get_all_parents.parent_object_type,
                                  r_immediate_parent.parent_id,
                                  r_immediate_parent.parent_table_name,
                                  r_immediate_parent.parent_object_type);
            FETCH c_get_link_info INTO r_get_link_info;
            CLOSE c_get_link_info;

            -- we need to find out
            --     level : level of XXX->YYY is level of XXX->III plus 1
            l_level_number := r_get_link_info.level_number + 1;

            --     effective dates : that would be
            --                       1. start date later of the two start dates of XXX->III and III->YYY
            --                       2. end date earlier of the two end dates of XXX->III and III->YYY
            IF r_get_link_info.effective_start_date <= r_immediate_parent.effective_start_date THEN
                l_effective_start_date := r_immediate_parent.effective_start_date;
            ELSE
                l_effective_start_date := r_get_link_info.effective_start_date;
            END IF;

            IF r_get_link_info.effective_end_date <= r_immediate_parent.effective_end_date THEN
                l_effective_end_date := r_get_link_info.effective_end_date;
            ELSE
                l_effective_end_date := r_immediate_parent.effective_end_date;
            END IF;

            --     top parent : top parent status of XXX remains as it is
            -- l_top_parent_flag := r_get_all_parents.top_parent_flag;

            IF l_level_number > 1 THEN
            -- now insert the XXX->YYY link
                HZ_HIERARCHY_NODES_PKG.Insert_Row(
                    X_ROWID                      => l_rowid,
                    X_HIERARCHY_TYPE             => p_hierarchy_node_rec.hierarchy_type,
                    X_PARENT_ID                  => r_get_all_parents.parent_id,
                    X_PARENT_TABLE_NAME          => r_get_all_parents.parent_table_name,
                    X_PARENT_OBJECT_TYPE         => r_get_all_parents.parent_object_type,
                    X_CHILD_ID                   => r_get_all_children.child_id,
                    X_CHILD_TABLE_NAME           => r_get_all_children.child_table_name,
                    X_CHILD_OBJECT_TYPE          => r_get_all_children.child_object_type,
                    X_LEVEL_NUMBER               => l_level_number,
                    X_TOP_PARENT_FLAG            => NULL,
                    X_LEAF_CHILD_FLAG            => NULL,
                    X_EFFECTIVE_START_DATE       => l_effective_start_date,
                    X_EFFECTIVE_END_DATE         => l_effective_end_date,
                    X_STATUS                     => NULL,
                    X_RELATIONSHIP_ID            => NULL,
                    X_ACTUAL_CONTENT_SOURCE      => p_hierarchy_node_rec.actual_content_source
                );
            END IF;

            -- get the next child
            FETCH c_get_all_children INTO r_get_all_children;
        END LOOP;
        CLOSE c_get_all_children;
        -- get the next parent of AAA
        FETCH c_get_all_parents INTO r_get_all_parents;

    END LOOP;
    CLOSE c_get_all_parents;


	-- Debug info.
     IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'maintain indirect links (-)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
     END IF;

    l_temp_start_date := l_effective_start_date_lc;
    l_temp_end_date := l_effective_end_date_lc;

  	  -- Debug info.
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'do_create_link (-)',
	                           p_prefix=> '',
	 		                   p_msg_level=>fnd_log.level_procedure);
      END IF;

END do_create_link;

/*------------------------------------------------------------------------------+
 Created By Nishant on 03-Apr-2006 for Bug 4662744. Modified logic of
 Do_update_link procedure to traverse the tree recursively to figure out parents
 at each step and then update the hierarchy nodes dates
------------------------------------------------------------------------------+*/
PROCEDURE do_update_link_pvt(
    p_hierarchy_node_rec      IN     HIERARCHY_NODE_REC_TYPE
) IS

  l_debug_prefix		CONSTANT VARCHAR2(30) := '';

  l_parent_id            NUMBER;
  l_parent_type          VARCHAR2(100);
  l_child_id             NUMBER;
  l_child_type           VARCHAR2(100);
  l_level                NUMBER;
  l_hierarchy_type       VARCHAR2(30);
  l_parent_table         VARCHAR2(30);
  l_child_table          VARCHAR2(30);

    -- Bug 4902909.
    -- we'll get the parents and children of the relationship,
    -- based on the existing start dates.
    -- This is because, if the new dates are used, the data will be picked up
    -- in to the cursor only if there is some overlap between the old and new dates.
    -- If the old and new date ranges are mutually exclusive, then the where
    -- used for the cursors will prevent any data from being picked up.
    -- Also the relationship API will not pass the existing dates.
    -- these are picked up from the HZ_HIERARCHY_NODES table itself,
    -- from the level 1 recordusing the parent_id, child_i and relationship_id
    -- passed through the  p_hierarchy_node_rec.
    -- once obtained, these current dates will be used to pickup data in to the cursors.
  l_existing_start_date               DATE;
  l_existing_end_date                 DATE;
  l_LAST_UPDATED_BY                   NUMBER;
  l_LAST_UPDATE_DATE                  DATE;
  l_LAST_UPDATE_LOGIN                 NUMBER;

  TYPE parent_list_rec_type IS RECORD
  ( parent_id      NUMBER,
    parent_type    VARCHAR2(100),
    parent_table   VARCHAR2(100),
    level_number   NUMBER
  );

  TYPE parent_list_tbl_type IS TABLE OF parent_list_rec_type INDEX BY BINARY_INTEGER;

  parent_list_tbl parent_list_tbl_type;

    CURSOR c_get_all_children (ll_child_id NUMBER, ll_child_object_type IN VARCHAR2,
	                           ll_child_table IN VARCHAR2)
	IS
        SELECT CHILD_ID,
               CHILD_OBJECT_TYPE,
               CHILD_TABLE_NAME
        FROM   HZ_HIERARCHY_NODES
        WHERE  PARENT_ID = ll_child_id
        AND    PARENT_TABLE_NAME = ll_child_table
        AND    PARENT_OBJECT_TYPE = ll_child_object_type
        AND    HIERARCHY_TYPE = l_hierarchy_type
        AND    (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                OR
                l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               )
        AND    NVL(status,'A') = 'A'
        ORDER BY LEVEL_NUMBER ASC;

     CURSOR c_match_par_child (l_parent_id IN NUMBER,l_parent_object_type IN VARCHAR2,
                               l_parent_table IN VARCHAR2,
		                       l_child_id IN NUMBER, l_child_object_type IN VARCHAR2,
							   l_child_table IN VARCHAR2)
		IS
        SELECT PARENT_ID, PARENT_OBJECT_TYPE, CHILD_ID, CHILD_OBJECT_TYPE, rowid
        FROM  HZ_HIERARCHY_NODES a
        WHERE PARENT_ID = l_parent_id
        AND   PARENT_TABLE_NAME = l_parent_table
        AND   PARENT_OBJECT_TYPE = l_parent_object_type
        AND   CHILD_ID = l_child_id
        AND   CHILD_TABLE_NAME = l_child_table
        AND   CHILD_OBJECT_TYPE = l_child_object_type
        AND   HIERARCHY_TYPE = l_hierarchy_type
        AND   (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
               OR
               EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
               OR
               l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               OR
               l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
              )
        AND   NVL(status,'A') = 'A'
        -- Fix for Bug 5662272
        -- Here problem is, it will pick up any 1 record in random and update end date for that
        -- This way it may inactivae end dated record and leave active record unchanged.
        -- Change it pick up the records for which start date and end date for level 1 relationship
        -- matches (most likely that will be the date for this link also.). If No such record
        -- exists, then pick up the greatest effective_end_date rec (most linkely will be the active one)
        -- and execute cursor only once
        AND   NOT  EXISTS (SELECT NULL FROM HZ_HIERARCHY_NODES b
                           WHERE b.PARENT_ID = a.PARENT_ID
                           AND   b.PARENT_TABLE_NAME = a.PARENT_TABLE_NAME
                           AND   b.PARENT_OBJECT_TYPE = a.PARENT_OBJECT_TYPE
                           AND   b.CHILD_ID = a.CHILD_ID
                           AND   b.CHILD_TABLE_NAME = a.CHILD_TABLE_NAME
                           AND   b.CHILD_OBJECT_TYPE = a.CHILD_OBJECT_TYPE
                           AND   b.HIERARCHY_TYPE = a.HIERARCHY_TYPE
                           AND   b.LEVEL_NUMBER = a.LEVEL_NUMBER
                           AND   NVL(b.status,'A') = 'A'
                           AND   b.EFFECTIVE_START_DATE = l_existing_start_date
                           AND   b.EFFECTIVE_END_DATE = l_existing_end_date
                           AND   a.ROWID <> b.ROWID
              )
      -- Move this condition inside cursor loop
      --AND  ROWNUM = 1
      ORDER BY effective_end_date desc;


	PROCEDURE do_recursive_parent_fetch (p_child_id IN NUMBER,
	                                     p_child_type IN VARCHAR2,
	                                     p_child_table IN VARCHAR2,
	                                     p_child_level IN NUMBER) IS


	    CURSOR get_parent_id_cur (l_child_id IN NUMBER, l_child_object_type IN VARCHAR2,
		                          l_child_table IN VARCHAR2) IS
	    SELECT parent_id, parent_object_type, parent_table_name
	    FROM   hz_hierarchy_nodes
	    WHERE  hierarchy_type = l_hierarchy_type
	    AND    child_table_name = l_child_table
	    AND    child_object_type = l_child_object_type
	    AND    child_id = l_child_id
	    AND    level_number = 1
	    AND    SYSDATE+0.0001 BETWEEN effective_start_date AND effective_end_date
        AND    NVL(status,'A') = 'A'
	    ;

	  l_parent_id          NUMBER;
	  l_parent_type        VARCHAR2(100);
	  l_parent_level       NUMBER;
	  l_parent_table       VARCHAR2(100);
	  l_counter            NUMBER;
	BEGIN
      -- FND Logging for debug purpose
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Input : '||p_child_id||' : '||p_child_type||' : '||p_child_level,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

	  OPEN get_parent_id_cur (p_child_id, p_child_type, p_child_table);

         -- FND Logging for debug purpose
    	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Open get_parent_id_cur for id : '||p_child_id,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
         END IF;

	    LOOP
	      FETCH get_parent_id_cur INTO l_parent_id, l_parent_type, l_parent_table;
	      IF (get_parent_id_cur%FOUND) THEN

	        l_counter := parent_list_tbl.COUNT+1;
	        parent_list_tbl(l_counter).parent_id := l_parent_id;
	        parent_list_tbl(l_counter).parent_type := l_parent_type;
	        parent_list_tbl(l_counter).parent_table := l_parent_table;
	        parent_list_tbl(l_counter).level_number := p_child_level;

            -- Fix for Bug 5204188 (Parent Id and Child Id same at level =1, so it goes
			-- infinite recursion). Break out if parent and child id are same.
			IF (p_child_id = l_parent_id) THEN
               -- FND Logging for debug purpose
           	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  hz_utility_v2pub.debug
	               (p_message      => 'Exit loop because parent child matched for level 1',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		           );
               END IF;

			   EXIT;

			ELSE

			   -- FND Logging for debug purpose
           	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  hz_utility_v2pub.debug
	               (p_message      => 'Fetched for recursion : '||l_parent_id||' : '||l_parent_type||' : '||TO_CHAR(TO_NUMBER(p_child_level+1)),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		           );
               END IF;

			  do_recursive_parent_fetch(l_parent_id, l_parent_type,l_parent_table, p_child_level+1);
            END IF;

	      ELSE

			 -- FND Logging for debug purpose
           	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  hz_utility_v2pub.debug
	               (p_message      => 'Exit Loop...',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		           );
             END IF;

	        EXIT;
	      END IF;

	    END LOOP;

  	    -- FND Logging for debug purpose
       	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              hz_utility_v2pub.debug
               (p_message      => 'Close get_parent_id_cur for id : '||p_child_id,
	           p_prefix        => l_debug_prefix,
	           p_msg_level     => fnd_log.level_statement,
	           p_module_prefix => l_module_prefix,
	           p_module        => l_module
	           );
        END IF;

	  CLOSE get_parent_id_cur;

	END do_recursive_parent_fetch;

BEGIN
  -- Debug info.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     hz_utility_v2pub.debug(p_message=>'do_update_link_pvt (+)',
	                       p_prefix=>l_debug_prefix,
	 		               p_msg_level=>fnd_log.level_procedure);
  END IF;

  -- initialize variables
  l_parent_id           := p_hierarchy_node_rec.parent_id;
  l_parent_type         := p_hierarchy_node_rec.parent_object_type;
  l_child_id            := p_hierarchy_node_rec.child_id;
  l_child_type          := p_hierarchy_node_rec.child_object_type;
  l_level               := 1;
  l_hierarchy_type      := p_hierarchy_node_rec.hierarchy_type;
  l_parent_table        := p_hierarchy_node_rec.parent_table_name;
  l_child_table         := p_hierarchy_node_rec.child_table_name;

  l_LAST_UPDATED_BY     := HZ_UTILITY_V2PUB.last_updated_by;
  l_LAST_UPDATE_DATE    := HZ_UTILITY_V2PUB.last_update_date;
  l_LAST_UPDATE_LOGIN   := HZ_UTILITY_V2PUB.last_update_login;


  -- fetch existing effective start and end dates for relationship id
  BEGIN
    SELECT EFFECTIVE_START_DATE,EFFECTIVE_END_DATE
    INTO   l_existing_start_date,l_existing_end_date
    FROM   HZ_HIERARCHY_NODES
    WHERE  PARENT_ID = p_hierarchy_node_rec.parent_id
      AND  CHILD_ID = p_hierarchy_node_rec.child_id
      AND  LEVEL_NUMBER = 1
      AND  RELATIONSHIP_ID = p_hierarchy_node_rec.relationship_id ;
  EXCEPTION WHEN OTHERS THEN
    l_existing_start_date := p_hierarchy_node_rec.effective_start_date;
    l_existing_end_date   := p_hierarchy_node_rec.effective_end_date;

	-- Debug info.
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'Local Exception:'||SQLERRM,
	                       p_prefix=>l_debug_prefix,
	 		               p_msg_level=>fnd_log.level_procedure);
    END IF;

  END;

  -- Add self record for parent
  parent_list_tbl(1).parent_id    := l_parent_id;
  parent_list_tbl(1).parent_type  := l_parent_type;
  parent_list_tbl(1).parent_table  := l_parent_table;
  parent_list_tbl(1).level_number := 0;

  -- Debug info.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_recursive_parent_fetch (+)',
	                       p_prefix=>l_debug_prefix,
	 		               p_msg_level=>fnd_log.level_procedure);
  END IF;

  do_recursive_parent_fetch(l_parent_id, l_parent_type, l_parent_table, l_level);

  -- Debug info.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_recursive_parent_fetch (-)',
	                       p_prefix=>l_debug_prefix,
	 		               p_msg_level=>fnd_log.level_procedure);
  END IF;

  -- dbms_output.put_line('Table data:');
  IF (parent_list_tbl IS NOT NULL) THEN
    IF (parent_list_tbl.COUNT > 0) THEN
      FOR i IN parent_list_tbl.FIRST..parent_list_tbl.LAST LOOP
      /*  dbms_output.put_line(i||':'||parent_list_tbl(i).parent_id
		                      ||':'||parent_list_tbl(i).parent_type
							  ||':'||parent_list_tbl(i).level_number);
		*/
		-- put the child cursor here
		FOR c_child_rec IN c_get_all_children (l_child_id, l_child_type, l_child_table) LOOP
           FOR c_par_child_rec IN c_match_par_child (parent_list_tbl(i).parent_id, parent_list_tbl(i).parent_type,
		                          parent_list_tbl(i).parent_table,
		                          c_child_rec.child_id, c_child_rec.CHILD_OBJECT_TYPE, c_child_rec.CHILD_TABLE_NAME
								  ) LOOP
		     /* dbms_output.put_line(c_par_child_rec.parent_id||':'||c_par_child_rec.parent_object_type||':'||
			                      c_par_child_rec.child_id||':'||c_par_child_rec.child_object_type||':'||
								  c_par_child_rec.rowid);
			 */
              UPDATE HZ_HIERARCHY_NODES
              SET EFFECTIVE_START_DATE = NVL(p_hierarchy_node_rec.effective_start_date, EFFECTIVE_START_DATE),
                  EFFECTIVE_END_DATE = NVL(p_hierarchy_node_rec.effective_end_date, EFFECTIVE_END_DATE),
                  -- added for Bug 5662272 (This will update Status values for I which help in
				  -- eleminating deleted rows from all the cursors
                  STATUS = NVL(p_hierarchy_node_rec.status, STATUS),
                  LAST_UPDATED_BY = l_last_updated_by,
  		          LAST_UPDATE_DATE = l_last_update_date,
                  LAST_UPDATE_LOGIN = l_last_update_login
              WHERE ROWID = c_par_child_rec.ROWID;

			  -- exit after 1 execution for each parent child pair for 1 level
			  -- proviously rownum = 1 logic in cursor but because of sorting req. (latest rec)
			  -- moved 1 rec logic here (Fix for Bug 5662272)
			  EXIT;

		   END LOOP;
		END LOOP;
      END LOOP;
    END IF;
  END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_link_pvt (-)',
	                       p_prefix=>l_debug_prefix,
	 		               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_link_pvt;
------------------------------------------------------------------------------+

/*===========================================================================+
 | PROCEDURE
 |              do_update_link
 |
 | DESCRIPTION
 |              updates hierarchial relationship between two nodes and corrosponding links.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_hierarchy_node_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_link(
    p_hierarchy_node_rec                IN     HIERARCHY_NODE_REC_TYPE,
    x_return_status                     IN OUT NOCOPY VARCHAR2
) IS
/*  -- Moved below logic into procedure do_update_link_pvt for Bug 4662744 (Nishant 30-Mar-2006)
    -- End dating of hierarchy in case of multiple parents was not correct

    -- Bug 4902909.
    -- we'll get the parents and children of the relationship,
    -- based on the existing start dates.
    -- This is because, if the new dates are used, the data will be picked up
    -- in to the cursor only if there is some overlap between the old and new dates.
    -- If the old and new date ranges are mutually exclusive, then the where
    -- used for the cursors will prevent any data from being picked up.
    -- Also the relationship API will not pass the existing dates.
    -- these are picked up from the HZ_HIERARCHY_NODES table itself,
    -- from the level 1 recordusing the parent_id, child_i and relationship_id
    -- passed through the  p_hierarchy_node_rec.
    -- once obtained, these current dates will be used to pickup data in to the cursors.
    l_existing_start_date               DATE;
    l_existing_end_date                 DATE;
    -- this cursor retrieves all the parents of the parent node passed.
    -- the or condition for the where clause is such to cover any parent
    -- existance with the current relationships time period and any parent's
    -- time period.
    CURSOR c_get_all_parents IS
        SELECT PARENT_ID,
               PARENT_TABLE_NAME,
               PARENT_OBJECT_TYPE,
               LEVEL_NUMBER,
               TOP_PARENT_FLAG,
               EFFECTIVE_START_DATE,
               EFFECTIVE_END_DATE
        FROM   HZ_HIERARCHY_NODES
        WHERE  CHILD_ID = p_hierarchy_node_rec.parent_id
        AND    CHILD_TABLE_NAME = p_hierarchy_node_rec.parent_table_name
        AND    CHILD_OBJECT_TYPE = p_hierarchy_node_rec.parent_object_type
        AND    HIERARCHY_TYPE = p_hierarchy_node_rec.hierarchy_type
        AND    (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                OR
                l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               )
        -- AND    NVL(RELATIONSHIP_ID, p_hierarchy_node_rec.relationship_id) = p_hierarchy_node_rec.relationship_id
        ORDER BY LEVEL_NUMBER ASC;

    r_get_all_parents     c_get_all_parents%ROWTYPE;

    -- this cursor retrieves all the children of the child node passed.
    -- the or condition for the where clause is such to cover any parent
    -- existance with the current relationships time period and any parent's
    -- time period.
    CURSOR c_get_all_children IS
        SELECT CHILD_ID,
               CHILD_TABLE_NAME,
               CHILD_OBJECT_TYPE,
               LEVEL_NUMBER,
               LEAF_CHILD_FLAG,
               EFFECTIVE_START_DATE,
               EFFECTIVE_END_DATE
        FROM   HZ_HIERARCHY_NODES
        WHERE  PARENT_ID = p_hierarchy_node_rec.child_id
        AND    PARENT_TABLE_NAME = p_hierarchy_node_rec.child_table_name
        AND    PARENT_OBJECT_TYPE = p_hierarchy_node_rec.child_object_type
        AND    HIERARCHY_TYPE = p_hierarchy_node_rec.hierarchy_type
        AND    (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                OR
                l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                OR
                l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
               )
        -- AND    NVL(RELATIONSHIP_ID, p_hierarchy_node_rec.relationship_id) = p_hierarchy_node_rec.relationship_id
        ORDER BY LEVEL_NUMBER ASC;

    r_get_all_children     c_get_all_children%ROWTYPE;
    l_child_rec_count_p    NUMBER;
    l_child_rec_count_c    NUMBER;
    l_parent_rec_count_p   NUMBER;
    l_parent_rec_count_c   NUMBER;
*/

BEGIN

/* -- Moved below logic into procedure do_update_link_pvt for Bug 4662744 (Nishant 30-Mar-2006)
   -- End dating of hierarchy in case of multiple parents was not correct

  Select EFFECTIVE_START_DATE,EFFECTIVE_END_DATE into l_existing_start_date,l_existing_end_date
      from HZ_HIERARCHY_NODES
      where PARENT_ID=p_hierarchy_node_rec.parent_id
         AND CHILD_ID=p_hierarchy_node_rec.child_id
         AND LEVEL_NUMBER=1
         AND RELATIONSHIP_ID=p_hierarchy_node_rec.relationship_id ;

    -- let's assume the effective dates of AAA->BBB are being updated
    -- assumption : start_date and end_date is always passed by relationship api

    -------------------
    -- LINK MAINTENANCE
    -------------------

    -- get all the parents of AAA including itself
    OPEN c_get_all_parents;
    FETCH c_get_all_parents INTO r_get_all_parents;

    -- loop through all the parents
    WHILE c_get_all_parents%FOUND
    LOOP
        -- we open the cursor to get all the children of BBB (this will include BBB itself)
        OPEN c_get_all_children;
        FETCH c_get_all_children INTO r_get_all_children;

        WHILE c_get_all_children%FOUND
        -- let's call it YYY
        LOOP
            UPDATE HZ_HIERARCHY_NODES
            SET EFFECTIVE_START_DATE = NVL(p_hierarchy_node_rec.effective_start_date, EFFECTIVE_START_DATE),
                EFFECTIVE_END_DATE = NVL(p_hierarchy_node_rec.effective_end_date, EFFECTIVE_END_DATE),
                LAST_UPDATED_BY = HZ_UTILITY_V2PUB.last_updated_by,
		LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.last_update_date,
                LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.last_update_login
            WHERE PARENT_ID = r_get_all_parents.parent_id
            AND   PARENT_TABLE_NAME = r_get_all_parents.parent_table_name
            AND   PARENT_OBJECT_TYPE = r_get_all_parents.parent_object_type
            AND   CHILD_ID = r_get_all_children.child_id
            AND   CHILD_TABLE_NAME = r_get_all_children.child_table_name
            AND   CHILD_OBJECT_TYPE = r_get_all_children.child_object_type
            AND   HIERARCHY_TYPE = p_hierarchy_node_rec.hierarchy_type
            AND   (EFFECTIVE_START_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                   OR
                   EFFECTIVE_END_DATE BETWEEN l_existing_start_date AND l_existing_end_date
                   OR
                   l_existing_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                   OR
                   l_existing_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
                  );

            FETCH c_get_all_children INTO r_get_all_children;
        END LOOP;
        CLOSE c_get_all_children;
        FETCH c_get_all_parents INTO r_get_all_parents;
    END LOOP;
    CLOSE c_get_all_parents;
*/

    -------------------
    -- LINK MAINTENANCE
    -- Replaced above code with procedure do_update_link_pvt (Bug 4662744 (Nishant 30-Mar-2006))
    -------------------
     do_update_link_pvt(p_hierarchy_node_rec);


    ---------------------------------
    -- PARENT'S SELF NODE MAINTENANCE
    ---------------------------------
    maintain_self_node (
        p_node_id            => p_hierarchy_node_rec.parent_id,
        p_hierarchy_type     => p_hierarchy_node_rec.hierarchy_type,
        p_table_name         => p_hierarchy_node_rec.parent_table_name,
        p_object_type        => p_hierarchy_node_rec.parent_object_type,
        p_actual_content_source => p_hierarchy_node_rec.actual_content_source
    );


    --------------------------------
    -- CHILD'S SELF NODE MAINTENANCE
    --------------------------------
    maintain_self_node (
        p_node_id            => p_hierarchy_node_rec.child_id,
        p_hierarchy_type     => p_hierarchy_node_rec.hierarchy_type,
        p_table_name         => p_hierarchy_node_rec.child_table_name,
        p_object_type        => p_hierarchy_node_rec.child_object_type,
        p_actual_content_source => p_hierarchy_node_rec.actual_content_source
    );


END do_update_link;


/**********************************
******   Public Procedures ********
***********************************/

/**
 * PROCEDURE create_link
 *
 * DESCRIPTION
 *     Creates a hierarchial relationship between two nodes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_hierarchy_node_rec           Hierarchy node record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    31-JAN-00  Indrajit Sen   o Created
 *
 */

PROCEDURE create_link(
    p_init_msg_list                         IN         VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_node_rec                    IN         HIERARCHY_NODE_REC_TYPE,
    x_return_status                         OUT NOCOPY VARCHAR2,
    x_msg_count                             OUT NOCOPY NUMBER,
    x_msg_data                              OUT NOCOPY VARCHAR2
) IS
l_debug_prefix		       VARCHAR2(30) := '';
BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_link;
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_link (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    do_create_link(p_hierarchy_node_rec,
                   x_return_status);

     --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_link (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_link;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
      IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_line_number = '||l_line_number||' create_link (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_link;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_line_number = '||l_line_number||' create_link (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;


    WHEN OTHERS THEN
        ROLLBACK TO create_link;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_line_number = '||l_line_number||' create_link (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;


END create_link;


/**
 * PROCEDURE update_link
 *
 * DESCRIPTION
 *     Updates a hierarchial relationship between two nodes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_hierarchy_node_rec           Hierarchy node record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    31-JAN-00  Indrajit Sen   o Created
 *
 */

PROCEDURE update_link(
    p_init_msg_list                         IN         VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_node_rec                    IN         HIERARCHY_NODE_REC_TYPE,
    x_return_status                         OUT NOCOPY VARCHAR2,
    x_msg_count                             OUT NOCOPY NUMBER,
    x_msg_data                              OUT NOCOPY VARCHAR2
) IS
l_debug_prefix		       VARCHAR2(30) := '';
BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_link;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_link (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    do_update_link(p_hierarchy_node_rec,
                   x_return_status);

     --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_link (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_link;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_line_number = '||l_line_number||' update_link (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);

        END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_link;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_line_number = '||l_line_number||' update_link (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;


    WHEN OTHERS THEN
        ROLLBACK TO update_link;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

        -- Debug info.
        IF fnd_log.level_error >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
        END IF;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=> 'l_line_number = '||l_line_number||' update_link (-)' ,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);

        END IF;

END update_link;

/**
 * PROCEDURE
 *     convert_rel_type
 *
 * DESCRIPTION
 *     Procedure to convert a particular relationship type
 *     to a hierarchical relationship type
 *
 * SCOPE - Public
 *
 * ARGUMENTS  : IN:
 *                       p_rel_type
 *                       p_multi_parent_allowed
 *                       p_incl_unrelated_entities
 *              OUT:
 *          IN/ OUT:
 *
 * RETURNS    :
 *                       Errbuf
 *                       Retcode
 *
 * NOTES      : p_rel_type can be non-hierarchical relationship type
 *              p_multi_parent_allowed is Y/N
 *              p_incl_unrelated_entities is Y/N
 *
 * MODIFICATION HISTORY
 *
 *    31-JAN-00  Indrajit Sen   o Created

 *
 */

PROCEDURE convert_rel_type(
    errbuf                                  OUT NOCOPY VARCHAR2,
    Retcode                                 OUT NOCOPY VARCHAR2,
    p_rel_type                              IN         VARCHAR2,
    p_multi_parent_allowed                  IN         VARCHAR2,
    p_incl_unrelated_entities               IN         VARCHAR2
)
IS
    CURSOR c1 IS
    SELECT a.ROWID row_id, a.*
    FROM   HZ_RELATIONSHIPS a
    WHERE  RELATIONSHIP_TYPE = p_rel_type
    ORDER BY RELATIONSHIP_ID;

    CURSOR c2 (p_rel_type       VARCHAR2,
               p_forward_rel_code    VARCHAR2,
               p_subject_type        VARCHAR2,
               p_object_type         VARCHAR2)
    IS
    SELECT *
    FROM   HZ_RELATIONSHIP_TYPES
    WHERE  RELATIONSHIP_TYPE = p_rel_type
    AND    FORWARD_REL_CODE = p_forward_rel_code
    AND    SUBJECT_TYPE = p_subject_type
    AND    OBJECT_TYPE = p_object_type;

    -- this cursor retrieves a parent for a given child in a particular hierarchy.
    -- it will be used for circularity check.
    CURSOR c_parent (p_child_id NUMBER, p_child_table_name VARCHAR2, p_child_object_type VARCHAR2,
                     p_rel_type VARCHAR2, p_start_date DATE, p_end_date DATE)
    IS
    SELECT SUBJECT_ID,
           SUBJECT_TABLE_NAME,
           SUBJECT_TYPE
    FROM   HZ_RELATIONSHIPS
    WHERE  OBJECT_ID = p_child_id
    AND    OBJECT_TABLE_NAME = p_child_table_name
    AND    OBJECT_TYPE = p_child_object_type
    AND    RELATIONSHIP_TYPE = p_rel_type
    AND    DIRECTION_CODE = 'P'
    AND    (START_DATE BETWEEN NVL(p_start_date, SYSDATE)
                          AND NVL(p_end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           END_DATE BETWEEN NVL(p_start_date, SYSDATE)
                          AND NVL(p_end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           NVL(p_start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
           OR
           NVL(p_end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE
           );

    r1                                c1%ROWTYPE;
    r2                                c2%ROWTYPE;
    r_parent                          c_parent%ROWTYPE;
    l_hierarchy_rec                   HZ_HIERARCHY_PUB.HIERARCHY_NODE_REC_TYPE;
    l_return_status                   VARCHAR2(1);
    l_msg_count                       NUMBER;
    l_msg_data                        VARCHAR2(2000);
    l_count                           NUMBER;
    l_parent_id                       NUMBER;
    l_parent_object_type              VARCHAR2(30);
    l_parent_table_name               VARCHAR2(30);
    l_child_id                        NUMBER;
    l_child_object_type               VARCHAR2(30);
    l_child_table_name                VARCHAR2(30);
    l_temp_parent_id                  NUMBER;
    l_temp_parent_table_name          VARCHAR2(30);
    l_temp_parent_object_type         VARCHAR2(30);
    l_parent_flag                     VARCHAR2(1);
    l_conc_status                     VARCHAR2(1) := 'S';



BEGIN

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Concurrent program ARHCRTHI - Convert relationship type to hierarchical.');
    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Options - ');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Relationship type : '||p_rel_type);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Multiple parent allowed : '||p_multi_parent_allowed);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Include unrelated entities : '||p_incl_unrelated_entities);
    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');

    -- get all the relationships for this relationship type
    OPEN c1;
    FETCH c1 INTO r1;

    WHILE c1%FOUND LOOP
        -- get the relationship type to determine parent/child
        OPEN c2(r1.relationship_type, r1.relationship_code, r1.subject_type, r1.object_type);
        FETCH c2 INTO r2;

        -- decide who is parent and who is child in this relationship.
        -- if relationship type record is 'P' type, then subject is parent, else object
        IF r2.direction_code = 'P' THEN
            l_parent_id := r1.subject_id;
            l_parent_table_name := r1.subject_table_name;
            l_parent_object_type := r1.subject_type;
            l_child_id := r1.object_id;
            l_child_table_name := r1.object_table_name;
            l_child_object_type := r1.object_type;
        ELSIF r2.direction_code = 'C' THEN
            l_parent_id := r1.object_id;
            l_parent_table_name := r1.object_table_name;
            l_parent_object_type := r1.object_type;
            l_child_id := r1.subject_id;
            l_child_table_name := r1.subject_table_name;
            l_child_object_type := r1.subject_type;
        END IF;

        IF p_multi_parent_allowed = 'N' THEN
            BEGIN
                SELECT 1 INTO l_count
                FROM   HZ_RELATIONSHIPS
                WHERE  OBJECT_ID = l_child_id
                AND    OBJECT_TABLE_NAME = l_child_table_name
                AND    OBJECT_TYPE = l_child_object_type
                AND    RELATIONSHIP_TYPE = r1.relationship_type
                AND    DIRECTION_CODE = 'P'
                AND    (START_DATE BETWEEN NVL(r1.start_date, SYSDATE)
                                      AND NVL(r1.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
                       OR
                       END_DATE BETWEEN NVL(r1.start_date, SYSDATE)
                                      AND NVL(r1.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'))
                       OR
                       NVL(r1.start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
                       OR
                       NVL(r1.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE
                       );

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- no parent found, proceed
                    NULL;
                WHEN TOO_MANY_ROWS then
                    -- there is already a parent, so raise error
                    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Multiple parent found for the following child :');
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Child ID : '||l_child_id);
                    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Chiild Type : '||l_child_object_type);
                    FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
                    l_conc_status := 'E';
                    EXIT;
            END;
        END IF;

        -- Check for circular relationships in the hierarchy.
        -- If circularity is found, reported as error.
        l_parent_flag := 'Y';
        l_temp_parent_id := l_parent_id;
        l_temp_parent_table_name := l_parent_table_name;
        l_temp_parent_object_type := l_parent_object_type;
        WHILE l_parent_flag <> 'N' LOOP
            OPEN c_parent (l_temp_parent_id, l_temp_parent_table_name, l_temp_parent_object_type, r1.relationship_type, r1.start_date, r1.end_date);
            FETCH c_parent INTO r_parent;
            IF c_parent%NOTFOUND THEN
                l_parent_flag := 'N';
            ELSE
                l_temp_parent_id := r_parent.subject_id;
                l_temp_parent_table_name := r_parent.subject_table_name;
                l_temp_parent_object_type := r_parent.subject_type;
            END IF;
            IF l_temp_parent_id = l_child_id THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Circularity exists for the following relationship record : ');
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Subject ID : '||r1.subject_id);
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Subject Type : '||r1.subject_type);
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Object ID : '||r1.object_id);
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Object Type : '||r1.object_type);
                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Relationship Code : '||r1.relationship_code);
                FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
                l_conc_status := 'E';
                CLOSE c_parent;
                EXIT;
            END IF;
            CLOSE c_parent;
        END LOOP;

        IF r2.direction_code = 'P' THEN
            -- record is the parent record
            -- assign the subject to parent for hierarchy
            l_hierarchy_rec.hierarchy_type := r1.relationship_type;
            l_hierarchy_rec.parent_id := r1.subject_id;
            l_hierarchy_rec.parent_table_name := r1.subject_table_name;
            l_hierarchy_rec.parent_object_type := r1.subject_type;
            l_hierarchy_rec.child_id := r1.object_id;
            l_hierarchy_rec.child_table_name := r1.object_table_name;
            l_hierarchy_rec.child_object_type := r1.object_type;
            l_hierarchy_rec.effective_start_date := r1.start_date;
            l_hierarchy_rec.effective_end_date := NVL(r1.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'));
            l_hierarchy_rec.relationship_id := r1.relationship_id;
            l_hierarchy_rec.status := NVL(r1.status, 'A');
        ELSE
            -- record is the child record
            -- assign the object to parent
            l_hierarchy_rec.hierarchy_type := r1.relationship_type;
            l_hierarchy_rec.parent_id := r1.object_id;
            l_hierarchy_rec.parent_table_name := r1.object_table_name;
            l_hierarchy_rec.parent_object_type := r1.object_type;
            l_hierarchy_rec.child_id := r1.subject_id;
            l_hierarchy_rec.child_table_name := r1.subject_table_name;
            l_hierarchy_rec.child_object_type := r1.subject_type;
            l_hierarchy_rec.effective_start_date := r1.start_date;
            l_hierarchy_rec.effective_end_date := NVL(r1.end_date, TO_DATE('31-12-4712 00:00:01', 'DD-MM-YYYY HH24:MI:SS'));
            l_hierarchy_rec.relationship_id := r1.relationship_id;
            l_hierarchy_rec.status := NVL(r1.status, 'A');
        END IF;

        HZ_HIERARCHY_PUB.create_link(
            p_init_msg_list           => FND_API.G_FALSE,
            p_hierarchy_node_rec      => l_hierarchy_rec,
            x_return_status           => l_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
           );

        CLOSE c2;

        IF r2.direction_code = 'P' THEN
            UPDATE HZ_RELATIONSHIPS SET DIRECTION_CODE = 'P' WHERE ROWID = r1.row_id;
        ELSE
            UPDATE HZ_RELATIONSHIPS SET DIRECTION_CODE = 'C' WHERE ROWID = r1.row_id;
        END IF;

        -- one call is to by-pass the second record which is identical but reverse one.
        FETCH c1 INTO r1;
        IF r2.direction_code = 'P' THEN
            UPDATE HZ_RELATIONSHIPS SET DIRECTION_CODE = 'C' WHERE ROWID = r1.row_id;
        ELSE
            UPDATE HZ_RELATIONSHIPS SET DIRECTION_CODE = 'P' WHERE ROWID = r1.row_id;
        END IF;

        FETCH c1 INTO r1;

    END LOOP;

    CLOSE c1;

    IF l_conc_status = 'E' THEN
        ROLLBACK;
        FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Conversion of relationship type to hierarchical failed. ');
        FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
    ELSE
        UPDATE HZ_RELATIONSHIP_TYPES
        SET HIERARCHICAL_FLAG = 'Y',
            MULTIPLE_PARENT_ALLOWED = NVL(p_multi_parent_allowed, 'N'),
            INCL_UNRELATED_ENTITIES = NVL(p_incl_unrelated_entities, 'N')
        WHERE RELATIONSHIP_TYPE = p_rel_type;

        FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Successfully converted relationship type to hierarchical. ');
        FND_FILE.PUT_LINE (FND_FILE.LOG, ' ');
        COMMIT;
    END IF;

END convert_rel_type;

END HZ_HIERARCHY_PUB;

/
