--------------------------------------------------------
--  DDL for Package Body HXC_AP_DETAIL_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_AP_DETAIL_LINKS_PKG" as
/* $Header: hxcadtsum.pkb 120.2 2005/09/23 08:03:11 sechandr noship $ */

g_debug		BOOLEAN:= hr_utility.debug_enabled;
TYPE tbb_id_tab     IS TABLE OF hxc_time_building_blocks.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;
TYPE app_period_tab IS TABLE OF hxc_tc_ap_links.application_period_id%TYPE INDEX BY BINARY_INTEGER;

procedure insert_summary_row(p_application_period_id   in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_id  in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type) is

begin

--
-- 1. Remove any previous links between an earlier version
--    of the detail
--
  delete from hxc_ap_detail_links
   where time_building_block_id = p_time_building_block_id
     and application_period_id = p_application_period_id;
--
-- 2. Insert the new link
--

insert into hxc_ap_detail_links
(application_period_id
,time_building_block_id
,time_building_block_ovn
)
values
(p_application_period_id
,p_time_building_block_id
,p_time_building_block_ovn
);

end insert_summary_row;

procedure delete_summary_row(p_application_period_id   in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_id  in hxc_time_building_blocks.time_building_block_id%type
                            ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type) is

begin

delete from hxc_ap_detail_links
 where application_period_id = p_application_period_id
   and time_building_block_id = p_time_building_block_id
   and time_building_block_ovn = p_time_building_block_ovn;

end delete_summary_row;

procedure delete_ap_detail_links(p_application_period_id in hxc_time_building_blocks.time_building_block_id%type) is

begin

  delete from hxc_ap_detail_links where application_period_id = p_application_period_id;

end delete_ap_detail_links;


PROCEDURE bulk_delete ( p_application_period NUMBER
                      , p_tbb_id_tab     tbb_id_tab
                      , p_app_period_tab app_period_tab) IS

l_proc 	varchar2(72);

l_app_period_tab app_period_tab;

BEGIN

if g_debug then
	l_proc  := g_package||'bulk_delete';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

IF ( p_app_period_tab.COUNT = 0 )
THEN

     FOR x IN p_tbb_id_tab.FIRST .. p_tbb_id_tab.LAST
     LOOP

          l_app_period_tab(x) := p_application_period;

     END LOOP;

ELSE

     -- for first application period this is already populated

     l_app_period_tab := p_app_period_tab;

END IF;

FORALL i IN p_tbb_id_tab.FIRST .. p_tbb_id_tab.LAST
DELETE FROM hxc_ap_detail_links adl
WHERE       adl.application_period_id   = l_app_period_tab(i)
AND         adl.time_building_block_id  = p_tbb_id_tab(i);


END bulk_delete;

procedure delete_ap_detail_links(p_timecard_id in  number
                                ,p_blocks      in  hxc_block_table_type) IS

CURSOR csr_get_appl_period_id ( p_tbb_id NUMBER ) IS
SELECT tal.application_period_id
FROM   hxc_tc_ap_links tal
WHERE  tal.timecard_id = p_tbb_id;

l_index            PLS_INTEGER;
l_contiguous_index PLS_INTEGER;

l_application_period_id hxc_tc_ap_links.application_period_id%TYPE;

t_tbb_id      tbb_id_tab;
t_app_period  app_period_tab;

l_proc 	varchar2(72);

BEGIN
g_debug:=hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'delete_ap_detail_links';
	hr_utility.set_location('Entering '||l_proc, 10);
end if;

IF ( p_blocks.COUNT <> 0 )
THEN

    OPEN  csr_get_appl_period_id ( p_timecard_id );
    FETCH csr_get_appl_period_id INTO l_application_period_id;

    IF csr_get_appl_period_id%FOUND
    THEN

        -- now populate the bb id and bb ovn arrays in preparation for the bulk delete
        -- note we also populate the t_app_period array even though it can change.
        -- so we must also delete it if there is more than one application period
        -- for a timecard so we know to populate it again in the bulk_delete
        -- procedure (the bb and ovn arrays being static)

        l_index            := p_blocks.FIRST;
        l_contiguous_index := 1;

        WHILE l_index IS NOT NULL
        LOOP

              -- we only want to delete detail links for deleted blocks
              -- with non zero hours otherwise bug 3156317 happens again.

              IF (
                   ( FND_DATE.CANONICAL_TO_DATE( p_blocks(l_index).date_to) <> hr_general.end_of_time )
                   AND
                   (
                     ( ( NVL(p_blocks(l_index).measure,0) <> 0 ) AND p_blocks(l_index).type = 'MEASURE' )
                     OR
                     ( p_blocks(l_index).start_time IS NOT NULL )
                   )
                 )
              THEN

                   t_tbb_id    (l_contiguous_index) := p_blocks(l_index).time_building_block_id;
                   t_app_period(l_contiguous_index) := l_application_period_id;

                   l_contiguous_index := l_contiguous_index + 1;

               END IF;

               l_index            := p_blocks.NEXT(l_index);

        END LOOP;

        -- only delete if there are buildng blocks to delete

        IF ( t_tbb_id.COUNT > 0 )
        THEN

            WHILE csr_get_appl_period_id%FOUND
            LOOP

                bulk_delete ( l_application_period_id, t_tbb_id, t_app_period );

                FETCH csr_get_appl_period_id INTO l_application_period_id;

                t_app_period.DELETE;

            END LOOP;

            CLOSE csr_get_appl_period_id;

        END IF; -- t_tbb_id.COUNT > 0

        t_tbb_id.DELETE;

    END IF; -- csr_get_appl_period_id%FOUND

END IF; -- p_blocks.COUNT <> 0

if g_debug then
	hr_utility.set_location('Leaving '||l_proc, 20);
end if;

END delete_ap_detail_links;



procedure create_ap_detail_links(p_application_period_id in hxc_time_building_blocks.time_building_block_id%type) is

cursor c_app_period_info
        (p_application_period_id in hxc_time_building_blocks.time_building_block_id%type) is
  select resource_id
        ,start_time
        ,stop_time
    from hxc_app_period_summary
   where application_period_id = p_application_period_id;

cursor c_detail_info
        (p_rid in hxc_time_building_blocks.resource_id%type
        ,p_start_time in hxc_time_building_blocks.start_time%type
        ,p_stop_time in hxc_time_building_blocks.stop_time%type
        ) is
  select details.time_building_block_id
        ,details.object_version_number
    from hxc_time_building_blocks details, hxc_time_building_blocks days
   where days.resource_id = p_rid
     and trunc(days.stop_time) >= trunc(p_start_time)
     and trunc(days.start_time) <= trunc(p_stop_time)
     and days.scope = 'DAY'
     and days.date_to = hr_general.end_of_time
     and details.parent_building_block_id = days.time_building_block_id
     and details.parent_building_block_ovn = days.object_version_number
     and details.date_to = hr_general.end_of_time
     and details.scope = 'DETAIL';

l_resource_id hxc_time_building_blocks.resource_id%type;
l_start_time  hxc_time_building_blocks.start_time%type;
l_stop_time   hxc_time_building_blocks.stop_time%type;


begin

delete_ap_detail_links(p_application_period_id);

open c_app_period_info(p_application_period_id);
fetch c_app_period_info into l_resource_id, l_start_time, l_stop_time;
if (c_app_period_info%found) then

  for det_rec in c_detail_info(l_resource_id,l_start_time,l_stop_time) loop

    insert_summary_row(p_application_period_id,det_rec.time_building_block_id,det_rec.object_version_number);

  end loop;

end if;
close c_app_period_info;

end create_ap_detail_links;

end hxc_ap_detail_links_pkg;

/
