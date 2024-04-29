--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_REPORT_PUB" AS
/* $Header: jtfrsbgb.pls 120.0 2005/05/11 08:19:17 appldev ship $ */

/*****************************************************************************

   This is a sql to get the history of movement of members in and out of groups

   15-JUN-2004    nsinghai   added dummy parameters for selective enabling
                             disbaling of fields.

 *****************************************************************************/

 TYPE REL_RECORD_TYPE IS RECORD
  ( p_group_id           JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_related_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE,
    p_start_date_active  DATE,
    p_end_date_active    DATE,
    p_relation_start_date  DATE,
    p_relation_end_date    DATE,
    level                NUMBER);


  TYPE rel_table IS TABLE OF REL_RECORD_TYPE INDEX BY BINARY_INTEGER;
  g_child_tab rel_table;


PROCEDURE child_groups(p_group_id in number,
                       p_usr_name in varchar2,
                       p_start_date in date,
                       p_end_date   in date,
                       p_usage      in varchar2);

/**********************************************************************************************
 * <Start>
 * Introduced for incorporating reporting of DFF fields
 * Ref: ER# 2549463
 * Data structures and private procedures to accomplish reporting of DFFs
 */

-- Cursor definition to verify if the DFF definition associated with the groups table is frozen.
CURSOR c_DFF_frozen
IS
  SELECT 1
  FROM FND_DESCRIPTIVE_FLEXS_VL
  WHERE DESCRIPTIVE_FLEXFIELD_NAME = 'JTF_RS_GROUPS'
        AND FREEZE_FLEX_DEFINITION_FLAG = 'Y';

r_DFF_frozen c_DFF_frozen%ROWTYPE;

g_DFF_to_be_displayed boolean := false;
g_DFF_prompt_max_length number := 0;

-- Type definition to store relevent details for each segment in the DFF definition
TYPE segment_details_record IS RECORD
( context_code fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE,
  is_global BOOLEAN,
  segment_name fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE,
  is_displayed BOOLEAN,
  row_prompt fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE,
  application_column_name fnd_descr_flex_col_usage_vl.application_column_name%TYPE);

-- Define table to store records containing relevant details of segments
-- Stores all the segments for all the contexts in the DFF definition
TYPE segment_details_table IS TABLE OF segment_details_record INDEX BY BINARY_INTEGER;

all_segment_details_tab segment_details_table;


/*
 * Private Procedure to cache the DFF segment details in a local table
 * Uses FND_DFLEX APIs to populate segment and context details into a local table all_segment_details_tab
 * A record is created for each segment in each context in the DFF definition.
 */
PROCEDURE populate_segment_details_table ( p_appl_short_name  IN  fnd_application.application_short_name%TYPE,
                         p_flexfield_name   IN  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE )
IS
  k INTEGER := 0;
  flexfield fnd_dflex.dflex_r;
  flexinfo  fnd_dflex.dflex_dr;
  contexts  fnd_dflex.contexts_dr;
  segments  fnd_dflex.segments_dr;

BEGIN
  fnd_dflex.get_flexfield(p_appl_short_name, p_flexfield_name, flexfield, flexinfo);
  fnd_dflex.get_contexts(flexfield, contexts);
  FOR i IN 1 .. contexts.ncontexts LOOP /* loop through the contexts defined */
    IF(contexts.is_enabled(i)) THEN /* consider only the contexts that are enabled.*/
      fnd_dflex.get_segments(fnd_dflex.make_context(flexfield, contexts.context_code(i)), segments,TRUE);
      FOR j IN 1 .. segments.nsegments LOOP /* loop through the segments in the each context */
        /* push a record into the local table all_segment_details_tab for each segment */
        k := all_segment_details_tab.count + 1;
        all_segment_details_tab(k).context_code := contexts.context_code(i);
        all_segment_details_tab(k).is_global    := contexts.is_global(i);
        all_segment_details_tab(k).segment_name := segments.segment_name(j);
        all_segment_details_tab(k).is_displayed := segments.is_displayed(j);
        all_segment_details_tab(k).row_prompt := segments.row_prompt(j);
        all_segment_details_tab(k).application_column_name := segments.application_column_name(j);
        /* Determine the maximum length of the prompts for the DFF segments */
        IF ( LENGTH(segments.row_prompt(j)) > g_DFF_prompt_max_length)
        THEN
          g_DFF_prompt_max_length := LENGTH(segments.row_prompt(j)) ;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
END populate_segment_details_table;

/*
 * Private Procedure to print the DFF field values to the output file, for a particular row.
 * this proc may be invoked after only after invoking  the procedure: populate_segment_details_table
 * Parameters: ATTRIBUTE_CATEGORY and  ATTRIBUTEn field values of the row and the required indent for printing
 * Loops over all the segment records for the DFF definition from the local table all_segment_details_tab
   already populated by the proc populate_segment_details_table
 * Prints out values for segments that are either in the global context
   or in the context pertinent to this particular row identified from the value of ATTRIBUTE_CATEGORY of the row
   and with is_displayed flag on.
 * For each segment, identifies the ATTRIBUTEn field storing value for that segment and prints it.
 */
PROCEDURE get_DFF_output
( p_attribute_category   jtf_rs_groups_b.ATTRIBUTE_CATEGORY%TYPE,
  p_attribute1           jtf_rs_groups_b.ATTRIBUTE1%TYPE,
  p_attribute2           jtf_rs_groups_b.ATTRIBUTE2%TYPE,
  p_attribute3           jtf_rs_groups_b.ATTRIBUTE3%TYPE,
  p_attribute4           jtf_rs_groups_b.ATTRIBUTE4%TYPE,
  p_attribute5           jtf_rs_groups_b.ATTRIBUTE5%TYPE,
  p_attribute6           jtf_rs_groups_b.ATTRIBUTE6%TYPE,
  p_attribute7           jtf_rs_groups_b.ATTRIBUTE7%TYPE,
  p_attribute8           jtf_rs_groups_b.ATTRIBUTE8%TYPE,
  p_attribute9           jtf_rs_groups_b.ATTRIBUTE9%TYPE,
  p_attribute10          jtf_rs_groups_b.ATTRIBUTE10%TYPE,
  p_attribute11          jtf_rs_groups_b.ATTRIBUTE11%TYPE,
  p_attribute12          jtf_rs_groups_b.ATTRIBUTE12%TYPE,
  p_attribute13          jtf_rs_groups_b.ATTRIBUTE13%TYPE,
  p_attribute14          jtf_rs_groups_b.ATTRIBUTE14%TYPE,
  p_attribute15          jtf_rs_groups_b.ATTRIBUTE15%TYPE,
  p_indent               NUMBER
)
IS
l_DFF_value jtf_rs_groups_b.ATTRIBUTE1%TYPE;
BEGIN
  FOR i IN 1 .. all_segment_details_tab.count /* Loop over all the segments in the DFF defn. */
  LOOP
    IF (all_segment_details_tab(i).is_displayed AND (all_segment_details_tab(i).is_global OR all_segment_details_tab(i).context_code = p_attribute_category))
    /* segment needs to be printed if it belongs to global context or context pertinent to this record */
    THEN
      /* Identify the ATTRIBUTEn field storing value for this segment */
      IF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE1' THEN
        l_DFF_value := p_attribute1;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE2' THEN
        l_DFF_value := p_attribute2;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE3' THEN
        l_DFF_value := p_attribute3;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE4' THEN
        l_DFF_value := p_attribute4;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE5' THEN
        l_DFF_value := p_attribute5;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE6' THEN
        l_DFF_value := p_attribute6;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE7' THEN
        l_DFF_value := p_attribute7;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE8' THEN
        l_DFF_value := p_attribute8;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE9' THEN
        l_DFF_value := p_attribute9;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE10' THEN
        l_DFF_value := p_attribute10;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE11' THEN
        l_DFF_value := p_attribute11;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE12' THEN
        l_DFF_value := p_attribute12;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE13' THEN
        l_DFF_value := p_attribute13;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE14' THEN
        l_DFF_value := p_attribute14;
      ELSIF all_segment_details_tab(i).application_column_name = 'ATTRIBUTE15' THEN
        l_DFF_value := p_attribute15;
      END IF;
      /* indent the line */
      FOR i IN 1 .. p_indent
      LOOP
        fnd_file.put(fnd_file.log,' ');
      END LOOP;
      /* RPAD so that the values besides the prompts are printed aligned */
      fnd_file.put(fnd_file.log, RPAD (all_segment_details_tab(i).row_prompt || ': ', g_DFF_prompt_max_length + 5, ' ')  || l_DFF_value);
      fnd_file.put_line(fnd_file.log,'');
    END IF;
  END LOOP;

END get_DFF_output;


/*
 * Introduced for incorporating reporting of DFF fields
 * Ref: ER# 2549463
 * Data structures and private procedures to accomplish reporting of DFFs
 * <End>
 * Hereafter code is inserted at appropriate places to invoke the above procedures.
 ***********************************************************************************************/




PROCEDURE query_group(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_REP_TYPE   IN  VARCHAR2 ,
                      P_DUMMY_1    IN VARCHAR2 ,
                      P_DUMMY_2    IN VARCHAR2 ,
                      P_DUMMY_3    IN VARCHAR2 ,
                      P_GROUP_ID   IN NUMBER ,
                      P_RES_ID     IN NUMBER ,
                      P_USAGE      IN VARCHAR2 ,
                      P_USR_NAME   IN VARCHAR2 ,
                      P_DATE_OPT   IN  VARCHAR2 ,
                      P_START_DATE IN varchar2 ,
                      P_END_DATE   IN varchar2 ,
                      P_NO_OF_DAYS IN number )
IS
begin
  query_group (ERRBUF, RETCODE, P_REP_TYPE, P_DUMMY_1, P_DUMMY_2, P_DUMMY_3,  P_GROUP_ID, P_RES_ID, P_USAGE, P_USR_NAME, P_DATE_OPT, P_START_DATE, P_END_DATE, P_NO_OF_DAYS, 'N') ;
end;


/*
 * Procedure overloaded to give user choice to display DFF fields in the report.
 * While submitting the concurrent request, The user may choose to display DFF fields in the report.
 * Ref: ER# 2549463
 */

PROCEDURE query_group(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_REP_TYPE   IN  VARCHAR2 ,
                      P_DUMMY_1    IN VARCHAR2 ,
                      P_DUMMY_2    IN VARCHAR2 ,
                      P_DUMMY_3    IN VARCHAR2 ,
                      P_GROUP_ID   IN NUMBER ,
                      P_RES_ID     IN NUMBER ,
                      P_USAGE      IN VARCHAR2 ,
                      P_USR_NAME   IN VARCHAR2 ,
                      P_DATE_OPT   IN  VARCHAR2 ,
                      P_START_DATE IN varchar2 ,
                      P_END_DATE   IN varchar2 ,
                      P_NO_OF_DAYS IN number,
                      P_DISP_DFF_FIELDS IN VARCHAR2)
is
  /* Moved the initial assignment of below variables to inside begin */
l_group_id   number;
l_res_id   number;
l_usr_name   VARCHAR2(2000);
l_start_date  date;
l_end_date  date;
l_no_of_days  number;

cursor c_grp_usage
    is
 select /*+ INDEX(usg jtf_rs_group_usages_n1) */ group_id
  from  jtf_rs_group_usages usg
 where  usg.usage = p_usage
   and  not exists (select group_id
                     from  jtf_rs_grp_relations rel
                    where  rel.group_id = usg.group_id
                     and   nvl(delete_flag, 'N') <> 'Y') ;

cursor c_grp_usage2
    is
 select /*+ INDEX(usg jtf_rs_group_usages_n1) */ group_id
  from  jtf_rs_group_usages usg
 where  usg.usage = p_usage
   and  usg.group_id = p_group_id;

r_grp_usage c_grp_usage%rowtype;

  --Bug# 2909006. To print Usage at the top of report.
  cursor c_grp_usagename
    is
    select
        meaning
    from
        fnd_lookups
    where  lookup_type = 'JTF_RS_USAGE'
    and lookup_code = p_usage;

     r_grp_usagename c_grp_usagename%rowtype;

cursor c_grp_sec(l_group number)
   is
  select /*+ INDEX(gm jtf_rs_group_members_aud_nu3) */ g1.group_name,
       --<Start>: Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
       g1.attribute_category, g1.attribute1, g1.attribute2, g1.attribute3, g1.attribute4, g1.attribute5, g1.attribute6, g1.attribute7, g1.attribute8,
       g1.attribute9, g1.attribute10, g1.attribute11, g1.attribute12, g1.attribute13, g1.attribute14, g1.attribute15,
       --<End>: Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
       ext.resource_number,
       ext.resource_name,
       ext.category,
       lkp.name category_name,
       to_char(gm.creation_date, 'DD-MON-YYYY:HH24:MI:SS') creation_date,
       fnd.user_name   created_by,
       decode(gm.old_group_id, g1.group_id, 'OUT', 'IN') moved,
       decode(gm.old_group_id, null, null, g1.group_id,null, g3.group_number ) from_group_number,
       decode(gm.old_group_id, null, null, g1.group_id,null, g3.group_name ) from_group_name,
       decode(gm.old_group_id, g1.group_id, g2.group_number, null)    to_group_number,
       decode(gm.old_group_id, g1.group_id, g2.group_name, null)    to_group_name,
       ext.resource_id,
       g1.group_id
  from
       jtf_rs_groups_vl g2,
       jtf_rs_groups_vl g3,
       jtf_rs_resource_extns_vl ext,
       jtf_objects_vl lkp ,
       fnd_user fnd,
       jtf_rs_group_members_aud gm,
       jtf_rs_group_members  mem,
       jtf_rs_groups_vl g1
 where g1.group_id = l_group
 and   mem.group_id  = g1.group_id
 and   gm.group_member_id = mem.group_member_id
 and   ( gm.new_group_id   = g1.group_id
           or gm.old_group_id = g1.group_id )
 and  gm.creation_date between nvl(l_start_date,sysdate)
                           and  nvl(l_end_date,sysdate)
 and   gm.new_group_id  =   g2.group_id(+)
 and   gm.old_group_id  =   g3.group_id(+)
 and  fnd.user_name like nvl(l_usr_name, '%')
 and  fnd.user_id = gm.created_by
 and  mem.resource_id = ext.resource_id
 and  ext.category = lkp.object_code
 order by g1.group_name , resource_name, gm.creation_date , fnd.user_name;


r_grp c_grp_sec%rowtype;
l_prev_group JTF_RS_GROUPS_TL.GROUP_NAME%TYPE;


cursor c_res
   is
  select /*+ INDEX(gm jtf_rs_group_members_aud_nu3) */ g1.group_name,
       --<Start>: Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
       g1.attribute_category, g1.attribute1, g1.attribute2, g1.attribute3, g1.attribute4, g1.attribute5, g1.attribute6, g1.attribute7, g1.attribute8,
       g1.attribute9, g1.attribute10, g1.attribute11, g1.attribute12, g1.attribute13, g1.attribute14, g1.attribute15,
       --<End>: Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
       ext.resource_number,
       ext.resource_name,
       ext.category,
       lkp.name category_name,
       to_char(gm.creation_date, 'DD-MON-YYYY:HH24:MI:SS') creation_date,
       fnd.user_name   created_by,
       decode(gm.old_group_id, g1.group_id, 'OUT', 'IN') moved,
       decode(gm.old_group_id, null, null, g1.group_id,null, g3.group_number ) from_group_number,
       decode(gm.old_group_id, null, null, g1.group_id,null, g3.group_name ) from_group_name,
       decode(gm.old_group_id, g1.group_id, g2.group_number, null)    to_group_number,
       decode(gm.old_group_id, g1.group_id, g2.group_name, null)    to_group_name
 from
       jtf_rs_groups_vl g2,
       jtf_rs_groups_vl g3,
       fnd_user fnd,
       jtf_objects_vl lkp,
       jtf_rs_groups_vl g1,
       jtf_rs_group_members_aud gm,
       jtf_rs_group_members  mem,
       jtf_rs_resource_extns_vl ext
  where  ext.resource_id = l_res_id
    and  mem.resource_id = ext.resource_id
    and  gm.group_member_id = mem.group_member_id
    and  gm.creation_date between nvl(l_start_date,sysdate)
                           and   nvl(l_end_date,sysdate)
    and  gm.created_by = fnd.user_id
    and  fnd.user_name like nvl(l_usr_name, '%')
    and  g1.group_id = mem.group_id
    and  g2.group_id(+)=  gm.new_group_id
    and  g3.group_id(+) = gm.old_group_id
    and  ext.category = lkp.object_code
  order by resource_name, g1.group_name , gm.creation_date , fnd.user_name;

 r_res  c_res%rowtype;

  /* Moved the initial assignment of below variable to inside begin */
 l_rep_type VARCHAR2(30);

 cursor to_grp_cur(l_group_id number,
                   l_resource_id number)
     is
  select gm.group_member_id,
        g1.group_id,
        g1.group_name,
        g1.group_number
 from   jtf_rs_group_members_aud gm,
         jtf_rs_groups_vl g1
 where  gm.old_group_id = l_group_id
 and    gm.new_resource_id = l_resource_id
 and     g1.group_id = gm.new_group_id;

 to_grp_rec to_grp_cur%rowtype;
 l_to_grp_number jtf_rs_groups_vl.group_number%type;
 l_to_grp_name jtf_rs_groups_vl.group_name%type;




begin

  l_group_id    := p_group_id;
  l_res_id      := p_res_id;
  l_usr_name    := p_usr_name;
  l_no_of_days  := p_no_of_days;
  l_rep_type    := p_rep_type;

  IF(p_date_opt = 'RANGE')
  THEN
      l_start_date := trunc(to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS'));
      l_end_date := trunc(to_date(p_end_date,'YYYY/MM/DD HH24:MI:SS'));
  ELSE
      l_start_date := sysdate - nvl(p_no_of_days ,0);
      l_end_date   := sysdate;
  END IF;

  fnd_file.new_line(fnd_file.log, 1);

  --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
  /*
   * If the user chooses to display the DFFs AND the DFF definition is frozen
   * Cache the segment details in a local table.
   */
  IF (P_DISP_DFF_FIELDS = 'Y')
  THEN
      OPEN c_DFF_frozen;
      FETCH c_DFF_frozen INTO r_DFF_frozen;
      IF(c_DFF_frozen%found)
      THEN
        g_DFF_to_be_displayed := TRUE;
        all_segment_details_tab.delete;
        populate_segment_details_table('JTF', 'JTF_RS_GROUPS');
      END IF;
  CLOSE c_DFF_frozen;
  END IF;
  --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463

  IF(l_rep_type = 'GROUP')
  THEN
        open c_grp_sec(p_group_id);
        fetch c_grp_sec into r_grp;
        if(c_grp_sec%found)
        then
           fnd_file.put_line(fnd_file.log,'Group name: '||r_grp.group_name);
           --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
           IF (g_DFF_to_be_displayed)
           THEN
             get_DFF_output
             (  r_grp.ATTRIBUTE_CATEGORY,
                r_grp.ATTRIBUTE1,
                r_grp.ATTRIBUTE2,
                r_grp.ATTRIBUTE3,
                r_grp.ATTRIBUTE4,
                r_grp.ATTRIBUTE5,
                r_grp.ATTRIBUTE6,
                r_grp.ATTRIBUTE7,
                r_grp.ATTRIBUTE8,
                r_grp.ATTRIBUTE9,
                r_grp.ATTRIBUTE10,
                r_grp.ATTRIBUTE11,
                r_grp.ATTRIBUTE12,
                r_grp.ATTRIBUTE13,
                r_grp.ATTRIBUTE14,
                r_grp.ATTRIBUTE15,
                0
             );
           END IF;
           --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
        else
           fnd_file.put_line(fnd_file.log,'No values found based on your criterion');
        end if;
        l_prev_group := r_grp.group_name;
        while (c_grp_sec%FOUND)
        loop
            if (l_prev_group <> r_grp.group_name)
            then
              fnd_file.new_line(fnd_file.log, 3);
              fnd_file.put_line(fnd_file.log,'Group name: '||r_grp.group_name);
              --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
              IF (g_DFF_to_be_displayed)
              THEN
                get_DFF_output
                (  r_grp.ATTRIBUTE_CATEGORY,
                   r_grp.ATTRIBUTE1,
                   r_grp.ATTRIBUTE2,
                   r_grp.ATTRIBUTE3,
                   r_grp.ATTRIBUTE4,
                   r_grp.ATTRIBUTE5,
                   r_grp.ATTRIBUTE6,
                   r_grp.ATTRIBUTE7,
                   r_grp.ATTRIBUTE8,
                   r_grp.ATTRIBUTE9,
                   r_grp.ATTRIBUTE10,
                   r_grp.ATTRIBUTE11,
                   r_grp.ATTRIBUTE12,
                   r_grp.ATTRIBUTE13,
                   r_grp.ATTRIBUTE14,
                   r_grp.ATTRIBUTE15,
                   0
                );
              END IF;
              --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
            end if;

            if(r_grp.moved = 'OUT')
            then
               open  to_grp_cur( r_grp.group_id,
                     r_grp.resource_id)  ;
               fetch to_grp_cur into to_grp_rec;
               l_to_grp_number := to_grp_rec.group_number;
               l_to_grp_name := to_grp_rec.group_name;
               close to_grp_cur;
            else
               l_to_grp_number := null;
               l_to_grp_name := null;
            end if;

            fnd_file.put_line(fnd_file.log,rpad('  Resource Name: ',27, ' ')||r_grp.resource_name);
            fnd_file.put_line(fnd_file.log,rpad('  Resource Number: ',27, ' ')||r_grp.resource_number);
            fnd_file.put_line(fnd_file.log,rpad('  Category: ',27, ' ')||r_grp.category_name);
            fnd_file.put_line(fnd_file.log,rpad('  Date: ',27, ' ')||r_grp.creation_date);
            fnd_file.put_line(fnd_file.log,rpad('  Updated By: ',27, ' ')||r_grp.created_by);
            fnd_file.put_line(fnd_file.log,rpad('  Action: ',27, ' ')||r_grp.moved);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group #:',27, ' ')||r_grp.from_group_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group Name:',27, ' ')||r_grp.from_group_name);
            fnd_file.put_line(fnd_file.log,rpad('  Moved To Group #:',27, ' ')||l_to_grp_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved to Group Name: ',27, ' ')||l_to_grp_name);
            --fnd_file.put_line(fnd_file.log,rpad('  Moved To Group #:',27, ' ')||r_grp.to_group_number);
            --fnd_file.put_line(fnd_file.log,rpad('  Moved to Group Name: ',27, ' ')||r_grp.to_group_name);
            l_prev_group := r_grp.group_name;
            fnd_file.new_line(fnd_file.log, 1);
            fetch c_grp_sec into r_grp;

        end loop; -- end of if
        close c_grp_sec;


       -- for the child groups
       child_groups(p_group_id,
                    p_usr_name,
                    l_start_date,
                    l_end_date,
                    p_usage);
    ELSIF(l_rep_type = 'USAGE')
    THEN
    --Bug# 2909006. Print Usage at the top of report.
    open  c_grp_usagename;
     fetch c_grp_usagename into r_grp_usagename;
     if (c_grp_usagename%found) then
        fnd_file.put_line(fnd_file.log,'Usage:      ' || r_grp_usagename.meaning);
     end if;
     close c_grp_usagename;

     if(p_group_id is null)
     then

       open c_grp_usage;
       fetch c_grp_usage into r_grp_usage;
       while(c_grp_usage%found)
       loop
          open c_grp_sec(r_grp_usage.group_id);
          fetch c_grp_sec into r_grp;
          if(c_grp_sec%found)
          then
             fnd_file.put_line(fnd_file.log,'Group name: '||r_grp.group_name);
             --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
             IF (g_DFF_to_be_displayed)
             THEN
               get_DFF_output
               (  r_grp.ATTRIBUTE_CATEGORY,
                  r_grp.ATTRIBUTE1,
                  r_grp.ATTRIBUTE2,
                  r_grp.ATTRIBUTE3,
                  r_grp.ATTRIBUTE4,
                  r_grp.ATTRIBUTE5,
                  r_grp.ATTRIBUTE6,
                  r_grp.ATTRIBUTE7,
                  r_grp.ATTRIBUTE8,
                  r_grp.ATTRIBUTE9,
                  r_grp.ATTRIBUTE10,
                  r_grp.ATTRIBUTE11,
                  r_grp.ATTRIBUTE12,
                  r_grp.ATTRIBUTE13,
                  r_grp.ATTRIBUTE14,
                  r_grp.ATTRIBUTE15,
                  0
               );
             END IF;
             --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
          end if;
         l_prev_group := r_grp.group_name;


          while (c_grp_sec%FOUND)
          loop
            if (l_prev_group <> r_grp.group_name)
            then
              fnd_file.new_line(fnd_file.log, 3);
              fnd_file.put_line(fnd_file.log,'Group name: '||r_grp.group_name);
              --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
              IF (g_DFF_to_be_displayed)
              THEN
                get_DFF_output
                (  r_grp.ATTRIBUTE_CATEGORY,
                   r_grp.ATTRIBUTE1,
                   r_grp.ATTRIBUTE2,
                   r_grp.ATTRIBUTE3,
                   r_grp.ATTRIBUTE4,
                   r_grp.ATTRIBUTE5,
                   r_grp.ATTRIBUTE6,
                   r_grp.ATTRIBUTE7,
                   r_grp.ATTRIBUTE8,
                   r_grp.ATTRIBUTE9,
                   r_grp.ATTRIBUTE10,
                   r_grp.ATTRIBUTE11,
                   r_grp.ATTRIBUTE12,
                   r_grp.ATTRIBUTE13,
                   r_grp.ATTRIBUTE14,
                   r_grp.ATTRIBUTE15,
                   0
                );
              END IF;
              --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
            end if;

            if(r_grp.moved = 'OUT')
            then
               open  to_grp_cur( r_grp.group_id,
                     r_grp.resource_id)  ;
               fetch to_grp_cur into to_grp_rec;
               l_to_grp_number := to_grp_rec.group_number;
               l_to_grp_name := to_grp_rec.group_name;
               close to_grp_cur;
            else
               l_to_grp_number := null;
               l_to_grp_name := null;
            end if;

            fnd_file.put_line(fnd_file.log,rpad('  Resource Name: ',27, ' ')||r_grp.resource_name);
            fnd_file.put_line(fnd_file.log,rpad('  Resource Number: ',27, ' ')||r_grp.resource_number);
            fnd_file.put_line(fnd_file.log,rpad('  Category: ',27, ' ')||r_grp.category_name);
            fnd_file.put_line(fnd_file.log,rpad('  Date: ',27, ' ')||r_grp.creation_date);
            fnd_file.put_line(fnd_file.log,rpad('  Updated By: ',27, ' ')||r_grp.created_by);
            fnd_file.put_line(fnd_file.log,rpad('  Action: ',27, ' ')||r_grp.moved);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group #:',27, ' ')||r_grp.from_group_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group Name:',27, ' ')||r_grp.from_group_name);
            --fnd_file.put_line(fnd_file.log,rpad('  Moved To Group #:',27, ' ')||r_grp.to_group_number);
            --fnd_file.put_line(fnd_file.log,rpad('  Moved to Group Name: ',27, ' ')||r_grp.to_group_name);
            fnd_file.put_line(fnd_file.log,rpad('  Moved To Group #:',27, ' ')||l_to_grp_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved to Group Name: ',27, ' ')||l_to_grp_name);
            l_prev_group := r_grp.group_name;
            fnd_file.new_line(fnd_file.log, 1);
            fetch c_grp_sec into r_grp;

          end loop; -- end of if
          close c_grp_sec;

          --call drill down
           child_groups(r_grp_usage.group_id,
                    p_usr_name,
                    l_start_date,
                    l_end_date,
                    p_usage);


          fetch c_grp_usage into r_grp_usage;
         end loop;
         close c_grp_usage;
     else
       open c_grp_usage2;
       fetch c_grp_usage2 into r_grp_usage;
       while(c_grp_usage2%found)
       loop
          open c_grp_sec(r_grp_usage.group_id);
          fetch c_grp_sec into r_grp;
          if(c_grp_sec%found)
          then
             fnd_file.put_line(fnd_file.log,'Group name: '||r_grp.group_name);
             --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
             IF (g_DFF_to_be_displayed)
             THEN
               get_DFF_output
               (  r_grp.ATTRIBUTE_CATEGORY,
                  r_grp.ATTRIBUTE1,
                  r_grp.ATTRIBUTE2,
                  r_grp.ATTRIBUTE3,
                  r_grp.ATTRIBUTE4,
                  r_grp.ATTRIBUTE5,
                  r_grp.ATTRIBUTE6,
                  r_grp.ATTRIBUTE7,
                  r_grp.ATTRIBUTE8,
                  r_grp.ATTRIBUTE9,
                  r_grp.ATTRIBUTE10,
                  r_grp.ATTRIBUTE11,
                  r_grp.ATTRIBUTE12,
                  r_grp.ATTRIBUTE13,
                  r_grp.ATTRIBUTE14,
                  r_grp.ATTRIBUTE15,
                  0
               );
             END IF;
             --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
         end if;
         l_prev_group := r_grp.group_name;


          while (c_grp_sec%FOUND)
          loop
            if (l_prev_group <> r_grp.group_name)
            then
              fnd_file.new_line(fnd_file.log, 3);
              fnd_file.put_line(fnd_file.log,'Group name: '||r_grp.group_name);
              --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
              IF (g_DFF_to_be_displayed)
              THEN
                get_DFF_output
                (  r_grp.ATTRIBUTE_CATEGORY,
                   r_grp.ATTRIBUTE1,
                   r_grp.ATTRIBUTE2,
                   r_grp.ATTRIBUTE3,
                   r_grp.ATTRIBUTE4,
                   r_grp.ATTRIBUTE5,
                   r_grp.ATTRIBUTE6,
                   r_grp.ATTRIBUTE7,
                   r_grp.ATTRIBUTE8,
                   r_grp.ATTRIBUTE9,
                   r_grp.ATTRIBUTE10,
                   r_grp.ATTRIBUTE11,
                   r_grp.ATTRIBUTE12,
                   r_grp.ATTRIBUTE13,
                   r_grp.ATTRIBUTE14,
                   r_grp.ATTRIBUTE15,
                   0
                );
              END IF;
              --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
            end if;

            if(r_grp.moved = 'OUT')
            then
               open  to_grp_cur( r_grp.group_id,
                     r_grp.resource_id)  ;
               fetch to_grp_cur into to_grp_rec;
               l_to_grp_number := to_grp_rec.group_number;
               l_to_grp_name := to_grp_rec.group_name;
               close to_grp_cur;
            else
               l_to_grp_number := null;
               l_to_grp_name := null;
            end if;

            fnd_file.put_line(fnd_file.log,rpad('  Resource Name: ',27, ' ')||r_grp.resource_name);
            fnd_file.put_line(fnd_file.log,rpad('  Resource Number: ',27, ' ')||r_grp.resource_number);
            fnd_file.put_line(fnd_file.log,rpad('  Category: ',27, ' ')||r_grp.category_name);
            fnd_file.put_line(fnd_file.log,rpad('  Date: ',27, ' ')||r_grp.creation_date);
            fnd_file.put_line(fnd_file.log,rpad('  Updated By: ',27, ' ')||r_grp.created_by);
            fnd_file.put_line(fnd_file.log,rpad('  Action: ',27, ' ')||r_grp.moved);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group #:',27, ' ')||r_grp.from_group_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group Name:',27, ' ')||r_grp.from_group_name);
            --fnd_file.put_line(fnd_file.log,rpad('  Moved To Group #:',27, ' ')||r_grp.to_group_number);
            --fnd_file.put_line(fnd_file.log,rpad('  Moved to Group Name: ',27, ' ')||r_grp.to_group_name);
            fnd_file.put_line(fnd_file.log,rpad('  Moved To Group #:',27, ' ')||l_to_grp_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved to Group Name: ',27, ' ')||l_to_grp_name);
            l_prev_group := r_grp.group_name;
            fnd_file.new_line(fnd_file.log, 1);
            fetch c_grp_sec into r_grp;

          end loop; -- end of if
          close c_grp_sec;

          --call drill down
           child_groups(r_grp_usage.group_id,
                    p_usr_name,
                    l_start_date,
                    l_end_date,
                    p_usage);


          fetch c_grp_usage2 into r_grp_usage;
         end loop;
         close c_grp_usage2;
     end if; --end of group_id check
  ELSIF(l_rep_type = 'RESOURCE')
  THEN
        open c_res;
        fetch c_res into r_res;
        if(c_res%found)
        then
          fnd_file.put_line(fnd_file.log,'Resource: '||r_res.resource_name);
          fnd_file.put_line(fnd_file.log,'Resource Number: '||r_res.resource_number);
          fnd_file.put_line(fnd_file.log,'Category: '||r_res.category_name);
          fnd_file.put_line(fnd_file.log,rpad(' Group name: ',27,' ')||r_res.group_name);
          --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
          IF (g_DFF_to_be_displayed)
          THEN
            get_DFF_output
            (  r_res.ATTRIBUTE_CATEGORY,
               r_res.ATTRIBUTE1,
               r_res.ATTRIBUTE2,
               r_res.ATTRIBUTE3,
               r_res.ATTRIBUTE4,
               r_res.ATTRIBUTE5,
               r_res.ATTRIBUTE6,
               r_res.ATTRIBUTE7,
               r_res.ATTRIBUTE8,
               r_res.ATTRIBUTE9,
               r_res.ATTRIBUTE10,
               r_res.ATTRIBUTE11,
               r_res.ATTRIBUTE12,
               r_res.ATTRIBUTE13,
               r_res.ATTRIBUTE14,
               r_res.ATTRIBUTE15,
               1
            );
          END IF;
          --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
        else
           fnd_file.put_line(fnd_file.log,'No values found based on your criterion');
       end if;
        l_prev_group := r_res.group_name;
        while (c_res%FOUND)
        loop
            if (l_prev_group <> r_res.group_name)
            then
              fnd_file.new_line(fnd_file.log, 3);
              fnd_file.put_line(fnd_file.log,rpad('  Group name: ',27,' ')||r_res.group_name);
              --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
              IF (g_DFF_to_be_displayed)
              THEN
                get_DFF_output
                (  r_res.ATTRIBUTE_CATEGORY,
                   r_res.ATTRIBUTE1,
                   r_res.ATTRIBUTE2,
                   r_res.ATTRIBUTE3,
                   r_res.ATTRIBUTE4,
                   r_res.ATTRIBUTE5,
                   r_res.ATTRIBUTE6,
                   r_res.ATTRIBUTE7,
                   r_res.ATTRIBUTE8,
                   r_res.ATTRIBUTE9,
                   r_res.ATTRIBUTE10,
                   r_res.ATTRIBUTE11,
                   r_res.ATTRIBUTE12,
                   r_res.ATTRIBUTE13,
                   r_res.ATTRIBUTE14,
                   r_res.ATTRIBUTE15,
                   2
                );
              END IF;
              --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
            end if;
            fnd_file.put_line(fnd_file.log,rpad('  Date: ',29, ' ')||r_res.creation_date);
            fnd_file.put_line(fnd_file.log,rpad('  Updated By: ',29, ' ')||r_res.created_by);
            fnd_file.put_line(fnd_file.log,rpad('  Action: ',29, ' ')||r_res.moved);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group #:',29, ' ')||r_res.from_group_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved From Group Name:',29, ' ')||r_res.from_group_name);
            fnd_file.put_line(fnd_file.log,rpad('  Moved To Group #:',29, ' ')||r_res.to_group_number);
            fnd_file.put_line(fnd_file.log,rpad('  Moved to Group Name: ',29, ' ')||r_res.to_group_name);
            l_prev_group := r_res.group_name;
            fnd_file.new_line(fnd_file.log, 1);
            fetch c_res into r_res;

        end loop; -- end of if
        close c_res;

  END IF;
  --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
  IF (g_DFF_to_be_displayed <> FALSE)
  THEN
    all_segment_details_tab.delete;
    g_DFF_to_be_displayed := FALSE;
    g_DFF_prompt_max_length := 0;
  END IF;
  --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
exception
   when others then
       fnd_file.put_line(fnd_file.log,sqlerrm);
end query_group;

 /* This procedure traverse recursively thru the child
     hierarchy of a group and populates g_child_tab table with
     records which are within the date range.  This procedure
     emulates the connect by prior cursor for finding parent groups. */
  PROCEDURE POPULATE_CHILD_TABLE(P_GROUP_ID IN NUMBER,
                                 P_GREATEST_START_DATE IN DATE,
                                 P_LEAST_END_DATE IN DATE,
                                 P_LEVEL IN NUMBER)
  IS
    CURSOR c_children (l_g_miss_date DATE)
    IS
      SELECT rel.group_id,
           rel.related_group_id,
           trunc(greatest(rel.start_date_active,
                      nvl(p_greatest_start_date, rel.start_date_active))) greatest_start_date,
             /* Logic : end_date_active, p_least_end_date
                          NULL         , NULL   = NULL
                          NULL         , Value  = Value
                          Value        , NULL   = Value
                          Value1       , Value2 = least(value1, value2) */
           trunc(least(nvl(rel.end_date_active, p_least_end_date),
                   nvl(p_least_end_date, rel.end_date_active))) least_end_date,
             start_date_active relation_start_date,
             end_date_active relation_end_date
       FROM jtf_rs_grp_relations rel
       WHERE relation_type = 'PARENT_GROUP'
       AND rel.related_group_id = p_group_id
       AND NVL(rel.delete_flag, 'N') <> 'Y'
         /*
            mugsrin:
            Modified the following lines to comply with GSCC standard
            Original:
            AND least(nvl(end_date_active, to_date(l_g_miss_date)),
                   nvl(p_least_end_date, to_date(l_g_miss_date))) >=
            Modified as given below:
         */
            AND least(nvl(end_date_active, to_date(to_char(l_g_miss_date,'DD-MM-RRRR'),'DD-MM-RRRR')),
                nvl(p_least_end_date, to_date(to_char(l_g_miss_date,'DD-MM-RRRR'),'DD-MM-RRRR'))) >=
            trunc(greatest(start_date_active,nvl(p_greatest_start_date, start_date_active)));

     i INTEGER := 0;
  BEGIN
     FOR r_child IN c_children(FND_API.G_MISS_DATE) LOOP
       i := g_child_tab.COUNT+1;
       g_child_tab(i).p_group_id            := r_child.group_id;
       g_child_tab(i).p_related_group_id    := r_child.related_group_id;
       g_child_tab(i).p_start_date_active   := r_child.greatest_start_date;
       g_child_tab(i).p_end_date_active     := r_child.least_end_date;
       g_child_tab(i).p_relation_start_date := r_child.relation_start_date;
       g_child_tab(i).p_relation_end_date   := r_child.relation_end_date;
       g_child_tab(i).level                 := p_level;
       populate_child_table(g_child_tab(i).p_group_id,
                            g_child_tab(i).p_start_date_active,
                            g_child_tab(i).p_end_date_active,
                            p_level+1);
     END LOOP;
  END;

  /* This procedure traverse recursively thru the child
     hierarchy of a group and populates g_child_tab table with
     records which are within the date range.  This procedure
     emulates the connect by prior cursor for finding parent groups. */
  PROCEDURE POPULATE_CHILD_TABLE(P_GROUP_ID IN NUMBER)
  IS
  BEGIN
     g_child_tab.delete;
     populate_child_table(p_group_id, null, null, 1);
  END;

/*
  Added P_DISP_ROLE parameter vide Bug# 1745032
 */

PROCEDURE query_group_hierarchy(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_GROUP_NAME IN VARCHAR2 ,
                      P_DISP_ROLE IN VARCHAR2  )
is
begin
  query_group_hierarchy (ERRBUF, RETCODE, P_GROUP_NAME, P_DISP_ROLE, 'N');
end;

/*
 * Procedure overloaded to give user choice to display DFF fields in the report.
 * While submitting the concurrent request, The user may choose to display DFF fields in the report.
 * Ref: ER# 2549463
 */
PROCEDURE query_group_hierarchy(ERRBUF  OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      P_GROUP_NAME IN VARCHAR2 ,
                      P_DISP_ROLE IN VARCHAR2,
                      P_DISP_DFF_FIELDS IN VARCHAR2 )
is

cursor group_id_cur
   is
 select group_id,
        --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
        attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8,
        attribute9, attribute10, attribute11, attribute12, attribute13, attribute14, attribute15
        --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
  from  jtf_rs_groups_vl
 where group_name = p_group_name;
group_id_rec group_id_cur%rowtype;

cursor child_dtls_cur(l_group_id number)
  is
select group_name,
       start_date_active,
      end_date_active,
        --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
        attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,
        attribute8, attribute9, attribute10, attribute11, attribute12, attribute13, attribute14, attribute15
        --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
from  jtf_rs_groups_vl
where group_id = l_group_id;

--<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
child_dtls_rec child_dtls_cur%rowtype;
--<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463

/* Begin of Change - Bug # 1745032 */
/*
cursor members_cur(l_group_id number)
   is
select mem.resource_id,
       res.resource_name,
       obj.name     category_name
 from  jtf_rs_group_members mem,
       jtf_rs_resource_extns_vl res,
       jtf_objects_vl  obj
where  mem.group_id = l_group_id
  and  nvl(mem.delete_flag, 'N') <> 'Y'
  and  mem.resource_id = res.resource_id
  and  res.category    = obj.object_code;
*/

cursor members_cur(l_group_id number)
   is
select mem.resource_id,
       res.resource_name,
       rol.role_name,
       obj.name     category_name,
       rol.res_rl_start_date,
       rol.res_rl_end_date
 from  jtf_rs_group_members mem,
       jtf_rs_resource_extns_vl res,
       jtf_rs_defresroles_vl rol,
       jtf_objects_vl  obj
where  mem.group_id = l_group_id
  and  nvl(mem.delete_flag, 'N') <> 'Y'
  and  mem.resource_id = res.resource_id
  and  mem.group_member_id = rol.role_resource_id(+)
  and  rol.role_resource_type(+) = 'RS_GROUP_MEMBER'
  and  nvl(rol.delete_flag, 'N') <> 'Y'
  -- and  trunc(sysdate) between nvl(rol.res_rl_start_date(+),sysdate) and nvl(rol.res_rl_end_date(+),sysdate)
  and  res.category    = obj.object_code;

/* End of Change - Bug# 1745032 */

members_rec members_cur%rowtype;
l_group_id number;
l_role_name jtf_rs_roles_vl.role_name%TYPE;
l_sysdate DATE;

l_child_tab rel_table;

begin

l_sysdate := TRUNC(SYSDATE);

--<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
/*
 * If the user chooses to display the DFFs AND the DFF definition is frozen
 * Cache the segment details in a local table.
 */
IF (P_DISP_DFF_FIELDS = 'Y')
THEN
    OPEN c_DFF_frozen;
    FETCH c_DFF_frozen INTO r_DFF_frozen;
    IF(c_DFF_frozen%found)
    THEN
      g_DFF_to_be_displayed := TRUE;
      all_segment_details_tab.delete;
      populate_segment_details_table('JTF', 'JTF_RS_GROUPS');
    END IF;
CLOSE c_DFF_frozen;
END IF;
--<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
open group_id_cur;
fetch group_id_cur into group_id_rec;
while(group_id_cur%found)
loop
  fnd_file.put_line(fnd_file.log,'Group name: '||p_group_name);
  --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
  IF (g_DFF_to_be_displayed)
  THEN
    get_DFF_output
    (  group_id_rec.ATTRIBUTE_CATEGORY,
       group_id_rec.ATTRIBUTE1,
       group_id_rec.ATTRIBUTE2,
       group_id_rec.ATTRIBUTE3,
       group_id_rec.ATTRIBUTE4,
       group_id_rec.ATTRIBUTE5,
       group_id_rec.ATTRIBUTE6,
       group_id_rec.ATTRIBUTE7,
       group_id_rec.ATTRIBUTE8,
       group_id_rec.ATTRIBUTE9,
       group_id_rec.ATTRIBUTE10,
       group_id_rec.ATTRIBUTE11,
       group_id_rec.ATTRIBUTE12,
       group_id_rec.ATTRIBUTE13,
       group_id_rec.ATTRIBUTE14,
       group_id_rec.ATTRIBUTE15,
       0
    );
  END IF;
  --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
  l_group_id := group_id_rec.group_id;
  -- get members
  open members_cur(l_group_id);
  fetch  members_cur into members_rec;
  while(members_cur%found)
  loop
        --print members
      fnd_file.put_line(fnd_file.log,rpad('   Member :',15,' ') ||members_rec.resource_name);
      /* Begin of Add - Bug# 1745032 */
      if (p_disp_role ='Y') then
          l_role_name := members_rec.role_name;
        if members_rec.res_rl_start_date IS NOT NULL THEN
          if (l_sysdate NOT BETWEEN members_rec.res_rl_start_date
                              AND NVL (members_rec.res_rl_end_date, l_sysdate)) THEN
            l_role_name := NULL;
          end if;
        end if;
       fnd_file.put_line(fnd_file.log,rpad('     Role :',15,' ') ||l_role_name);
      end if;
      /* End  of Add - Bug# 1745032 */
      fnd_file.put_line(fnd_file.log,rpad(' Category :',15,' ') ||members_rec.category_name);

      fetch  members_cur into members_rec;
  end loop;
  close members_cur;

  populate_child_table(l_group_id);
  l_child_tab := g_child_tab;

  FOR I IN 1 .. l_child_tab.COUNT
  LOOP
      open child_dtls_cur(l_child_tab(i).p_group_id);
      --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
      fetch child_dtls_cur into child_dtls_rec;
      --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463

     --get group name etc
      fnd_file.put_line(fnd_file.log,rpad('      Child Group name: ',27, ' ')||child_dtls_rec.group_name);
      fnd_file.put_line(fnd_file.log,rpad('      Level : ',27, ' ')||l_child_tab(i).level);
      fnd_file.put_line(fnd_file.log,rpad('      Effective : ',27, ' ')||l_child_tab(i).p_relation_start_date ||' -- '||l_child_tab(i).p_relation_end_date);
      --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
      IF (g_DFF_to_be_displayed)
      THEN
        get_DFF_output
        (  child_dtls_rec.ATTRIBUTE_CATEGORY,
           child_dtls_rec.ATTRIBUTE1,
           child_dtls_rec.ATTRIBUTE2,
           child_dtls_rec.ATTRIBUTE3,
           child_dtls_rec.ATTRIBUTE4,
           child_dtls_rec.ATTRIBUTE5,
           child_dtls_rec.ATTRIBUTE6,
           child_dtls_rec.ATTRIBUTE7,
           child_dtls_rec.ATTRIBUTE8,
           child_dtls_rec.ATTRIBUTE9,
           child_dtls_rec.ATTRIBUTE10,
           child_dtls_rec.ATTRIBUTE11,
           child_dtls_rec.ATTRIBUTE12,
           child_dtls_rec.ATTRIBUTE13,
           child_dtls_rec.ATTRIBUTE14,
           child_dtls_rec.ATTRIBUTE15,
           6
        );
      END IF;
      --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
      close child_dtls_cur;

     -- get members
      open members_cur(l_child_tab(i).p_group_id);
      fetch  members_cur into members_rec;
      while(members_cur%found)
      loop
        --print members
         fnd_file.put_line(fnd_file.log,rpad('       Member :',20,' ') ||members_rec.resource_name);
      /* Begin of Add - Bug# 1745032 */
         if (p_disp_role ='Y') then
           fnd_file.put_line(fnd_file.log,rpad('       Role   :',20,' ') ||members_rec.role_name);
         end if;
      /* End  of Add - Bug# 1745032 */
         fnd_file.put_line(fnd_file.log,rpad('     Category :',20,' ') ||members_rec.category_name);

         fetch  members_cur into members_rec;
      end loop;
      close members_cur;
  end loop; -- end of FOR loop
fetch group_id_cur into group_id_rec;
end loop;
close group_id_cur;
--<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
IF (g_DFF_to_be_displayed <> FALSE)
THEN
  all_segment_details_tab.delete;
  g_DFF_to_be_displayed := FALSE;
  g_DFF_prompt_max_length := 0;
END IF;
--<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
end query_group_hierarchy;

procedure child_groups(p_group_id in number,
                       p_usr_name in varchar2,
                       p_start_date in date,
                       p_end_date   in date,
                       p_usage      in varchar2)
is

   CURSOR c_date(x_group_id   JTF_RS_GROUPS_VL.GROUP_ID%TYPE)
      IS
          SELECT grp.start_date_active,
                 grp.end_date_active
            FROM jtf_rs_groups_b grp
           WHERE grp.group_id = x_group_id;

  cursor  c_check_usage(l_group_id  number,
                        l_usage     varchar2)
      is
   select usg.usage
    from  jtf_rs_group_usages usg
   where  usg.usage = l_usage
     and  usg.group_id = l_group_id;


  r_check_usage c_check_usage%rowtype;

  cursor c_grp_child(l_group_id number,
               l_usr_name varchar2,
               l_start_date date,
               l_end_date   date)
   is
  select /*+ INDEX(gm jtf_rs_group_members_aud_nu3) */ g1.group_name,
       --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
       g1.attribute_category, g1.attribute1, g1.attribute2, g1.attribute3, g1.attribute4, g1.attribute5, g1.attribute6, g1.attribute7, g1.attribute8,
       g1.attribute9, g1.attribute10, g1.attribute11, g1.attribute12, g1.attribute13, g1.attribute14, g1.attribute15,
       --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
       ext.resource_number,
       ext.resource_name,
       ext.category,
       lkp.name category_name,
       to_char(gm.creation_date, 'DD-MON-YYYY:HH24:MI:SS') creation_date,
       fnd.user_name   created_by,
       decode(gm.old_group_id, g1.group_id, 'OUT', 'IN') moved,
       decode(gm.old_group_id, null, null, g1.group_id,null, g3.group_number ) from_group_number,
       decode(gm.old_group_id, null, null, g1.group_id,null, g3.group_name ) from_group_name,
       decode(gm.old_group_id, g1.group_id, g2.group_number, null)    to_group_number,
       decode(gm.old_group_id, g1.group_id, g2.group_name, null)    to_group_name,
       ext.resource_id,
       g1.group_id
  from
       jtf_rs_groups_vl g2,
       jtf_rs_groups_vl g3,
       jtf_rs_resource_extns_vl ext,
       jtf_objects_vl lkp ,
       fnd_user fnd,
       jtf_rs_group_members_aud gm,
       jtf_rs_group_members  mem,
       jtf_rs_groups_vl g1
 where g1.group_id = l_group_id
 and   mem.group_id  = g1.group_id
 and   gm.group_member_id = mem.group_member_id
 and   ( gm.new_group_id   = g1.group_id
           or gm.old_group_id = g1.group_id )
 and  gm.creation_date between nvl(l_start_date,sysdate)
                           and  nvl(l_end_date,sysdate)
 and   gm.new_group_id  =   g2.group_id(+)
 and   gm.old_group_id  =   g3.group_id(+)
 and  fnd.user_name like nvl(l_usr_name, '%')
 and  fnd.user_id = gm.created_by
   and  mem.resource_id = ext.resource_id
 and  ext.category = lkp.object_code
 order by g1.group_name , resource_name, gm.creation_date , fnd.user_name;

 r_grp_child c_grp_child%rowtype;

  l_child_tab rel_table;

  i BINARY_INTEGER := 0;
  j BINARY_INTEGER := 0;

  cursor to_grp_cur(l_group_id number,
                   l_resource_id number)
     is
  select gm.group_member_id,
        g1.group_id,
        g1.group_name,
        g1.group_number
 from   jtf_rs_group_members_aud gm,
         jtf_rs_groups_vl g1
 where  gm.old_group_id = l_group_id
 and    gm.new_resource_id = l_resource_id
 and     g1.group_id = gm.new_group_id;

 to_grp_rec to_grp_cur%rowtype;
 l_to_grp_number jtf_rs_groups_vl.group_number%type;
 l_to_grp_name jtf_rs_groups_vl.group_name%type;

--Declare the variables
--
    l_api_version CONSTANT NUMBER        :=1.0;

  /* Moved the initial assignment of below variable to inside begin */
    l_immediate_parent_flag VARCHAR2(1);
    l_date  Date;
    l_user_id  Number;
    l_login_id  Number;
    l_start_date Date;
    l_end_date Date;
  /* Moved the initial assignment of below variable to inside begin */
    l_return_status varchar2(1);
    l_msg_count   number;
    l_msg_data    varchar2(2000);

    l_usage_found number := 1;


    l_indent number := 0;


 BEGIN

    l_immediate_parent_flag  := 'N';
    l_return_status          := fnd_api.g_ret_sts_success;

   -- if no group id is passed in then raise error
   IF p_group_id IS NOT NULL
   THEN

  --fetch the start date and the end date for the group
   OPEN c_date(p_group_id);
   FETCH c_date INTO l_start_date, l_end_date;
   CLOSE c_date;



  --get all the child groups for this group

   POPULATE_CHILD_TABLE(p_group_id, l_start_date, l_end_date, 1);
   l_child_tab := g_child_tab;

   FOR I IN 1 .. l_child_tab.COUNT
   LOOP


            --assign start date and end date for which this relation is valid

            l_usage_found := 1;
            if(p_usage is not null)
            then
                open c_check_usage(l_child_tab(i).p_group_id,
                                   p_usage);
                fetch c_check_usage into r_check_usage;
                if(c_check_usage%found)
                then
                     l_usage_found := 1;
                else
                     l_usage_found := 0;
                end if;
                close c_check_usage;
            end if;


           if(
               (l_usage_found = 1)
               )
           THEN
             --get audit report

                  open c_grp_child(l_child_tab(i).p_group_id,
                             p_usr_name,
                             p_start_date,
                             p_end_date);

                  fetch c_grp_child into r_grp_child;
                  if(c_grp_child%found)
                  then
                      l_indent := l_child_tab(i).level * 3 + 15;
                      fnd_file.put_line(fnd_file.log,lpad('Group name: ',l_indent,' ')||r_grp_child.group_name);
                      --<Start> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
                      IF (g_DFF_to_be_displayed)
                      THEN
                        get_DFF_output
                        (  r_grp_child.ATTRIBUTE_CATEGORY,
                           r_grp_child.ATTRIBUTE1,
                           r_grp_child.ATTRIBUTE2,
                           r_grp_child.ATTRIBUTE3,
                           r_grp_child.ATTRIBUTE4,
                           r_grp_child.ATTRIBUTE5,
                           r_grp_child.ATTRIBUTE6,
                           r_grp_child.ATTRIBUTE7,
                           r_grp_child.ATTRIBUTE8,
                           r_grp_child.ATTRIBUTE9,
                           r_grp_child.ATTRIBUTE10,
                           r_grp_child.ATTRIBUTE11,
                           r_grp_child.ATTRIBUTE12,
                           r_grp_child.ATTRIBUTE13,
                           r_grp_child.ATTRIBUTE14,
                           r_grp_child.ATTRIBUTE15,
                           l_indent - 12
                        );
                      END IF;
                      --<End> Introduced for incorporating reporting of DFF fields Ref: ER# 2549463
                      --fnd_file.put_line(fnd_file.log,'Level: '||l_child_tab(i).level);

                  end if;
                  while (c_grp_child%FOUND)
                  loop
                      if(r_grp_child.moved = 'OUT')
                       then
                          open  to_grp_cur( r_grp_child.group_id,
                                r_grp_child.resource_id)  ;
                          fetch to_grp_cur into to_grp_rec;
                          l_to_grp_number := to_grp_rec.group_number;
                          l_to_grp_name := to_grp_rec.group_name;
                          close to_grp_cur;
                       else
                         l_to_grp_number := null;
                         l_to_grp_name := null;
                      end if;

                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Resource Name: ',27, ' '),15+l_indent, ' ')||r_grp_child.resource_name);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Resource Number: ',27, ' '),15+l_indent, ' ')||r_grp_child.resource_number);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Category: ',27, ' '),15+l_indent, ' ')||r_grp_child.category_name);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Date: ',27, ' '),15+l_indent, ' ')||r_grp_child.creation_date);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Updated By: ',27, ' '),15+l_indent, ' ')||r_grp_child.created_by);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Action: ',27, ' '),15+l_indent, ' ')||r_grp_child.moved);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Moved From Group #:',27, ' '),15+l_indent, ' ')||r_grp_child.from_group_number);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Moved From Group Name:',27, ' '),15+l_indent, ' ')||r_grp_child.from_group_name);
                    --  fnd_file.put_line(fnd_file.log,lpad(rpad('  Moved To Group #:',27, ' '),15+l_indent, ' ')||r_grp_child.to_group_number);
                     -- fnd_file.put_line(fnd_file.log,lpad(rpad('  Moved to Group Name: ',27, ' '),15+l_indent, ' ')||r_grp_child.to_group_name);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Moved To Group #:',27, ' '),15+l_indent,' ')||l_to_grp_number);
                      fnd_file.put_line(fnd_file.log,lpad(rpad('  Moved to Group Name: ',27, ' '),15+l_indent,' ')||l_to_grp_name);
                      fnd_file.new_line(fnd_file.log, 1);
                      fetch c_grp_child into r_grp_child;

                  end loop; -- end of if
                  close c_grp_child;

           END IF; -- end of start date < end date check

   END LOOP;

 END IF; -- end of group_id not cull check
end child_groups;
end jtf_rs_group_report_pub;

/
