--------------------------------------------------------
--  DDL for Package Body HXC_OTL_INFO_TYPE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_OTL_INFO_TYPE_HELPER" AS
/* $Header: hxcinfotypehelp.pkb 120.2 2005/12/19 10:07:42 arundell noship $ */

  Type segment is record
    (name fnd_descr_flex_column_usages.end_user_column_name%type,
     column fnd_descr_flex_column_usages.application_column_name%type
     );

  Type segment_list is table of segment index by binary_integer;

  Function form_otl_context
     (p_context_prefix in varchar2,
      p_context_code   in varchar2)
   Return varchar2 is

  Begin
     return substr(p_context_prefix||' - '||p_context_code,1,30);
  End form_otl_context;

   Function form_long_otl_context
      (p_context_prefix in varchar2,
       p_context_code in varchar2)
      Return varchar2 is

      cursor get_max_sequence is
        select max(to_number(substrb(descriptive_flex_context_code,
                                     instr(descriptive_flex_context_code,'-')+2)))
          from fnd_descr_flex_contexts_vl
         where descriptive_flexfield_name = 'OTC Information Types'
           and application_id = 809
           and  substrb(descriptive_flex_context_code,0,
                        instr(descriptive_flex_context_code,'-')-2)
                =substrb(descriptive_flex_context_name,0,
                         instr(descriptive_flex_context_name,'-')-2)||'C';

      l_max_sequence number;
      l_long_context_code fnd_descr_flex_contexts.descriptive_flex_context_code%type;
      l_test_long_context fnd_descr_flex_contexts_tl.descriptive_flex_context_name%type;

   Begin

      l_test_long_context := hxc_deposit_wrapper_utilities.get_dupdff_code
                               (p_context_prefix||' - '||p_context_code);

      if(l_test_long_context <> p_context_prefix||' - '||p_context_code) then
         l_long_context_code := l_test_long_context;
      else
         open get_max_sequence;
         fetch get_max_sequence into l_max_sequence;
         if(get_max_sequence%notfound) then
            l_long_context_code := p_context_prefix||'C - 1';
         else
            l_long_context_code := p_context_prefix||'C - '||(l_max_sequence+1);
         end if;
         close get_max_sequence;

      end if;

      return l_long_context_code;

   End form_long_otl_context;

   function long_context_code
      (p_otc_appl_short_name in fnd_application.application_short_name%type,
       p_otc_flex_name in fnd_descriptive_flexs.descriptive_flexfield_name%type,
       p_context_prefix in varchar2,
       p_context_code in varchar2)
      return boolean is

      l_long boolean;

   begin
      l_long := false;

      if (fnd_flex_dsc_api.context_exists
            (p_appl_short_name=> p_otc_appl_short_name,
             p_flexfield_name=> p_otc_flex_name,
             p_context_code=>form_otl_context(p_context_prefix, p_context_code))
          )then
         l_long := false;
      else
         l_long := true;
      end if;

      if(
          (length(p_context_code) >= (30-(length(p_context_prefix)+3)))
        and
          (l_long)
        ) then
         l_long := true;
      else
         l_long := false;
      end if;

      return l_long;

   end long_context_code;

  function get_otl_flex
     (p_appl_short_name fnd_application.application_short_name%type,
      p_flexfield_name  fnd_descriptive_flexs.descriptive_flexfield_name%type
      )
     return fnd_dflex.dflex_r is

     l_flex      fnd_dflex.dflex_r;
     l_flex_info fnd_dflex.dflex_dr;

  Begin

     fnd_dflex.get_flexfield
        (appl_short_name => p_appl_short_name,
         flexfield_name => p_flexfield_name,
         flexfield => l_flex,
         flexinfo => l_flex_info);

     return l_flex;

  End get_otl_flex;

  Function get_otl_context
     (p_otl_flex in fnd_dflex.dflex_r,
      p_context_code in fnd_descr_flex_contexts.descriptive_flex_context_code%type
      )
     Return fnd_dflex.context_r is

  Begin
     return fnd_dflex.make_context
        (flexfield => p_otl_flex,
         context_code => p_context_code
         );
  End get_otl_context;

  Function otl_context_exists
     (p_otc_appl_short_name in fnd_application.application_short_name%type,
      p_otc_flex_name in fnd_descriptive_flexs.descriptive_flexfield_name%type,
      p_context_code in fnd_descr_flex_contexts.descriptive_flex_context_code%type)
   Return Boolean is
     l_exists boolean;
  Begin

     if FND_FLEX_DSC_API.context_exists
        (P_APPL_SHORT_NAME => p_otc_appl_short_name,
         P_FLEXFIELD_NAME => p_otc_flex_name,
         P_CONTEXT_CODE => p_context_code
         ) then
        l_exists := true;
     else
        l_exists := false;
     end if;

     return l_exists;
  End otl_context_exists;

  Function segment_lists_differ
     (p_list_a in segment_list,
      p_list_b in segment_list)
     Return Boolean is

     l_index   binary_integer;
     l_differ  boolean;

  Begin
     if(p_list_a.count <> p_list_b.count) then
        l_differ := true;
     else
        l_differ := false;
        l_index := p_list_a.first;
        Loop
           Exit when ((not p_list_a.exists(l_index)) or (l_differ));
           if(
              (p_list_a(l_index).name <> p_list_b(l_index).name)
             OR
              (p_list_a(l_index).column  <> p_list_b(l_index).column)
             ) then
              l_differ := true;
           end if;
           l_index := p_list_a.next(l_index);
        End Loop;

     end if;

     return l_differ;

  End segment_lists_differ;

  Procedure populate_segment_list
     (p_context in fnd_dflex.context_r,
      p_segment_list in out nocopy segment_list) is

     l_segments FND_DFLEX.segments_dr;
     l_segment_index NUMBER;
     l_index         binary_integer;

  Begin

     FND_DFLEX.get_Segments
        (context => p_context,
         segments => l_segments,
         enabled_only => FALSE);

     l_segment_index := l_segments.segment_name.first;
     l_index := p_segment_list.count;

     Loop
        exit when not l_segments.segment_name.exists(l_segment_index);
        l_index := l_index + 1;

        p_segment_list(l_index).name := l_segments.segment_name(l_segment_index);
        p_segment_list(l_index).column := l_segments.application_column_name(l_segment_index);

        l_segment_index := l_segments.segment_name.next(l_segment_index);

     End Loop;

  End populate_segment_list;

  Function build_otl_contexts
     (p_otc_appl_short_name  in fnd_application.application_short_name%type,
      p_otc_flex_name in fnd_descriptive_flexs.descriptive_flexfield_name%type,
      p_context_prefix in varchar2,
      p_flex in FND_DFLEX.dflex_r,
      p_contexts in FND_DFLEX.contexts_dr,
      p_context_index in number,
      p_global_context in FND_DFLEX.context_r,
      p_preserve in boolean)
   Return Boolean is

     l_build boolean;
     l_reference_segment_list segment_list;
     l_otl_segment_list segment_list;
     l_otl_context_code fnd_descr_flex_contexts.descriptive_flex_context_code%type;

  Begin

     if(long_context_code
           (p_otc_appl_short_name,
            p_otc_flex_name,
            p_context_prefix,
            p_contexts.context_code(p_context_index))
        ) then
        l_otl_context_code := form_long_otl_context(p_context_prefix,p_contexts.context_code(p_context_index));
     else
        l_otl_context_code := form_otl_context(p_context_prefix,p_contexts.context_code(p_context_index));
     end if;

     if(p_preserve) then
        l_build := true;
        if(otl_context_exists
             (p_otc_appl_short_name,
              p_otc_flex_name,
              l_otl_context_code)
           ) then
           --
           -- First Add the global segments to the reference segment list
           --
           populate_segment_list
              (p_global_context,
               l_reference_segment_list
               );
           --
           -- Next add the segments from this context to the reference list
           --
           populate_segment_list
              (fnd_dflex.make_context(p_flex,p_contexts.context_code(p_context_index)),
               l_reference_segment_list
               );
           --
           -- Next add the segments from the OTL context to the otl list
           --
           populate_segment_list
              (get_otl_context
                 (get_otl_flex(p_otc_appl_short_name,p_otc_flex_name),
                  l_otl_context_code),
               l_otl_segment_list
               );

           l_build := segment_lists_differ
                         (l_reference_segment_list,
                          l_otl_segment_list
                          );

        else -- The OTL context does not exist, we must create it
           l_build := true;
        end if;
     else -- Do we preserve the contexts
        l_build := true;
     end if;

     return l_build;

  End build_otl_contexts;

END hxc_otl_info_type_helper;

/
