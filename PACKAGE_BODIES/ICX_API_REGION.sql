--------------------------------------------------------
--  DDL for Package Body ICX_API_REGION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_API_REGION" 
/* $Header: ICXREGB.pls 115.5 1999/12/09 22:54:05 pkm ship      $ */

is

    function create_main_region
    return number

    is
        l_region_id        icx_regions.region_id%type;

    begin

    -- Generate the region id
    select icx_regions_s.nextval
    into l_region_id
    from sys.dual;

    -- Insert a record into the region table
    -- For the the parent_id is 0
    -- and the region is not split
    insert into icx_regions
    (
        region_id,
        parent_region_id,
        split_mode,
        portlet_flow,
        border,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
	last_update_login
    )
    values
    (
        l_region_id,
        MAIN_REGION,
        REGION_NOT_SPLIT,
        REGION_HORIZONTAL_PORTLETFLOW,
        'Y',
	sysdate,
	icx_sec.g_user_id,
	sysdate,
	icx_sec.g_user_id,
	icx_sec.g_user_id
    );

    commit;
    return l_region_id;

    exception
    when REGION_VALIDATION_EXCEPTION then
        raise;

    when DUP_VAL_ON_INDEX then
        rollback;
        htp.p(SQLERRM);

    when OTHERS then
        rollback;
        htp.p(SQLERRM);

    end create_main_region;



    procedure split_region (
        p_region_id      in integer
    ,   p_split_mode     in number
    )
    is

    l_region        icx_regions%rowtype;
    l_parent_region icx_regions%rowtype;
    l_new_region_id number;

    begin

    -- Security Check

    -- Get the record for the region to be split
    select * into l_region
    from icx_regions
    where region_id = p_region_id;

    -- If the region is already split in one direction then
    -- do not change that
    -- mbuk do we need this check.
    -- if ( l_region.split_mode = REGION_HORIZONTAL_SPLIT and
    --      p_split_mode = REGION_VERTICAL_SPLIT )   or
    --    ( l_region.split_mode = REGION_VERTICAL_SPLIT and
    --      p_split_mode = REGION_HORIZONTAL_SPLIT ) then

    --    wwerr_api_error.add(wwerr_api_error.DOMAIN_WWC,
    --                        'pob', 'reg_split',
    --                        'wwpob_api_region.split_region');
    --    raise REGION_VALIDATION_EXCEPTION;
    --end if;


    -- Check if it has a parent ( or is it the main region )
    if l_region.parent_region_id = MAIN_REGION then

        if l_region.split_mode = REGION_NOT_SPLIT then

            select icx_regions_s.nextval into l_new_region_id from sys.dual;

            insert into icx_regions
            (
                region_id,
                parent_region_id,
                split_mode,
                portlet_flow,
                border,
	        last_update_date,
   		last_updated_by,
        	creation_date,
        	created_by,
        	last_update_login
            )
            values
            (
                l_new_region_id,
                l_region.region_id,
                REGION_NOT_SPLIT,
                l_region.portlet_flow,
                l_region.border,
		sysdate,
		icx_sec.g_user_id,
		sysdate,
		icx_sec.g_user_id,
		icx_sec.g_user_id
            );

           update icx_page_plugs
              set region_id = l_new_region_id
            where region_id = p_region_id;

        end if;

        select icx_regions_s.nextval into l_new_region_id from sys.dual;

        insert into icx_regions
        (
            region_id,
            parent_region_id,
            split_mode,
            portlet_flow,
            border,
	    last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login
        )
        values
        (
            l_new_region_id,
            l_region.region_id,
            REGION_NOT_SPLIT,
            l_region.portlet_flow,
            l_region.border,
	    sysdate,
	    icx_sec.g_user_id,
	    sysdate,
	    icx_sec.g_user_id,
	    icx_sec.g_user_id
        );

        update icx_regions
           set split_mode = p_split_mode
         where region_id  = l_region.region_id;

        commit;

    -- For all other regions
    else

        select * into l_parent_region
        from icx_regions
        where region_id = l_region.parent_region_id;

            -- Check if the parent region was already split
        if ( l_parent_region.split_mode = REGION_HORIZONTAL_SPLIT and p_split_mode = REGION_HORIZONTAL_SPLIT )
             or ( l_parent_region.split_mode = REGION_VERTICAL_SPLIT and p_split_mode = REGION_VERTICAL_SPLIT ) then

            select icx_regions_s.nextval into l_new_region_id from sys.dual;

            -- Insert a row into icx_regions for the new region
            insert into icx_regions
            (
                region_id,
                parent_region_id,
                split_mode,
                portlet_flow,
                border,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login
            )
            values
            (
                l_new_region_id,
                l_region.parent_region_id,
                REGION_NOT_SPLIT,
                l_region.portlet_flow,
                l_region.border,
		sysdate,
		icx_sec.g_user_id,
		sysdate,
		icx_sec.g_user_id,
		icx_sec.g_user_id
            );

            -- don't want to move plug data from the existing region.
            --update icx_page_plugs
            --   set region_id = l_new_region_id
            -- where region_id = p_region_id;

        -- If the parent region was not split then update the flag in icx_regions for the parent
        elsif p_split_mode = REGION_HORIZONTAL_SPLIT then

            if l_region.split_mode = REGION_NOT_SPLIT then

                select icx_regions_s.nextval into l_new_region_id from sys.dual;

                insert into icx_regions
                (
                    region_id,
                    parent_region_id,
                    split_mode,
                    portlet_flow,
                    border,
		    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login
                )
                values
                (
                    l_new_region_id,
                    p_region_id,
                    REGION_NOT_SPLIT,
                    l_region.portlet_flow,
                    l_region.border,
		    sysdate,
		    icx_sec.g_user_id,
		    sysdate,
		    icx_sec.g_user_id,
		    icx_sec.g_user_id
                );

                update icx_page_plugs
                   set region_id = l_new_region_id
                 where region_id = p_region_id;

            end if;

            insert into icx_regions
            (
                region_id,
                parent_region_id,
                split_mode,
                portlet_flow,
                border,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login
            )
            values
            (
                icx_regions_s.nextval,
                p_region_id,
                REGION_NOT_SPLIT,
                l_region.portlet_flow,
                l_region.border,
		sysdate,
		icx_sec.g_user_id,
		sysdate,
		icx_sec.g_user_id,
		icx_sec.g_user_id
            );

            update icx_regions
            set split_mode = REGION_HORIZONTAL_SPLIT
            where region_id       = p_region_id;


        elsif p_split_mode = REGION_VERTICAL_SPLIT then

            select icx_regions_s.nextval into l_new_region_id from sys.dual;

            if l_region.split_mode = REGION_NOT_SPLIT then
                insert into icx_regions
                (
                    region_id,
                    parent_region_id,
                    split_mode,
                    portlet_flow,
                    border,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login
                )
                values
                (
                    l_new_region_id,
                    p_region_id,
                    REGION_NOT_SPLIT,
                    l_region.portlet_flow,
                    l_region.border,
		    sysdate,
		    icx_sec.g_user_id,
		    sysdate,
		    icx_sec.g_user_id,
		    icx_sec.g_user_id
                );

                update icx_page_plugs
                   set region_id = l_new_region_id
                 where region_id = p_region_id;

            end if;

            insert into icx_regions
            (
                region_id,
                parent_region_id,
                split_mode,
                portlet_flow,
                border,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login
            )
            values
            (
                icx_regions_s.nextval,
                p_region_id,
                REGION_NOT_SPLIT,
                l_region.portlet_flow,
                l_region.border,
		sysdate,
		icx_sec.g_user_id,
		sysdate,
		icx_sec.g_user_id,
		icx_sec.g_user_id
            );

            update icx_regions
            set split_mode = REGION_VERTICAL_SPLIT
            where region_id       = p_region_id;

            end if;
            commit;
    end if;

    exception
    when REGION_VALIDATION_EXCEPTION then
        raise;
    when NO_DATA_FOUND then
        htp.p(SQLERRM);
        raise;
    when DUP_VAL_ON_INDEX then
        rollback;
        htp.p(SQLERRM);
        raise;

    when OTHERS then
        rollback;
        htp.p(SQLERRM);
        raise;

    end split_region;



    procedure delete_region (
        p_region_id in integer
    )

    is

    l_count              number     := 0;
    l_parent_region_id   integer    := p_region_id;
    l_split_mode         number     := REGION_NOT_SPLIT;
    l_region_sibling_id  number     := 0;

    cursor child_regions is
        select region_id
          from icx_regions
         where parent_region_id = p_region_id;

    begin

    -- get the parent for the region to be deleted
    select parent_region_id
      into l_parent_region_id
      from icx_regions
     where region_id = p_region_id;

    -- Delete plugs, if any, associated with the children of the region being deleted
    for region_record in child_regions loop
        delete from icx_page_plugs
         where region_id = region_record.region_id;
    end loop;

    -- Delete any child regions
    delete from icx_regions
    where parent_region_id = p_region_id;

    -- delete plugs for the region to be deleted
    delete from icx_page_plugs
     where region_id = p_region_id;

    -- When deleting a region, check if it is the only child of the parent
    select count(region_id)
      into l_count
      from icx_regions
     where parent_region_id = l_parent_region_id;

    -- If it is the only region
    if l_count = 1 then

        -- Delete the region
        delete from icx_regions
        where region_id = p_region_id;

        -- Update the parent splig flag
        update icx_regions
           set split_mode = REGION_NOT_SPLIT
         where region_id  = l_parent_region_id;


    -- If the parent of the region being deleted has 2 regions, then
    -- delete both of them, but only if the other one (sibling) is not split.
    -- If the sibling region is to be delete then move the content of the
    -- sibling region to the parent region.

    elsif l_count = 2 then

        select split_mode, region_id
          into l_split_mode, l_region_sibling_id
          from icx_regions
         where parent_region_id = l_parent_region_id
           and region_id <> p_region_id;

        if l_split_mode = REGION_NOT_SPLIT then

            -- Delete both the regions
            delete from icx_regions
            where parent_region_id = l_parent_region_id;

             -- Update the parent split flag
            update icx_regions
            set split_mode  = REGION_NOT_SPLIT
            where region_id = l_parent_region_id;

            -- if the sibling had any plugs in it then they should
            -- be transferred to the parent.
            update icx_page_plugs
               set region_id = l_parent_region_id
             where region_id = l_region_sibling_id;

        else
            -- Delete only the region
            delete from icx_regions
            where region_id = p_region_id;
        end if;

    else
        -- Delete only the region
        delete from icx_regions
        where region_id = p_region_id;
    end if;

    commit;

    exception
    when REGION_VALIDATION_EXCEPTION then
        raise;

    when NO_DATA_FOUND then
        htp.p(SQLERRM);
        raise;

    when OTHERS then
        rollback;
        htp.p(SQLERRM);
        raise;

    end delete_region;



    function get_region (
        p_region_id     in integer
    )
    return region_record

    is
    l_region    region_record;

    begin

    -- Security Check

    select
        region_id,
        parent_region_id,
        split_mode,
        portlet_alignment,
        height,
        width,
        width_restrict,
        portlet_flow,
        navwidget_id,
        border
    into
        l_region.region_id,
        l_region.parent_region_id,
        l_region.split_mode,
        l_region.portlet_alignment,
        l_region.height,
        l_region.width,
        l_region.width_restrict,
        l_region.portlet_flow,
        l_region.navwidget_id,
        l_region.border
    from icx_regions
    where region_id = p_region_id;

    return l_region;

    exception
    when NO_DATA_FOUND then
        return null;

    end get_region;



    function add_region (
        p_region    in region_record
    )
    return integer

    is

    l_region_id        icx_regions.region_id%type;

    begin

    -- Security Check

    -- Validate the record fields

    -- Generate the region id
    select icx_regions_s.nextval
    into l_region_id
    from sys.dual;

    insert into icx_regions
    (
        region_id,
        parent_region_id,
        split_mode,
        width,
        height,
        portlet_alignment,
        width_restrict,
        portlet_flow,
        navwidget_id,
        border,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login
    )
    values
    (
        l_region_id,
        p_region.parent_region_id,
        p_region.split_mode,
        p_region.width,
        p_region.height,
        p_region.portlet_alignment,
        p_region.width_restrict,
        p_region.portlet_flow,
        p_region.navwidget_id,
        p_region.border,
	sysdate,
	icx_sec.g_user_id,
	sysdate,
	icx_sec.g_user_id,
	icx_sec.g_user_id
    );

    commit;
    return l_region_id;

    exception
    when DUP_VAL_ON_INDEX then
        rollback;
        htp.p(SQLERRM);
        raise;

    when OTHERS then
        rollback;
        htp.p(SQLERRM);
        raise;

    end add_region;



    procedure edit_region (
        p_region    in region_record
    )

    is

    begin

    update icx_regions
    set     parent_region_id   = p_region.parent_region_id,
            split_mode         = p_region.split_mode,
            width              = p_region.width,
            height             = p_region.height,
            portlet_alignment  = p_region.portlet_alignment,
            width_restrict     = p_region.width_restrict,
            portlet_flow       = 0,      -- we are not using p_region.portlet_flow,
            navwidget_id       = p_region.navwidget_id,
            border             = p_region.border
    where region_id = p_region.region_id;

    -- mbuk.  Do we need to add this back?
    --if sql%rowcount = 0 then
    --    wwerr_api_error.add(wwerr_api_error.DOMAIN_WWC,
    --                        'pob', 'reg_notfound',
    --                        'wwpob_api_region.edit_region');
    --    raise REGION_VALIDATION_EXCEPTION;
    --end if;

    commit;

    end edit_region;



    function get_child_region_list (
        p_region_id in integer
    )
    return region_table

    is

    l_region_list   region_table;
    l_index number  := 0;

    begin

    -- Security Check

    for x in (select * from icx_regions where parent_region_id = p_region_id) loop

        l_index := l_index + 1;

        l_region_list(l_index).region_id           :=  x.region_id;
        l_region_list(l_index).parent_region_id    :=  x.parent_region_id;
        l_region_list(l_index).split_mode          :=  x.split_mode;
        l_region_list(l_index).portlet_alignment   :=  x.portlet_alignment;
        l_region_list(l_index).height              :=  x.height;
        l_region_list(l_index).width               :=  x.width;
        l_region_list(l_index).width_restrict      :=  x.width_restrict;
        l_region_list(l_index).portlet_flow        :=  x.portlet_flow;
        l_region_list(l_index).border              :=  x.border;

    end loop;

    return l_region_list;

    exception

    when OTHERS then
        htp.p(SQLERRM);
        raise;

    end get_child_region_list;



    procedure delete_regions (
        p_layout_id in integer
    )

    is

    l_count number  := 0;

    begin

    null;
    --**** Need to completely rewrite this.
    -- Need this for when a page is deleted. mbuk

    -- Security Check

    -- Check if the page exists
    --if not wwpob_api_layout.is_layout(p_layout_id) then
    --    wwerr_api_error.add(wwerr_api_error.DOMAIN_WWC,
    --                        'pob', 'lay_notfound',
    --                        'wwpob_api_region.delete_regions');
    --    raise REGION_VALIDATION_EXCEPTION;
    --end if;

    --for x in (select * from icx_regions where region_id = p_page_id )
    --loop
        -- Delete the translations for strings
    --    l_count := wwnls_api.remove_string(x.title_id, TRUE);
    --end loop;

    -- Delete all regions for a layout
    --delete from icx_regions
    --where layout_id = p_layout_id;

    --commit;

   -- exception
   -- when REGION_VALIDATION_EXCEPTION then
   --     raise;

    end delete_regions;


    --procedure get_region_list (p_region_id) is
    --    select region_id
    --      from icx_regions
    --     start with region_id = p_region_id
    --   connect by prior region_id = parent_region_id;

    procedure copy_region_plugs (p_from_region_id in number,
                                 p_to_region_id   in number,
                                 p_to_page_id     in number)
    is

    l_plug_id  number;
    cursor plugs_to_be_copied is
      select *
        from icx_page_plugs
       where region_id = p_from_region_id;

    begin

       for thisplug in plugs_to_be_copied loop

  	   select icx_page_plugs_s.nextval into l_plug_id from dual;

	   insert into ICX_PAGE_PLUGS
	           (PLUG_ID,
		    PAGE_ID,
		    DISPLAY_SEQUENCE,
		    RESPONSIBILITY_APPLICATION_ID,
		    SECURITY_GROUP_ID,
		    RESPONSIBILITY_ID,
		    MENU_ID,
		    ENTRY_SEQUENCE,
		    DISPLAY_NAME,
		    REGION_ID,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login)
	   values
		   (l_plug_id,
		    p_to_page_id,
		    thisplug.DISPLAY_SEQUENCE,
		    thisplug.RESPONSIBILITY_APPLICATION_ID,
		    thisplug.SECURITY_GROUP_ID,
		    thisplug.RESPONSIBILITY_ID,
		    thisplug.MENU_ID,
		    thisplug.ENTRY_SEQUENCE,
		    thisplug.DISPLAY_NAME,
                    p_to_region_id,
		    sysdate,
		    icx_sec.g_user_id,
		    sysdate,
		    icx_sec.g_user_id,
		    icx_sec.g_user_id);
       end loop;

    exception
       when others then
            htp.p(SQLERRM);
    end;


    procedure copy_child_regions (
        p_from_region_id    in number
    ,   p_to_region_id      in number
    ,   p_to_page_id        in number
    )

    is

    l_region_id  icx_regions.region_id%type;
    l_region     icx_regions%rowtype;

    begin

    -- Security

    for x in (select * from icx_regions where parent_region_id = p_from_region_id) loop

        select * into l_region
        from icx_regions
        where region_id = p_to_region_id;

        -- Insert a new record and copy the attributes
        select icx_regions_s.nextval
        into l_region_id
        from sys.dual;

	insert into icx_regions
	(
		region_id,
		parent_region_id,
		split_mode,
		width,
		height,
		portlet_alignment,
		width_restrict,
		portlet_flow,
		navwidget_id,
                border,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login
	)
	values
	(
		l_region_id,
		l_region.region_id,
		x.split_mode,
		x.width,
		x.height,
		x.portlet_alignment,
		x.width_restrict,
		x.portlet_flow,
		x.navwidget_id,
                x.border,
		sysdate,
		icx_sec.g_user_id,
		sysdate,
		icx_sec.g_user_id,
		icx_sec.g_user_id
	);

        copy_child_regions(x.region_id, l_region_id, p_to_page_id);

    end loop;

    copy_region_plugs(p_from_region_id, p_to_region_id, p_to_page_id);

    commit;

    exception
    when REGION_VALIDATION_EXCEPTION then
        raise;

    when NO_DATA_FOUND then
        htp.p(SQLERRM);
        raise;

    when DUP_VAL_ON_INDEX then
        rollback;
        htp.p(SQLERRM);
        raise;

    when OTHERS then
        rollback;
        htp.p(SQLERRM);
        raise;

    end copy_child_regions;

/**************************************************************************
        GET_MAIN_REGION
***************************************************************************/

    function get_main_region_record (
        p_region_id in integer
    )
    return icx_api_region.region_record

    is

    l_region    icx_api_region.region_record;

    begin

    select
        region_id,
        parent_region_id,
        split_mode,
        portlet_alignment,
        height,
        width,
        width_restrict,
        portlet_flow,
        navwidget_id,
        border
    into
        l_region.region_id,
        l_region.parent_region_id,
        l_region.split_mode,
        l_region.portlet_alignment,
        l_region.height,
        l_region.width,
        l_region.width_restrict,
        l_region.portlet_flow,
        l_region.navwidget_id,
        l_region.border
    from icx_regions
    where region_id = p_region_id;

    return l_region;

    exception
      when others then
           htp.p(SQLERRM);
    end get_main_region_record;


end ICX_API_REGION;

/
