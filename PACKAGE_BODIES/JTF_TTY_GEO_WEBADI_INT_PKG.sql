--------------------------------------------------------
--  DDL for Package Body JTF_TTY_GEO_WEBADI_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_GEO_WEBADI_INT_PKG" AS
/* $Header: jtfgtwpb.pls 120.4 2005/09/26 21:08:50 vbghosh ship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to return a list of column in order of selectivity.
--      And create indices on columns in order of  input
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/02/2002    SHLI        Created
--      12/22/2003    ACHANDA     Modified to insert record in jtf_tty_named_acct_changes
--                                so that GTP can perform increamental processing
--      12/30/2003    SGKUMAR     Modified to show data for the active territory
--                                groups
--      01/02/2004    SGKUMAR     Modified update_geo_terr to check if Postal Code
--                                is being assigned to geo territory for the appropriate
--                                parent territory.
--    01/07/2004    SGKUMAR       Modified POPULATE_INTERFACE to retrieve PCs based on
--                                geo name ranges instead of geo id range for postal code
--                                ranges for geo terr group. Modified UPDATE_GEO_TERR also.
--    09/26/2005   VBGHOSH       Added code to create corresponding values in terr_q
--								 uall_all and terr_values_all table
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************


 procedure POPULATE_INTERFACE(         p_userid         in varchar2,
                                       p_geoterrlist    in varchar2,
                                       x_seq            out NOCOPY varchar2) IS


--RESOURCE_NAME           VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
--                                                 null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
GEO_TERR_LIST           VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,
                                                 null,null,null,null,null,null,null,null,null,null);
-- GEO_SIGN_FLAG           VARRAY_TYPE:=VARRAY_TYPE(null,null,null,null,null,null,null,null,null,null,
--                                                 null,null,null,null,null,null,null,null,null,null);
-- COL_USED                NARRAY_TYPE:=NARRAY_TYPE(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

salesMgr                NUMBER;
SEQ     	            NUMBER;
ID	                    NUMBER;
user_id                 NUMBER;
l_rsc_id                NUMBER;
L_PARENT_TERR_ID        NUMBER;
l_var1                  VARCHAR2(100);
l_var2                  VARCHAR2(100);
l_v                     VARCHAR2(1);
i                       NUMBER;
j                       NUMBER;
k                       NUMBER;
geoterrnum              NUMBER;


--TYPE RefCur IS REF CURSOR;  -- define weak REF CURSOR type
--nastat   RefCur;  -- declare cursor variable
--na       RefCur;  -- declare cursor variable



    CURSOR signed_nd_terr_pc(terr_id IN number) IS
    select tg.terr_group_name territory_group,
           pterr.geo_terr_name manager_terr_name,
           g.country_code country,
           g.State_code state_province,
           g.City_code city,
           g.postal_code postal_code,
           terr.geo_terr_name geo_terr_name,
           terrv.geo_terr_value_id tv_id
    from  jtf_tty_geographies     g,
          jtf_tty_geo_terr        terr,
          jtf_tty_geo_terr        pterr,
          jtf_tty_geo_terr_values terrv,
          jtf_tty_terr_groups     tg
    where     terrv.geo_territory_id  = terr_id
          and terrv.geo_territory_id  = terr.geo_territory_id
          and terr.parent_geo_terr_id = pterr.geo_territory_id(+)
          and terrv.geo_id            = g.geo_id
          and terr.terr_group_id      = tg.terr_group_id;




    CURSOR getDefTerrGeo(terr_id IN number) IS
    select grpv.comparison_operator, grpv.geo_id_from, grpv.geo_id_to,
           tg.terr_group_name territory_group,
           pterr.geo_terr_name manager_terr_name,
           terr.geo_terr_name geo_terr_name
    from   jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups       tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geo_terr        pterr
    where      terr.geo_territory_id =terr_id
           and terr.terr_group_id = tg.terr_group_id
           and terr.terr_group_id = grpv.terr_group_id
           and terr.parent_geo_terr_id = pterr.geo_territory_id(+);


CURSOR unsigned_terr_pc(l_rsc_id IN number) IS
select  *
 from(
    /* postal code = */
    select tg.terr_group_name  territory_group,
           terr.geo_terr_name  manager_terr_name, /* the parent terr name */
           g.country_code      country,
           g.State_code        state_province,
           g.City_code         city,
           g.postal_code       postal_code,
           null                terr_name,
           g.geo_id            geo_id
    from   jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geo_terr_rsc    rsc,
           jtf_tty_geographies     g   --postal_code level
    where
               rsc.resource_id         = l_rsc_id -- user works in this geo terr
           and rsc.geo_territory_id    = terr.geo_territory_id
           and terr.terr_group_id      = tg.terr_group_id
           and terr.terr_group_id      = grpv.terr_group_id
           and terr.owner_resource_id  < 0
           and terr.parent_geo_terr_id < 0 -- default terr
           and SYSDATE BETWEEN tg.active_from_date AND NVL(tg.active_to_date, SYSDATE+1)
           and grpv.geo_type = 'POSTAL_CODE'
           and grpv.comparison_operator = '='
           and g.geo_id = grpv.geo_id_from
           and g.geo_type = 'POSTAL_CODE'
    union
    /* postal code range*/
    select tg.terr_group_name  territory_group,
           terr.geo_terr_name  manager_terr_name, /* the parent terr name */
           g.country_code      country,
           g.State_code        state_province,
           g.City_code         city,
           g.postal_code       postal_code,
           null                terr_name,
           g.geo_id            geo_id
    from   jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geo_terr_rsc    rsc,
           jtf_tty_geographies     g,   --postal_code level
           jtf_tty_geographies g1,
           jtf_tty_geographies g2
    where
               rsc.resource_id         = l_rsc_id -- user works in this geo terr
           and rsc.geo_territory_id    = terr.geo_territory_id
           and terr.terr_group_id      = tg.terr_group_id
           and terr.terr_group_id      = grpv.terr_group_id
           and terr.owner_resource_id  < 0
           and terr.parent_geo_terr_id < 0 -- default terr
           and SYSDATE BETWEEN tg.active_from_date AND NVL(tg.active_to_date, SYSDATE+1)
           and      grpv.geo_type = 'POSTAL_CODE'
           and grpv.comparison_operator = 'BETWEEN'
           and g.geo_type = 'POSTAL_CODE'
           AND    g1.geo_id = grpv.geo_id_from
           AND    g2.geo_id =  grpv.geo_id_to
           AND    g.geo_name BETWEEN g1.geo_name and g2.geo_name
    union
    select tg.terr_group_name  territory_group,
           terr.geo_terr_name  manager_terr_name, /* the parent terr name */
           g.country_code      country,
           g.State_code        state_province,
           g.City_code         city,
           g.postal_code       postal_code,
           null                terr_name,
           g.geo_id            geo_id
    from   jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geo_terr_rsc    rsc,
           jtf_tty_geographies     g,
           jtf_tty_geographies     g1
    where
               rsc.resource_id         = l_rsc_id -- user works in this geo terr
           and rsc.geo_territory_id    = terr.geo_territory_id
           and terr.terr_group_id      = tg.terr_group_id
           and terr.terr_group_id      = grpv.terr_group_id
           and terr.owner_resource_id  < 0
           and terr.parent_geo_terr_id < 0 -- default terr
           and SYSDATE BETWEEN tg.active_from_date AND NVL(tg.active_to_date, SYSDATE+1)
           and (
                  (
                    grpv.geo_type = 'STATE'
                    and g1.geo_id = grpv.geo_id_from
                    and g.STATE_CODE = g1.state_Code
                    and g.country_code = g1.country_Code
                    and g.geo_type = 'POSTAL_CODE'
                  )
                  or
                  ( grpv.geo_type = 'CITY'
                    AND  g.geo_type = 'POSTAL_CODE'
                    AND  g.country_code = g1.country_code
                    AND (
                           (g.state_code = g1.state_code AND g1.province_code is null)
                            or
                           (g1.province_code = g.province_code AND g1.state_code is null)
                         )
                    AND    (g1.county_code is null or g.county_code = g1.county_code)
                    AND    g.city_code = g1.city_code
                    AND    grpv.geo_id_from = g1.geo_id
                  )
                  or
                  (
                           grpv.geo_type = 'COUNTRY'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
                  )
                  or
                  (
                           grpv.geo_type = 'PROVINCE'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type = 'POSTAL_CODE'
                    AND    g.country_code = g1.country_code
                    AND    g.province_code = g1.province_code
                  )
                )
    union
    select tg.terr_group_name  territory_group,
           terr.geo_terr_name  manager_terr_name, /* the parent terr name */
           g.country_code   country,
           g.State_code     state_province,
           g.City_code      city,
           g.postal_code    postal_code,
           null                terr_name,
           g.geo_id         geo_id
    from   jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geo_terr_rsc    rsc,
           jtf_tty_geographies     g,
           jtf_tty_geo_terr_values tv
    where
               rsc.resource_id         = l_rsc_id
           and rsc.geo_territory_id    = terr.geo_territory_id
           and terr.terr_group_id      = tg.terr_group_id
           and terr.owner_resource_id  >= 0
           and terr.parent_geo_terr_id >= 0 -- not default terr
           and tv.geo_territory_id     = terr.geo_territory_id
           and g.geo_id                = tv.geo_id
           and SYSDATE BETWEEN tg.active_from_date AND NVL(tg.active_to_date, SYSDATE+1)
 )
 where  geo_id not in -- the terr the user owners
 (
    select tv.geo_id geo_id
    from   jtf_tty_geo_terr        terr,
           jtf_tty_geo_terr_values tv
    where
           terr.owner_resource_id  = l_rsc_id
           and tv.geo_territory_id = terr.geo_territory_id
  );


BEGIN

    -- remove existing old data for this userid
    delete from JTF_TTY_GEO_WEBADI_INTERFACE
    where user_id = p_userid
    and sysdate - creation_date >2;

    select jtf_tty_geo_int_s.nextval into SEQ from dual;

    select count(*) into id from JTF_TTY_GEO_WEBADI_INTERFACE;
    if id=0 then id:=1;
    else select max(id)+1 into id from JTF_TTY_GEO_WEBADI_INTERFACE;
    end if;

    user_id := to_number(p_userid);

    begin
      select resource_id into l_rsc_id from jtf_rs_resource_extns
      where user_id = p_userid;

     exception
           when no_data_found then
            x_seq := '-100';
            return;
    end;

    -- p_geoterrlist in format of: a,bb,ac,ddd,ee,ffff,
    geoterrnum := 0;
    k:=1; -- search start
    j:=1; -- index
    while j>0 loop
      j:= instr(p_geoterrlist,',',k);
      if j>0 then geoterrnum := geoterrnum+1;
                  GEO_TERR_LIST(geoterrnum) := substr(p_geoterrlist,k,j-k);
                  -- GEO_SIGN_FLAG(geoterrnum) := substr(p_geoterrlist,j-1,1);
                  k := j+1;
      end if;
    end loop;


    -- dbms_output.put_line(l_na_query);
    -- insert into tmp values(GEO_SIGN_FLAG(i), ''); commit;

    for i in 1..geoterrnum loop
    -- insert into tmp values(GEO_TERR_LIST(i),'no sign'); commit;
       if GEO_TERR_LIST(i)<0 then -- unsigned geo terr -999999
             /* find the pc from all terr the user works in, minus
                the pc from all terr the user owners */

             FOR pc IN unsigned_terr_pc(l_rsc_id)
                     LOOP
                            INSERT INTO JTF_TTY_GEO_WEBADI_INTERFACE(jtf_tty_webadi_int_id, object_version_number,
                                                                     user_id, user_sequence, territory_group,
                                                                     manager_terr_name, country, state_province,
                                                                     city, postal_code, geo_terr_name,geo_terr_value_id,
                                                                     created_by,creation_date, last_updated_by,
                                                                     last_update_date, last_update_login )
                                   VALUES(id, 1, user_id, SEQ, pc.territory_group,
                                          pc.manager_terr_name, pc.country, pc.state_province,
                                          pc.city, pc.postal_code, null, null,
                                          user_id, sysdate,user_id, sysdate,user_id);
                           -- insert into tmp values('two','two'); commit;
                           id := id+1;
                           EXIT WHEN unsigned_terr_pc%NOTFOUND;
                     END LOOP;


       ------------------------------------------------------------------------------------------------------
       else
             FOR pc IN signed_nd_terr_pc(to_number(GEO_TERR_LIST(i)))
             LOOP
             --insert into tmp values(GEO_TERR_LIST(i)||'value', pc.postal_code); commit;
                  INSERT INTO JTF_TTY_GEO_WEBADI_INTERFACE(jtf_tty_webadi_int_id, object_version_number,
                                                           user_id, user_sequence, territory_group,
                                                           manager_terr_name, country, state_province,
                                                           city, postal_code, geo_terr_name, geo_terr_value_id,
                                                           created_by, creation_date, last_updated_by,
                                                           last_update_date, last_update_login )
                               VALUES(id, 1, user_id, SEQ, pc.territory_group,
                                      pc.manager_terr_name, pc.country, pc.state_province,
                                      pc.city, pc.postal_code, pc.geo_terr_name,pc.tv_id,user_id,
                                      sysdate,user_id, sysdate,user_id);
                  id := id+1;
                  EXIT WHEN signed_nd_terr_pc%NOTFOUND;
              END LOOP; -- of fetch
         --end if; -- l_v='Y'
       end if;
    END LOOP; -- of for

    commit;

    x_seq := to_char(SEQ);

 END;




procedure isDefaultTerr(terr_id IN number, flag out NOCOPY varchar2) IS


l_num number;
begin
   select count(*) into l_num
   from jtf_tty_geo_terr
   where geo_territory_id = terr_id
         and owner_resource_id<0
         and parent_geo_terr_id<0;


   if l_num>0 then flag :='Y';
   else flag :='N';
   end if;

end;



procedure UPDATE_GEO_TERR   (      --p_user_sequence      in varchar2,
                                   p_terrgroup          in varchar2,
                                   p_manager_terr_name  in varchar2,
                                   p_country            in varchar2,
                                   p_state_province     in varchar2,
                                   p_city               in varchar2,
                                   p_postal_code        in varchar2,
                                   p_geo_terr_name      in varchar2,
                                   p_geo_terr_value_id  in varchar2,
                                   p_userid             in varchar2
                            ) IS

  -- Check if the PC is in default terr the user works in
  CURSOR CheckPCInDefTerr(rsc_id IN NUMBER, p_pc varchar2) IS
  select   count(g.postal_code) exist --, terr.geo_territory_id terr_id
  --grpv.comparison_operator, grpv.geo_type, grpv.geo_id_from, geo_id_to, terr.geo_territory_id terr_id
  from     jtf_tty_geo_terr       terr,
           jtf_tty_geo_terr_rsc   rsc,
           jtf_tty_geo_grp_values grpv,
           jtf_tty_geographies    g
  where        rsc_id = rsc.resource_id
           and rsc.geo_territory_id = terr.geo_territory_id
           and terr.owner_resource_id <0
           and terr.parent_geo_terr_id<0
           and terr.terr_group_id = grpv.terr_group_id
           and      grpv.geo_type = 'POSTAL_CODE'
                    and grpv.comparison_operator = '='
                    and g.geo_id = grpv.geo_id_from
                    and g.geo_type = 'POSTAL_CODE'
                    and g.postal_code = p_pc

    union
    select count(g.postal_code) exist         /* postal code range*/
    from   jtf_tty_geo_grp_values  grpv,
           jtf_tty_terr_groups     tg,
           jtf_tty_geo_terr        terr,
           jtf_tty_geo_terr_rsc    rsc,
           jtf_tty_geographies     g,   --postal_code level
           jtf_tty_geographies g1,
           jtf_tty_geographies g2
    where
               rsc.resource_id         = rsc_id -- user works in this geo terr
           and rsc.geo_territory_id    = terr.geo_territory_id
           and terr.terr_group_id      = tg.terr_group_id
           and terr.terr_group_id      = grpv.terr_group_id
           and terr.owner_resource_id  < 0
           and terr.parent_geo_terr_id < 0 -- default terr
           and SYSDATE BETWEEN tg.active_from_date AND NVL(tg.active_to_date, SYSDATE+1)
           and      grpv.geo_type = 'POSTAL_CODE'
           and grpv.comparison_operator = 'BETWEEN'
           and g.geo_type = 'POSTAL_CODE'
           and g.postal_code = p_pc
           AND    g1.geo_id = grpv.geo_id_from
           AND    g2.geo_id =  grpv.geo_id_to
           AND    g.geo_name BETWEEN g1.geo_name and g2.geo_name
  union
  select   count(g.postal_code) exist
  from     jtf_tty_geo_terr       terr,
           jtf_tty_geo_terr_rsc   rsc,
           jtf_tty_geo_grp_values grpv,
           jtf_tty_geographies    g,
           jtf_tty_geographies    g1
  where        rsc_id = rsc.resource_id
           and rsc.geo_territory_id = terr.geo_territory_id
           and terr.owner_resource_id <0
           and terr.parent_geo_terr_id<0
           and terr.terr_group_id = grpv.terr_group_id
           and (
                (
                        grpv.geo_type  = 'STATE'
                    and g1.geo_id      = grpv.geo_id_from
                    and g.STATE_CODE   = g1.state_Code
                    and g.country_code = g1.country_Code
                    and g.geo_type     = 'POSTAL_CODE'
                    and g.postal_code  = p_pc
                  )
                  or
                  (      grpv.geo_type      = 'CITY'
                    AND  g.geo_type         = 'POSTAL_CODE'
                    AND  g.country_code     = g1.country_code
                    AND (
                           (g.state_code = g1.state_code AND g1.province_code is null)
                            or
                           (g1.province_code = g.province_code AND g1.state_code is null)
                         )
                    AND    (g1.county_code is null or g.county_code = g1.county_code)
                    AND    g.city_code      = g1.city_code
                    AND    grpv.geo_id_from = g1.geo_id
                    and    g.postal_code    = p_pc
                  )
                  or
                  (
                           grpv.geo_type    = 'COUNTRY'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type       = 'POSTAL_CODE'
                    AND    g.country_code   = g1.country_code
                    and    g.postal_code    = p_pc
                  )
                  or
                  (
                           grpv.geo_type    = 'PROVINCE'
                    AND    grpv.geo_id_from = g1.geo_id
                    AND    g.geo_type       = 'POSTAL_CODE'
                    AND    g.country_code   = g1.country_code
                    AND    g.province_code  = g1.province_code
                    and    g.postal_code    = p_pc
                  )
    );




  terr_id     number;
  found       number;
  i           number;
  in_def_terr number;
  in_reg_terr number;
  n           number;
  m           number;
  l_user_id   varchar2(1000);
  rsc_id      number;
  x_msg_data  varchar2(100);
  l_geo_id    number;
  l_terr_id   number;
  l_change_id number;
    l_terr_count number;

l_terr_id_new          NUMBER;
l_terr_qual_id         NUMBER;
l_rank                 NUMBER;
l_geo_name             VARCHAR2(360); --from geographies
l_terr_value_id        NUMBER;   --value id corresponding to postal code
l_org_id               NUMBER;

l_g_terr_id            NUMBER;


  begin

  --l_user_id := fnd_global.user_id;
  -- for proxy user, a user_id is passed in
  l_user_id := p_userid;







  --insert into tmp values('glb userid',l_user_id); commit;
  select resource_id into rsc_id from jtf_rs_resource_extns
  where user_id = l_user_id;

    --Does this Postal Code belong to the current user, i.e., does the user have permission
    --to assign this postal code to the territories he created?
       begin
              in_reg_terr :=1;
              in_def_terr :=0;

              --insert into tmp values(l_user_id,p_terrgroup); commit;
              -- check if a regular terr the user working on has the postal code.
              select terr.geo_territory_id into terr_id
              from   jtf_tty_geo_terr terr,
                     jtf_tty_geo_terr_values terrv,
                     jtf_tty_geo_terr_rsc rsc,
                     jtf_tty_geographies  geog
              where      terr.geo_territory_id = terrv.geo_territory_id
                     and terrv.geo_id = geog.geo_id
                     and geog.postal_code = p_postal_code  /* the PC is in the terr she works in */
                     and rsc.geo_territory_id = terr.geo_territory_id /* the terr she works in */
                     and rsc_id = rsc.resource_id /* who logged in*/
                     and rownum<2;
              exception
                     when no_data_found then -- no postalcode - resource_id mapping found
                          in_reg_terr :=0;
      end;

      if in_reg_terr = 0 then       -- check the default geo terr
         -- start: the resource is not working in any default terr.
         -- or the default terr does not have any postalcode.
         FOR tgeo in CheckPCInDefTerr(rsc_id, p_postal_code) -- each grp_value entry
             LOOP

                 if tgeo.exist>0 then in_def_terr:=1;
                    else in_def_terr:=0;
                 end if;


             END LOOP;

      end if;
      if  in_reg_terr=0 and in_def_terr =0 and trim(p_postal_code) is not null then
      /*trim(p_postal_code) is null means the pc is to be removed */
                     fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_POSTAL_CODE');
                     x_msg_data := fnd_message.get();
                     fnd_message.set_name ('JTF', x_msg_data);
		     return;
      end if;
      /*  Does the Geography territory attached to the postal codes is created by the current user?
          check the ownership */
      if trim(p_geo_terr_name) is not null and trim(p_geo_terr_name)<>' ' then
         select    count(terr.geo_territory_id) into i
         from      jtf_tty_geo_terr terr
         where     terr.owner_resource_id = rsc_id
               and upper(terr.geo_terr_name) = upper(p_geo_terr_name);
              -- and terr.parent_geo_terr_id = terr_id; removed (sgkumar) parent terr can be default terr


         if i=0 then fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_TERR_NAME');
                     x_msg_data := fnd_message.get();
                     fnd_message.set_name ('JTF', x_msg_data);
		     return;
         end if;
      end if;


       /*  Does the Geography territory attached to the postal codes belong
           to the correct parent territory (sgkumar)*/

      if (trim(p_geo_terr_name) is not null and trim(p_geo_terr_name) <> ' ') then
         select    count(terr1.geo_territory_id) into i
         from      jtf_tty_geo_terr terr1, jtf_tty_geo_terr terr2
         where     terr1.geo_territory_id = terr2.parent_geo_terr_id
         and       upper(terr1.geo_terr_name) = upper(p_manager_terr_name)
         and       terr2.geo_terr_name = p_geo_terr_name;
         -- and terr.parent_geo_terr_id = terr_id;

         if i=0 then fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_TERR_NAME');
                     x_msg_data := fnd_message.get();
                     fnd_message.set_name ('JTF', x_msg_data);
		     return;
         end if;
      end if;

      -- pass the validation, now do the update
      -- check if the p_pc exists in the PCs the user owners.
      -- no need check for unsigned because it wont exist?

      select count(geog.postal_code) into found --geog.postal_code, terr.geo_terr_name
      from jtf_tty_geo_terr terr,
           jtf_tty_geo_terr_values terrv,
           jtf_tty_geographies geog
      where     terr.owner_resource_id   = rsc_id
           and terr.geo_territory_id     = terrv.geo_territory_id
           and terrv.geo_id              = geog.geo_id
           and geog.postal_code          = p_postal_code
           and upper(terr.geo_terr_name) = upper(p_geo_terr_name);

      if found=0 then
             -- the p_geo_terr_value_id is from the old assignment but pc/terr_name is new
             -- remove the old assignment, only happens in no-default terr
             -- p_geo_terr_value_id can be null
           /* delete from jtf_tty_geo_terr_values
             where geo_terr_value_id = p_geo_terr_value_id;
            */
            BEGIN
            /*remove recursively*/
            l_geo_id  :=0;
            l_terr_id :=0;
            select geo_id,geo_territory_id
                   into l_geo_id,l_terr_id
            from jtf_tty_geo_terr_values
            where geo_terr_value_id = p_geo_terr_value_id;
            exception
                when no_data_found then
                null;
                when others then
                null;
            END;

            delete from jtf_tty_geo_terr_values gtv
            where     geo_id = l_geo_id
                  and geo_territory_id in (
                            select     geo_territory_id
                            from   jtf_tty_geo_terr
                            start with geo_territory_id = l_terr_id
                            connect by prior geo_territory_id=parent_geo_terr_id
                            );

          if (trim(p_geo_terr_name) is not null) then -- insert
          --insert into tmp values('enter',p_geo_terr_name); commit;
                -- n: geo_terr_value_id
                if trim(p_geo_terr_value_id) is null then
                    -- new geo_terr_value_id
                   select jtf_tty_geo_terr_values_s.nextval into n from dual;
                else n:=trim(p_geo_terr_value_id);
                end if;


		-- dbms_output.put_line(' Postal code ******* is'||p_postal_code);

                if trim(p_postal_code) is null then return; -- no need inserting new postal code
                end if;

                -- m: geo_id
                select geo_id into m  -- geo_id
                from jtf_tty_geographies
                where postal_code=p_postal_code;

                begin
                -- terr_id

		-- dbms_output.put_line(' GEO TERR NAME  ******* is'||p_geo_terr_name);
                select geo_territory_id into terr_id --terr_id
                from jtf_tty_geo_terr
                where upper(geo_terr_name) = upper(p_geo_terr_name);
                      --and owner_resource_id = rsc_id; --10121
                exception
                when no_data_found then

                fnd_message.set_name ('JTF', 'JTF_TTY_INVALID_TERR_NAME');
                x_msg_data := fnd_message.get();
                fnd_message.set_name ('JTF', x_msg_data);
		return;

                when others then
                fnd_message.set_name ('JTF', 'JTF_TTY_DUPLICATE_TERRITORY_NAME');
                x_msg_data := fnd_message.get();
                fnd_message.set_name ('JTF', x_msg_data);
		return;
                end;


                insert into jtf_tty_geo_terr_values (geo_terr_value_id,object_version_number,
                                                     geo_territory_id,geo_id, created_by,
                                                     creation_date,last_updated_by,
                                                     last_update_date,last_update_login)
                       values(n,1,terr_id, m, rsc_id, sysdate, rsc_id, sysdate, rsc_id);



              l_g_terr_id := terr_id;




                /*  Vbghosh:
		    Get the terr_id from the geo_terr_id
		*/


                   /* get the terr_id from the corresponding geo_terr_id*/
		   BEGIN

		     --dbms_output.put_line(' GEO TERR ID  ******* is'||terr_id);

		      SELECT
			terr_id ,
			org_id
		      INTO l_terr_id_new
		      , l_org_id
		      FROM jtf_terr_all
		      WHERE geo_territory_id = l_g_terr_id ; --its geo_terr_id

		      --dbms_output.put_line(' after selecting terr_id is'||terr_id);

                    EXCEPTION
	     	      WHEN NO_DATA_FOUND THEN
  		      	RAISE;
		      WHEN OTHERS THEN
		      --dbms_output.put_line('ERROR '||SQLERRM);
	     	       RAISE;

                   END; --getting terr_id

		    BEGIN   --get the terr_qual_id if null then insert
			SELECT
				c.terr_qual_id
                             INTO
			         l_terr_qual_id
			     FROM
			        jtf_terr_all        a
				, jtf_tty_geo_terr  b
				, jtf_terr_qual_all c
			     WHERE
			        b.geo_territory_id         = a.geo_Territory_id
				AND b.geo_territory_id     = l_g_terr_id --its geo_terr_id
				AND c.terr_id              = a.terr_id
				AND c.qual_usg_id          = -1007;

				--dbms_output.put_line(' terr_qual_id ID  ******* is'|| l_terr_qual_id);

		    EXCEPTION
		         WHEN NO_DATA_FOUND THEN
			    --dbms_output.put_line('ERROR '||SQLERRM);
			    NULL;
			WHEN OTHERS THEN
			  --dbms_output.put_line('ERROR '||SQLERRM);
			  RAISE;
                    END; -- end checking create or update

                    IF l_terr_qual_id IS NULL THEN  -- need to create using sequence
                        --dbms_output.put_line(' terr_qual_id ID  ******* is NULL');
		       /* insert in terr_qual_all table using sequence*/
			 SELECT JTF_TERR_QUAL_S.NEXTVAL
			  INTO l_terr_qual_id
			  FROM DUAL;
			   --dbms_output.put_line(' AFter select ing from seq qual id');

                       INSERT INTO jtf_terr_qual_all
			 ( TERR_QUAL_ID
			   , LAST_UPDATE_DATE
			   , LAST_UPDATED_BY
			   , CREATION_DATE
			   , CREATED_BY
			   , LAST_UPDATE_LOGIN
			   , TERR_ID
			   , QUAL_USG_ID
			   , OVERLAP_ALLOWED_FLAG
			   , ORG_ID )
			SELECT
			   l_terr_qual_id
			   , SYSDATE
			   , LAST_UPDATED_BY
			   , SYSDATE
			   , CREATED_BY
			   , LAST_UPDATE_LOGIN
			   , l_terr_id_new
			   , -1007
			   , 'Y'
			   , l_org_id -- ORgId
			 FROM jtf_tty_geo_terr
			 WHERE geo_territory_id = terr_id;

			  --dbms_output.put_line(' AFterinserting  qual id');


		    END IF;




		   /* vbghosh: if parameter p_geo_terr_value_id or l_terr_value_id is null
	              then it is a new create and a new value has to be inseted in terr_values_all
		      table otherwise its a updated
	           */

                   IF p_geo_terr_value_id IS NULL  THEN
		      --dbms_output.put_line(' terr_value id is null ');



			/* Insert a new row in terr_values_all table , using the geo_terr_value_id "n"*/
                        INSERT INTO jtf_terr_values_all
			(
			 TERR_VALUE_ID
			 ,LAST_UPDATED_BY
			 ,LAST_UPDATE_DATE
			 ,CREATED_BY
			 ,CREATION_DATE
			 ,LAST_UPDATE_LOGIN
			 ,TERR_QUAL_ID
			 ,COMPARISON_OPERATOR
			 ,ID_USED_FLAG
			 ,ORG_ID
			 ,LOW_VALUE_CHAR -- TODO need to check
			 ,SELF_SERVICE_TERR_VALUE_ID
			)
			SELECT
			    JTF_TERR_VALUES_S.NEXTVAL
			    ,LAST_UPDATED_BY
			    ,SYSDATE
			    ,CREATED_BY
			    ,SYSDATE
			    ,LAST_UPDATE_LOGIN
			    ,l_terr_qual_id
			    ,'='
			    ,'N'
			    , l_org_id
			    , p_postal_code
			    , n   -- geo_terr_value_id
			 FROM jtf_tty_geo_terr
			 WHERE geo_territory_id = terr_id;

                       --dbms_output.put_line(' Inserting terr_value id  ');
                   ELSE
		     /* get the corresponding self_service_value_id from the terr_value_table
		        delete it and then insert it
		     */
                     BEGIN
                           --dbms_output.put_line(' before deletin terr_value_id ');
                           DELETE FROM jtf_terr_values_all
			   WHERE SELF_SERVICE_TERR_VALUE_ID = to_number(p_geo_terr_value_id);
				--dbms_output.put_line(' After deletin terr_value_id  and before insertin');
			    --dbms_output.put_line(' After inserting  terr_value_id ');

			  EXCEPTION
				WHEN NO_DATA_FOUND THEN
				   NULL;
				WHEN OTHERS THEN
				   RAISE;
		     END;

                     INSERT INTO jtf_terr_values_all
			(
			 TERR_VALUE_ID
			 ,LAST_UPDATED_BY
			 ,LAST_UPDATE_DATE
			 ,CREATED_BY
			 ,CREATION_DATE
			 ,LAST_UPDATE_LOGIN
			 ,TERR_QUAL_ID
			 ,COMPARISON_OPERATOR
			 ,ID_USED_FLAG
			 ,ORG_ID
			 ,LOW_VALUE_CHAR -- TODO need to check
			 ,SELF_SERVICE_TERR_VALUE_ID
			)
			SELECT
			    JTF_TERR_VALUES_S.NEXTVAL
			    ,LAST_UPDATED_BY
			    ,SYSDATE
			    ,CREATED_BY
			    ,SYSDATE
			    ,LAST_UPDATE_LOGIN
			    ,l_terr_qual_id
			    ,'='
			    ,'N'
			    , l_org_id
			    , p_postal_code
			    , to_number(p_geo_terr_value_id)  -- geo_terr_value_id
			 FROM jtf_tty_geo_terr
			 WHERE geo_territory_id = terr_id;




		  END IF;



                        /* ACHANDA: Inserting values to jtf_tty_named_acct_changes table for GTP
                           to do an incremental and Total Mode */

                        select jtf_tty_named_acct_changes_s.nextval
                          into l_change_id
                          from sys.dual;

                        insert into jtf_tty_named_acct_changes
                        (   NAMED_ACCT_CHANGE_ID
                          , OBJECT_VERSION_NUMBER
                          , OBJECT_TYPE
                          , OBJECT_ID
                          , CHANGE_TYPE
                          , FROM_WHERE
                          , CREATED_BY
                          , CREATION_DATE
                          , LAST_UPDATED_BY
                          , LAST_UPDATE_DATE
                          , LAST_UPDATE_LOGIN
                        )
                        VALUES (
                          l_change_id
                          , 1
                          , 'GT'
                          , terr_id
                          , 'UPDATE'
                          , 'Update Mapping'
                          , rsc_id
                          , sysdate
                          , rsc_id
                          , sysdate
                          , rsc_id
                        );

           end if;
      end if; -- of found=0

      commit;

  exception
          when others then
          fnd_message.set_name ('JTF', 'JTF_TTY_UNEXPECTED_ERROR');
          x_msg_data := fnd_message.get();
          fnd_message.set_name ('JTF', x_msg_data);
  end UPDATE_GEO_TERR;


END JTF_TTY_GEO_WEBADI_INT_PKG;

/
