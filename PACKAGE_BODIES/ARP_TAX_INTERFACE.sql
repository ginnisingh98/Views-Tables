--------------------------------------------------------
--  DDL for Package Body ARP_TAX_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TAX_INTERFACE" AS
/* $Header: ARPLTXIB.pls 115.17 2003/12/05 02:12:13 sachandr ship $ */


/*---------------------------------------------------------------------------+
 |                                                                           |
 | PRIVATE EXCEPTIONS                                                        |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PRIVATE DATATYPES                                                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/


type tab_id_type is table of number index by binary_integer;

type tab_value_type is table of varchar2(60) index by binary_integer;

type tab_date_type is table of date index by binary_integer;

type tab_rate_type is table of number index by binary_integer;

type tab_boolean_type is table of boolean index by binary_integer;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PRIVATE CONSTANTS                                                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | PRIVATE VARIABLES                                                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/


qualifier tab_value_type;         -- Segment Qualifiers, EG:-

                                  -- STATE
                                  -- COUNTY
                                  -- CITY

segment   number;                 -- Count of number of segments in location
                                  -- flexfield structure.

LOCATION_SEGMENTS varchar2(4096); -- Space separated list of segment qualifiers

error_count number ;

max_location_width number ;       -- Maximum precission that a name held in the
                                  -- interface table has. Only this many
                                  -- Characters of the location database will be
                                  -- checked before determing if a new row
                                  -- needs to be created in ar_location_values

qual_adjust number;               -- Allows optional creation of Country segment
                                  -- and rates.


  --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*---------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                          |
 |   ELIMINATE_OVERLAPPED_RANGE                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This function looks for records which are overlapped each other and     |
 |   update STATUS column of AR_TAX_INTERFACE with                           |
 |   IGNORED-NARROWER-ZIP for the record which zip range is narrower than    |
 |   the the other.                                                          |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |    20-Oct-98  Toru Kawamura        Created.                               |
 |    05-AUG-02  Satyadeep            Bugfix 2377918                         |
 |               Chandrashekar                                               |
 |                                    |-----------|                          |
 |                                      |-----|                              |
 |                                    Such records in the interface will not |
 |                                    be marked as ignore-narrower-zip       |
 ----------------------------------------------------------------------------*/
PROCEDURE ELIMINATE_OVERLAPPED_RANGE (
                        senior_segment     in varchar2   default null,
                        default_start_date in date       default to_date('01-01-1900', 'dd-mm-yyyy'))IS

  cursor c_overlap_candidate(senior_segment in varchar2 ) IS
  select distinct
    ci.interface_line_id,
    ci.location_segment_id,
    ci.segment_qualifier,
    trunc(nvl(ci.start_date, default_start_date)) start_date,
    nvl(ci.end_date, arp_standard.max_end_date) end_date,
    nvl(ci.from_postal_code,arp_standard.sysparm.from_postal_code ) from_postal_code,
    nvl(ci.to_postal_code,arp_standard.sysparm.to_postal_code ) to_postal_code,
    ci.rate_type,
    ci.tax_rate,
    ci.parent_location_id,
    ci.location_id,
    ci.location_value,
    ci.status
  from
    ar_tax_interface ci,
    ar_tax_interface co,
    ar_tax_interface st
  where ci.interface_line_id in (
     select
       distinct t1.interface_line_id
     from
       ar_tax_interface t1,
       ar_tax_interface t2
     where t1.location_value = t2.location_value
     and   t1.segment_qualifier = 'CITY'
     and   t1.parent_location_id = t2.parent_location_id
     and   t1.interface_line_id <> t2.interface_line_id
     and   ( ((( nvl(t1.from_postal_code,arp_standard.sysparm.from_postal_code)
                           >= nvl(t2.from_postal_code, arp_standard.sysparm.from_postal_code) )
             and ( nvl(t1.from_postal_code, arp_standard.sysparm.from_postal_code)
                             <= nvl(t2.to_postal_code, arp_standard.sysparm.to_postal_code) ))
           or (( nvl(t1.to_postal_code, arp_standard.sysparm.to_postal_code)
                         >= nvl(t2.from_postal_code, arp_standard.sysparm.from_postal_code) )
             and ( nvl(t1.to_postal_code, arp_standard.sysparm.to_postal_code)
                           <= nvl(t2.to_postal_code, arp_standard.sysparm.to_postal_code) )))
           and not (( nvl(t1.from_postal_code, arp_standard.sysparm.from_postal_code)
                           <= nvl(t2.from_postal_code, arp_standard.sysparm.from_postal_code) )
             and ( nvl(t1.to_postal_code, arp_standard.sysparm.to_postal_code)
                           >= nvl(t2.to_postal_code, arp_standard.sysparm.to_postal_code) ))
           and not (( nvl(t1.from_postal_code, arp_standard.sysparm.from_postal_code)
                           >= nvl(t2.from_postal_code, arp_standard.sysparm.from_postal_code) )
             and ( nvl(t1.to_postal_code, arp_standard.sysparm.to_postal_code)
                           <= nvl(t2.to_postal_code, arp_standard.sysparm.to_postal_code) )) )
     and ( trunc(nvl(t1.start_date, default_start_date)) = trunc(nvl(t2.start_date, default_start_date)) )
     and not( ( nvl(t1.from_postal_code, arp_standard.sysparm.from_postal_code)
                          = nvl(t2.from_postal_code, arp_standard.sysparm.from_postal_code))
            and ( nvl(t1.to_postal_code, arp_standard.sysparm.to_postal_code)
                          = nvl(t2.to_postal_code, arp_standard.sysparm.to_postal_code) ) )
     )
  and   st.location_value like nvl(senior_segment,'%')
  and   co.parent_location_id = st.location_id
  and   ci.parent_location_id = co.location_id
  and   ci.status is null
  order by ci.parent_location_id, ci.location_value, ci.location_id;

  cursor c_zip_overlap(p_interface_line_id  in number,
                       p_segment_qualifier  in varchar2,
                       p_start_date         in date,
                       p_from_postal_code   in varchar2,
                       p_to_postal_code     in varchar2,
                       p_rate_type          in varchar2,
                       p_parent_location_id in number,
                       p_location_value     in varchar2) IS
  select distinct
    interface_line_id,
    location_segment_id,
    segment_qualifier,
    nvl(start_date, default_start_date) start_date,
    nvl(end_date, arp_standard.max_end_date) end_date,
    nvl(from_postal_code, arp_standard.sysparm.from_postal_code ) from_postal_code,
    nvl(to_postal_code, arp_standard.sysparm.to_postal_code ) to_postal_code,
    rate_type,
    tax_rate,
    parent_location_id,
    location_value
  from
    ar_tax_interface
  where interface_line_id <> p_interface_line_id
  and   segment_qualifier = p_segment_qualifier
  and   parent_location_id = p_parent_location_id
  and   location_value = p_location_value
  and   rate_type = p_rate_type
  and   status is null
  and   (  ((nvl(p_from_postal_code, arp_standard.sysparm.from_postal_code)
                     >= nvl(from_postal_code, arp_standard.sysparm.from_postal_code)
           and nvl(p_from_postal_code, arp_standard.sysparm.from_postal_code)
                        <= nvl(to_postal_code, arp_standard.sysparm.to_postal_code))
        or (nvl(p_to_postal_code, arp_standard.sysparm.to_postal_code)
                   >= nvl(from_postal_code, arp_standard.sysparm.from_postal_code)
           and nvl(p_to_postal_code, arp_standard.sysparm.to_postal_code)
                      <= nvl(to_postal_code, arp_standard.sysparm.to_postal_code)))
        and not (nvl(p_from_postal_code, arp_standard.sysparm.from_postal_code)
                     >= nvl(from_postal_code, arp_standard.sysparm.from_postal_code)
           and nvl(p_to_postal_code, arp_standard.sysparm.to_postal_code)
                      <= nvl(to_postal_code, arp_standard.sysparm.to_postal_code))
        and not (nvl(p_from_postal_code, arp_standard.sysparm.from_postal_code)
                     <= nvl(from_postal_code, arp_standard.sysparm.from_postal_code)
           and nvl(p_to_postal_code, arp_standard.sysparm.to_postal_code)
                      >= nvl(to_postal_code, arp_standard.sysparm.to_postal_code)))
  and   not (nvl(p_from_postal_code, arp_standard.sysparm.from_postal_code)
                      = nvl(from_postal_code, arp_standard.sysparm.from_postal_code)
            and nvl(p_to_postal_code, arp_standard.sysparm.to_postal_code)
                       = nvl(to_postal_code, arp_standard.sysparm.to_postal_code))
  and   trunc(nvl(p_start_date,default_start_date)) = trunc(nvl(start_date, default_start_date));

l_interface_line_id    number;
l_location_segment_id  number;
l_segment_qualifier    varchar2(30);
l_start_date           date;
l_end_date             date;
l_from_postal_code     varchar2(60);
l_to_postal_code       varchar2(60);
l_rate_type            varchar2(30);
l_tax_rate             number;
l_parent_location_id   number;
l_location_value       varchar2(60);
l_status               varchar2(60);
in_clause              varchar2(20000);
dis_in_clause          varchar2(200);

l_count                binary_integer := 0;
s_count                binary_integer := 0;

start_pos              binary_integer;
end_pos                binary_integer;

l_ignore               binary_integer;
l_cursor               binary_integer;
sqlstmt                varchar2(20000);

prog_loc               binary_integer;/* Indicator to find out where
                                         exception is raised */
sel_count              binary_integer;

BEGIN
  if pg_debug='Y' then
    arp_util_tax.debug('ARP_TAX_INTERFACE.ELIMINATE_OVERLAPPED_RANGE('||
                 senior_segment||':'||to_char(default_start_date)||
                 to_char(sysdate, 'YYYY-MON-DD: HH:MI:SS')||')+');
  end if;

  prog_loc := 1;

  l_interface_line_id := NULL;
  l_location_segment_id := NULL;
  l_segment_qualifier := NULL;
  l_start_date := NULL;
  l_end_date := NULL;
  l_from_postal_code := NULL;
  l_to_postal_code := NULL;
  l_rate_type := NULL;
  l_tax_rate := NULL;
  l_parent_location_id := NULL;
  l_location_value := NULL;
  l_status := NULL;

  for c1 in c_overlap_candidate(senior_segment)
  loop
     prog_loc := 2;
     l_count := l_count + 1;

     l_interface_line_id := c1.interface_line_id;
     l_location_segment_id := c1.location_segment_id;
     l_segment_qualifier := c1.segment_qualifier;
     l_start_date := c1.start_date;
     l_end_date := c1.end_date;
     l_from_postal_code := c1.from_postal_code;
     l_to_postal_code := c1.to_postal_code;
     l_rate_type := c1.rate_type;
     l_tax_rate := c1.tax_rate;
     l_parent_location_id := c1.parent_location_id;
     l_location_value := c1.location_value;

     if pg_debug='Y' then
       arp_util_tax.debug(to_char(l_count)||':'||to_char(l_interface_line_id)||
                                                                  ':'||to_char(l_location_segment_id));
       arp_util_tax.debug('---'||l_segment_qualifier||':'||to_char(l_start_date)||':'||l_from_postal_code);
       arp_util_tax.debug('---'||l_rate_type||':'||to_char(l_parent_location_id)||':'||l_location_value);
     end if;
     s_count := 0;
     for c2 in c_zip_overlap(c1.interface_line_id,
                             c1.segment_qualifier,
                             c1.start_date,
                             c1.from_postal_code,
                             c1.to_postal_code,
                             c1.rate_type,
                             c1.parent_location_id,
                             c1.location_value)
     loop

       prog_loc := 3;
       s_count := s_count + 1;

       if (l_from_postal_code >= c2.from_postal_code) and
          (l_to_postal_code <= c2.to_postal_code) then
         if pg_debug='Y' then
           arp_util_tax.debug('Postal Code current: '||l_from_postal_code||' : '||l_to_postal_code);
           arp_util_tax.debug('     smaller than    ');
           arp_util_tax.debug('Postal Code in: '||c2.from_postal_code||' : '||c2.to_postal_code);
         end if;
         l_interface_line_id := c2.interface_line_id;
         l_location_segment_id := c2.location_segment_id;
         l_segment_qualifier := c2.segment_qualifier;
         l_start_date := c2.start_date;
         l_end_date := c2.end_date;
         l_from_postal_code := c2.from_postal_code;
         l_to_postal_code := c2.to_postal_code;
         l_rate_type := c2.rate_type;
         l_tax_rate := c2.tax_rate;
         l_parent_location_id := c2.parent_location_id;
         l_location_value := c2.location_value;

       else
         if pg_debug='Y' then
           arp_util_tax.debug('Postal Code current: '||l_from_postal_code||' : '||l_to_postal_code);
           arp_util_tax.debug('     larger than    ');
           arp_util_tax.debug('Postal Code in: '||c2.from_postal_code||' : '||c2.to_postal_code);
         end if;
         in_clause := in_clause||','||c2.interface_line_id;

       end if;
       if pg_debug='Y' then
         arp_util_tax.debug('************');
       end if;
     end loop;

     prog_loc := 4;
     if pg_debug='Y' then
       arp_util_tax.debug('Largest Zip Range is : '||l_from_postal_code||' ~~ '||l_to_postal_code);
       arp_util_tax.debug('Location value is :'||l_location_value);
       arp_util_tax.debug('Interface_line_id is :'||to_char(l_interface_line_id));
       arp_util_tax.debug('Small Count is: '||s_count);
       arp_util_tax.debug('');
       arp_util_tax.debug('-----------------------------------------------------');
       arp_util_tax.debug('');
      end if;

  end loop;

  prog_loc := 5;

  if in_clause is not null then

    in_clause := substrb(in_clause, 2);

    start_pos := 1;
    end_pos := 200;

    dis_in_clause := substrb(in_clause, start_pos, end_pos);
    if pg_debug='Y' then
      arp_util_tax.debug('STATUS column of records with following interface_line_id');
      arp_util_tax.debug('in ar_tax_interface table, will be updated with IGNORED-NARROWER-ZIP');
    end if;

    while dis_in_clause is not null loop
      prog_loc := 6;
      if pg_debug='Y' then
        arp_util_tax.debug(dis_in_clause);
      end if;
      start_pos:= start_pos + 200;
      end_pos := end_pos + 200;
      dis_in_clause := substrb(in_clause, start_pos, end_pos);
    end loop;
    if pg_debug='Y' then
      arp_util_tax.debug('');
    end if;

    --
    -- Prepareing Dynamic SQL to update overlapped records.
    --
    l_cursor := dbms_sql.open_cursor;
    prog_loc := 7;
    sqlstmt := 'update ar_tax_interface set status =' ||''''||
               'IGNORED-NARROWER-ZIP'||''''||' where interface_line_id in ('||in_clause||')';
    if pg_debug='Y' then
      arp_util_tax.debug('Update statement is <><><><><><>');
      arp_util_tax.debug(substrb(sqlstmt, 1, 250));
    end if;

    dbms_sql.parse(l_cursor, sqlstmt, dbms_sql.native);
    prog_loc := 8;

    l_ignore := dbms_sql.execute(l_cursor);

    dbms_sql.close_cursor( l_cursor );
    prog_loc := 9;

  end if;
  prog_loc := 10;

  select count(*) into sel_count from ar_tax_interface where status = 'IGNORED-NARROWER-ZIP';
  if pg_debug='Y' then
    arp_util_tax.debug('ARP_TAX_INTERFACE.ELIMINATE_OVERLAPPED_RANGE('||': '||
           to_char(sel_count)||' :'||to_char(sysdate, 'YYYY-MON-DD: HH:MI:SS')||')-');
  end if;
EXCEPTION
  WHEN OTHERS THEN
  if pg_debug='Y' then
      arp_util_tax.debug('Error Occured in ARP_TAX_INTERFACE.ELIMINATE_OVERLAPPED_RANGE'||to_char(prog_loc));
      arp_util_tax.debug('SQL CODE is :'||to_char(SQLCODE));
      arp_util_tax.debug('SQL ERRM is :'||SQLERRM);
   end if;

      if prog_loc in (7, 8) then
          dbms_sql.close_cursor( l_cursor );
      end if;
END ELIMINATE_OVERLAPPED_RANGE;

/*---------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                          |
 |   date_adjust                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Adjust existing or new date ranges so that they do not overlap          |
 |   Each date range can start at the beginning of time ( min_start_date )   |
 |   and/or end at the end of time ( max_end_date ).                         |
 |   Date ranges that have these boundaries are considered adjustable.       |
 |   Ranges that continue to overlap when each boundary is fixed have to be  |
 |   either replaced or ignored, dependent upon a runtime parameters         |
 |                                                                           |
 |   Existing or old data is first adjusted, then new data.                  |
 |   After each adjustment, a check is made to see if the ranges still       |
 |   overlap, in this way the minimum around of data changes to make the     |
 |   the date ranges compatible.                                             |
 |                                                                           |
 |   Adjustment Order                                                        |
 |      old_end                                                              |
 |      old_start                                                            |
 |      new_start                                                            |
 |      new_end                                                              |
 |                                                                           |
 | REQUIRES                                                                  |
 |   old_start          Existing start date, can also be min_start_date      |
 |   old_end            Existing end date, can also be max_end_date          |
 |   new_start          Proposed start date, can also be min_start_date      |
 |   new_end            Proposed end date, can also be max_end_date          |
 |                                                                           |
 | RETURNS                                                                   |
 |   Date Ranges        Each of the parameter values are modifiable          |
 |   ACTION                                                                  |
 |      UPDATE-INSERT   Old record updates, new inserted as it stands        |
 |      IGNORE          Reject new record                                    |
 |      ADJUST          New record only needs adjusting                      |
 |      OVERRIDE        New record replace old record                        |
 |                                                                           |
 | EXCEPTIONS RAISED                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | EXAMPLE                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    25-Feb-93  Nigel Smith        Created.                                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
FUNCTION dates_overlap(  old_start in out NOCOPY date,
                         old_end   in out NOCOPY date,
                         new_start in out NOCOPY date,
                         new_end   in out NOCOPY date ) return BOOLEAN IS
begin -- return true if the old and new dates overlap

   if ( old_start between new_start and new_end ) or
      ( old_end   between new_start and new_end ) then
      return(TRUE);
   else
      return(FALSE);
   end if;

end;


FUNCTION date_adjust(  old_start in out NOCOPY date,
                       old_end   in out NOCOPY date,
                       new_start in out NOCOPY date,
                       new_end   in out NOCOPY date ) return VARCHAR2 IS

action   varchar2(4096) := NULL;

BEGIN

  if dates_overlap( old_start, old_end, new_start, new_end ) then

    /*----------------------------------------------------------------------+
     | Date Ranges Overlap                                                  |
     |                                                                      |
     | Attempt to eliminate any overlap by adjusting any NULL values for    |
     | existing, or new date boundaries.                                    |
     |                                                                      |
     +----------------------------------------------------------------------*/

    /*----------------------------------------------------------------------+
     | Attempt to ADJUST original Dates, first end date, then start date    |
     +----------------------------------------------------------------------*/

    --
    -- old:    |-------------------------->
    -- new:                 |------------------------->
    -- Becomes
    -- old:    |-----------|
    -- new:                 |------------------------->
    -- Action: UPDATE-INSERT
    --
    if ( old_end >= trunc(arp_standard.max_end_date) ) and
       ( trunc(new_start) > arp_standard.min_start_date ) then

      if new_start < old_start then

        /* The new record starts before the existing record, update the new */
        /* record so that it has an end date */

        new_end := arp_standard.ceil(trunc( old_start -1 ));
        action := 'INSERT';

      else

        /* The new record, requires that the old record is terminated, before */
        /* it can be inserted */

        old_end := arp_standard.ceil(new_start - 1);
        action := 'UPDATE-INSERT';

      end if;

    elsif ( trunc(old_start) = trunc(new_start) ) and
          ( trunc(old_end) = trunc(new_end) ) then

      action := 'RATE-ADJUST';

    else

      action := 'ALREADY-EXISTS';  -- Used to be ignore; but already exists is a clearer
				      -- Statement of the problem.
    end if;

  else /* Dates do not overlap, insert new date, as it stands */

      action := 'INSERT';

  end if; /* Do dates overlap? */

  return(action);

end;

/*---------------------------------------------------------------------------+
 | PRIVATE PROCEDURE                                                         |
 |   load_segment_values                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | REQUIRES                                                                  |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | EXCEPTIONS RAISED                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | EXAMPLE                                                                   |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    25-Feb-93  Nigel Smith        Created.                                 |
 |    01-Feb-94  Martin Johnson     Incident 35495.  Removed upper for join  |
 |                                  to senior_segment                        |
 |    05-Jul-94  Nigel SMith        BUGFIX: 224123, uploads overlapping      |
 |                                  location_rate_records.                   |
 |    05-OCT-02  Satyadeep          Bug 2609220 added parameter              |
 |               Chandrashekar      p_rate_attribute1 to location_rates_c    |
 |                                  cursor (parameter for geocode)           |
 +---------------------------------------------------------------------------*/


PROCEDURE load_segment_values( change_control     in varchar2,
                               default_start_date in date,
                               senior_segment     in varchar2,
                               max_error_count    in number,
                               commit_on_each_senior_segment in varchar2 )  IS

  cursor interface_c( request_id     in number,
                    senior_segment in varchar2 ) IS
  select DISTINCT
         i.interface_line_id,
         i.segment_qualifier,
         level,
         i.location_id,
         upper(i.location_value) location_value,
         i.location_value location_user_value,
         nvl(i.location_description, initcap(i.location_value)) location_description,
         i.parent_location_id,
         nvl(i.from_postal_code, arp_standard.sysparm.from_postal_code ) from_postal_code,
         nvl(i.to_postal_code, arp_standard.sysparm.to_postal_code ) to_postal_code,
         trunc(nvl(i.start_date, default_start_date)) start_date,
         nvl(i.end_date, arp_standard.max_end_date) end_date,
         i.tax_rate,
         i.location_segment_id,
         i.status,
         location_attribute_category,
         location_attribute1,
         location_attribute2,
         location_attribute3,
         location_attribute4,
         location_attribute5,
         location_attribute6,
         location_attribute7,
         location_attribute8,
         location_attribute9,
         location_attribute10,
         location_attribute11,
         location_attribute12,
         location_attribute13,
         location_attribute14,
         location_attribute15,
         rate_attribute_category,
         rate_attribute1,
         rate_attribute2,
         rate_attribute3,
         rate_attribute4,
         rate_attribute5,
         rate_attribute6,
         rate_attribute7,
         rate_attribute8,
         rate_attribute9,
         rate_attribute10,
         rate_attribute11,
         rate_attribute12,
         rate_attribute13,
         rate_attribute14,
         rate_attribute15,
         decode(i.segment_qualifier, 'CITY',
                  nvl(i.override_structure_id,
                      arp_standard.sysparm.location_structure_id),
                  null) override_structure_id,
         override_rate1,
         override_rate2,
         override_rate3,
         override_rate4,
         override_rate5,
         override_rate6,
         override_rate7,
         override_rate8,
         override_rate9,
         override_rate10
  from   ar_tax_interface i
  where  i.rate_type = 'SALES'
  start  with parent_location_id is null
         and  i.location_value like nvl(senior_segment,'%')
         and  i.rate_type = 'SALES'
	 and i.status is null
  connect by prior location_id = parent_location_id
         and i.rate_type = 'SALES'
  order by rpad( location_id, 15, '0'), start_date; /*trunc(nvl(i.start_date, default_start_date));*/
   --BugFix:2170824 Modified the above order by clause,used the alias instead of the
   --truncate expression.
   /*** MB skip ... Note the above rpad had not been changed ***/
-- Bug 2609220 added parameter p_rate_attribute1
  cursor location_rates_c( p_location_segment_id             in number,
                         p_from_postal_code                in varchar2,
                         p_to_postal_code                  in varchar2,
                         p_start_date                      in date,
                         P_end_date                        in date,
                         p_rate_attribute1         in varchar2) IS

  select r.location_rate_id,
         r.tax_rate,
         r.from_postal_code,
         r.to_postal_code,
         r.start_date,
         r.end_date,
	 r.override_rate1,
	 r.override_rate2,
	 r.override_rate3,
	 r.override_rate4,
	 r.override_rate5,
	 r.override_rate6,
	 r.override_rate7,
	 r.override_rate8,
	 r.override_rate9,
	 r.override_rate10,
	 r.attribute_category,
	 r.attribute1,
	 r.attribute2,
	 r.attribute3,
	 r.attribute4,
	 r.attribute5,
	 r.attribute6,
	 r.attribute7,
	 r.attribute8,
	 r.attribute9,
	 r.attribute10,
	 r.attribute11,
	 r.attribute12,
	 r.attribute13,
	 r.attribute14,
	 r.attribute15
  from   ar_location_rates r
  where     r.location_segment_id = p_location_segment_id
  and    (  p_from_postal_code between r.from_postal_code and r.to_postal_code
         or p_to_postal_code   between r.from_postal_code and r.to_postal_code
         or (p_from_postal_code <= r.from_postal_code and
             p_to_postal_code   >= r.to_postal_code))
  and    (  p_start_date between r.start_date and nvl(r.end_date, r.start_date)
         or p_end_date   between r.start_date and nvl(r.end_date, r.start_date)
         or (p_start_date <= r.start_date and
             p_end_date   >= nvl(r.end_date, p_end_date)))
  and    nvl(r.attribute1, -99) = nvl(p_rate_attribute1, -99)
  order by from_postal_code, start_date
  for update of tax_rate, from_postal_code, to_postal_code, start_date, end_date;

  current_level             NUMBER;
  location_id               TAB_ID_TYPE;
  location_value            TAB_VALUE_TYPE;
  location_from_postal_code TAB_VALUE_TYPE;
  location_to_postal_code   TAB_VALUE_TYPE;
  location_start_date       TAB_DATE_TYPE;
  location_end_date         TAB_DATE_TYPE;
  location_rate             TAB_RATE_TYPE;
  new_location              BOOLEAN := FALSE;
  rate_id                   NUMBER;
  action                    AR_TAX_INTERFACE.STATUS%TYPE;
  this_location             NUMBER(15);
  error_code                number;
  error_text                varchar2(4096);

begin

  /*** Update STATUS column of AR_TAX_INTERFACE with NARROWER-ZIP-RANGE for the ***/
  /*** records which are narrower than the other.                               ***/
  ELIMINATE_OVERLAPPED_RANGE(senior_segment,
                              default_start_date);
  current_level := 0;

  /* COUNTRY Segments are not loaded via the interface table */
  if qualifier( 0 ) = 'COUNTRY' then
    begin

      /* Defaults the country correctly */
      location_id( current_level ) := arp_adds.find_location_segment_id(
                                                'COUNTRY',
                                                nvl( arp_standard.sysparm.default_country, 'US'),
                                                nvl( arp_standard.sysparm.default_country, 'US'),
                                                null,
                                                attribute_category => 'TRIGGER' );

      if arp_adds.location_segment_inserted then

        arp_adds.ins_location_rates( location_id(current_level),
                                     arp_standard.sysparm.from_postal_code,
                                     arp_standard.sysparm.to_postal_code,
                                     arp_standard.min_start_date,
                                     arp_standard.max_end_date,
                                     0,
                                     attribute_category => 'TRIGGER' );
      end if;

      location_value( current_level ) := nvl( arp_standard.sysparm.default_country, 'US' );
      qual_adjust := 0;

    end;

  else

    location_value( current_level ) := null;
    qual_adjust := 1;
    location_id( current_level ) := null;

  end if;

  location_from_postal_code( current_level ) := arp_standard.sysparm.from_postal_code;
  location_to_postal_code( current_level ) := arp_standard.sysparm.to_postal_code;
  location_start_date( current_level ) := arp_standard.min_start_date;
  location_end_date( current_level ) := arp_standard.max_end_date;

  /*--------------------------------------------------------------------------+
   | Loop over each record of the tax_interface table, selecting the rows     |
   | in the hierarchy of the location flexfield.                              |
   | The Tree Walk Query Ensures that every parent value is read before       |
   | reading any new children. It also ensures that all children for a given  |
   | parent are found next to each other.                                     |
   |                                                                          |
   | Example Data                                                             |
   | Qual     LEVEL  LOCATION_VALUE           ZIP_START  ZIP_END    TAX_RATE  |
   | -------- -----  ------------------------ ---------- ---------- --------- |
   | STATE        1  CA                       90000      96699           6.25 |
   |  COUNTY      2  SACRAMENTO                                           1.5 |
   |    CITY      3  ARDEN ARCADE             95825      95825              0 |
   |                                                                          |
   | If any records are orphans, the declared parent does not exist, they     |
   | will not be found by this cursor, and so the status of each will remain  |
   | unchanged.                                                               |
   +--------------------------------------------------------------------------*/


  FOR interface in interface_c( arp_standard.profile.request_id, senior_segment )
  LOOP
    BEGIN
      interface.start_date := trunc( interface.start_date );
      interface.end_date := arp_standard.ceil( interface.end_date );

      if pg_debug='Y' then
        arp_util_tax.debug( 'INTERFACE: ' || to_char( interface.level, 0)
                        || '.' || interface.location_value || ' '
                        || to_char( interface.start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                        ' .. ' || to_char(interface.end_date, 'DD-MON-YYYY HH24:MI:SS' ) ||
                        ' =' || to_char( interface.tax_rate, '990.00' ) );
      end if;

      action := 'READ';           -- Initial value of Action
      error_text := null;

      /*------------------------------------------------------------------------+
       | Check interface.qualifier and interface.level to ensure that the user  |
       | has not missed a segment in the flexfield structure, take for example: |
       | The Default installation of COUNTRY.STATE.COUNTY.CITY then:-           |
       |   level: 0 records (not loaded from the interface ) should be COUNTRY. |
       |   level: 1 records should be marked as STATE                           |
       |   level: 2 records should be marked as COUNTY                          |
       |   level: 3 records should be marked as CITY                            |
       | Any records deeper than level 3 should be errored, any qualifiers that |
       | are found but dont match the expected qualifier for that level should  |
       | raise an error.                                                        |
       *------------------------------------------------------------------------*/

      if interface.level > segment then
         arp_standard.fnd_message( 'AR_TAXI_LEVEL_TOO_DEEP' );
      end if;

      if qualifier( interface.level - qual_adjust ) <> interface.segment_qualifier then

         arp_standard.fnd_message( 'AR_TAXI_UNEXPECTED_QUALIFIER',
                                   'EXPECTED', qualifier( interface.level - qual_adjust ),
                                   'FOUND', interface.segment_qualifier );

      end if;

      if interface.location_segment_id is not null then
         arp_standard.fnd_message( 'AR_TAXI_LOC_SEG_ID_HAS_VALUE' );
      end if;

      /*-----------------------------------------------------------------------+
       | Populate table: AR_LOCATION_VALUES                                    |
       *-----------------------------------------------------------------------*/

      /*-----------------------------------------------------------------------+
       | If the segment level has changed, reset the 'old' values kept for     |
       | segments at this level                                                |
       *-----------------------------------------------------------------------*/

      if interface.level <> current_level then
         current_level := interface.level;
         location_id( current_level ) := NULL;
         location_value( current_level ) := '                '; /* Dummy Value */
      end if;

      /*-----------------------------------------------------------------------+
       | Default the from and to postal codes based on the most recent parent  |
       +-----------------------------------------------------------------------*/

       location_from_postal_code( current_level ) :=
                   nvl( interface.from_postal_code, location_from_postal_code( current_level-1 ));
       interface.from_postal_code := location_from_postal_code( current_level ) ;

       location_to_postal_code( current_level ) :=
                 nvl( interface.to_postal_code, location_to_postal_code( current_level-1 ));
       interface.to_postal_code := location_to_postal_code( current_level ) ;

       /*-----------------------------------------------------------------------+
        | Has the location segment value changed since the previous record at   |
        | this level?                                                           |
        *-----------------------------------------------------------------------*/

       IF interface.location_value <> location_value(current_level) THEN

         /*-------------------------------------------------------------------+
          | We have a new location segment value                              |
          +-------------------------------------------------------------------*/

         location_value( current_level ) := interface.location_value;

         /*------------------------------------------------------------------+
          | Check that the the new location id still contains the parent     |
          | location id in the leading n character positions.                |
          | This is needed to ensure that the select distinct, and order by  |
          | clauses added to interface_c will return the row data in the     |
          | correct order.                                                   |
          +------------------------------------------------------------------*/

         /* MB conversion - substr to substrb, converted because this is
            basically a cmparsion */
         if substrb( interface.location_id, 1, lengthb(interface.parent_location_id ) )
            <> interface.parent_location_id then

           arp_standard.fnd_message( 'AR_TAXI_LOCATION_BAD_PARENT',
                                     'LOCATION_ID', interface.location_id,
                                     'PARENT_LOCATION_ID', interface.parent_location_id );
         end if;

         /*------------------------------------------------------------------+
          | Check the database to see if this value has been identified with |
          | this parent before, if not insert the new value.                 |
          | find_location_segment_id returns with the internal id for this   |
          | segment.                                                         |
          +------------------------------------------------------------------*/

         this_location := null;

         /*----------------------------------------------------------------+
          | current_level: Parent is segment id at previous level          |
          | Location_Attributes: Upload Descriptive Flexfield Information  |
          |                      From Tax Interface table                  |
          |                                                                |
          | The data in this interface table may not contain all of the    |
          | characters used to define a City, Vertex(tm) for example only  |
          | lists the first 25 characters of a city name. These truncated  |
          | cities can be manually corrected using the Define Location     |
          | values form, after correction this search_precission parameter |
          | ensures that new versions of the cities tax rate will not be   |
          | assigned to a new (truncated) city but to the existing         |
          | corrected city.                                                |
          +----------------------------------------------------------------*/
         location_id( current_level ) := arp_adds.find_location_segment_id(
                                                     interface.segment_qualifier,
                                                     interface.location_user_value,
                                                     interface.location_description,
                                                     location_id( current_level -1 ),
                                                     interface.location_attribute_category,
                                                     interface.location_attribute1,
                                                     interface.location_attribute2,
                                                     interface.location_attribute3,
                                                     interface.location_attribute4,
                                                     interface.location_attribute5,
                                                     interface.location_attribute6,
                                                     interface.location_attribute7,
                                                     interface.location_attribute8,
                                                     interface.location_attribute9,
                                                     interface.location_attribute10,
                                                     interface.location_attribute11,
                                                     interface.location_attribute12,
                                                     interface.location_attribute13,
                                                     interface.location_attribute14,
                                                     interface.location_attribute15,
                                                     search_precission => max_location_width );


         this_location := location_id( current_level );

         new_location := arp_adds.location_segment_inserted;


       END IF; /* Segment Value has not changed, dont attempt to re-insert it */

       /*-----------------------------------------------------------------------+
        | Populate table: AR_LOCATION_RATES                                     |
        *-----------------------------------------------------------------------*/

       if interface.status = 'IGNORED-NARROWER-ZIP' then
         action := 'IGNORED-NARROWER-ZIP';
         new_location := FALSE;
       else
         action := 'INSERT';
       end if;

       if new_location then

         if interface.tax_rate is NULL and
            interface.from_postal_code = arp_standard.sysparm.from_postal_code and
            interface.to_postal_code   = arp_standard.sysparm.to_postal_code then
           action := 'NEW-LOCATION';
         else
           action := 'NEW-LOCATION-INSERT';
         end if;

         new_location := FALSE;

       else

         /* for each existing location_rate assigned to sales tax see if the
            record needs updating or inserting */
-- Bug 2609220 added parameter rate_attribute1 to cursor
         for rates in location_rates_c( location_id(current_level),
                                        nvl(interface.from_postal_code,arp_standard.sysparm.from_postal_code),
                                        nvl(interface.to_postal_code,arp_standard.sysparm.to_postal_code),
                                        interface.start_date,
                                        interface.end_date,
                                        interface.rate_attribute1 )

         loop

           if interface.status = 'IGNORED-NARROWER-ZIP' then
             action := 'IGNORED-NARROWER-ZIP';
             exit when true;
           end if;

           /* Overlapping data Exists */

           if pg_debug='Y' then
             arp_util_tax.debug( 'OVERLAP: ' || to_char( rates.start_date, 'DD-MON-YYYY' ) ||
                               ' .. ' || to_char( rates.end_date, 'DD-MON-YYYY' ) ||
                               ' =' || to_char( rates.tax_rate, '990.00' ) );

             arp_util_tax.debug('');
             arp_util_tax.debug('Segment ID: '||to_char(location_id(current_level)));
             arp_util_tax.debug('Value: '||interface.location_value);
             arp_util_tax.debug('Postal Code Old: '||
                        nvl(rates.from_postal_code,arp_standard.sysparm.from_postal_code) ||
                        ' - '||nvl(rates.to_postal_code,arp_standard.sysparm.to_postal_code));
             arp_util_tax.debug('Postal Code New: '||
                        nvl(interface.from_postal_code,arp_standard.sysparm.from_postal_code) ||
                        ' - '||nvl(interface.to_postal_code,arp_standard.sysparm.to_postal_code));
             arp_util_tax.debug('Effective Date Old: '||to_char(trunc(rates.start_date))||
  			' - '||to_char(trunc(rates.end_date)));
             arp_util_tax.debug('Effective Date New: '||to_char(trunc(interface.start_date))||
  			' - '||to_char(trunc(interface.end_date)));
           end if;

           /* Checking Postal Code Range */
           IF ( rates.from_postal_code = interface.from_postal_code ) and
              ( rates.to_postal_code   = interface.to_postal_code  ) THEN
              --arp_util_tax.debug('Interface postal code range identical to existing one');

               /* Checking Date Range */
               IF ( trunc(rates.start_date) = trunc(interface.start_date) ) and
                  ( arp_standard.ceil(rates.end_date) = arp_standard.ceil(interface.end_date) ) THEN

                 /* Compare Tax Rates */
                 IF ( rates.tax_rate > interface.tax_rate ) THEN

    	         /* Bugfix 406993: For the same State.County.City.Zip.Date
    		    combination, Upload the highest tax rate as this is the
    		    safest amount.					   */
                   ACTION := 'ALREADY-EXISTS';

                   if pg_debug='Y' then
                     arp_util_tax.debug('Rate is smaller than existing one');
                   end if;

                 ELSE

                   /* Checking Tax Rate and it's attributes */
                   IF ( rates.tax_rate = interface.tax_rate ) and
                      ( nvl(rates.attribute_category,'x') = nvl(interface.rate_attribute_category,'x')) and
                      ( nvl(rates.attribute1,'x') = nvl(interface.rate_attribute1,'x')) and
                      ( nvl(rates.attribute2,'x') = nvl(interface.rate_attribute2,'x')) and
                      ( nvl(rates.attribute3,'x') = nvl(interface.rate_attribute3,'x')) and
                      ( nvl(rates.attribute4,'x') = nvl(interface.rate_attribute4,'x')) and
                      ( nvl(rates.attribute5,'x') = nvl(interface.rate_attribute5,'x')) and
                      ( nvl(rates.attribute6,'x') = nvl(interface.rate_attribute6,'x')) and
                      ( nvl(rates.attribute7,'x') = nvl(interface.rate_attribute7,'x')) and
                      ( nvl(rates.attribute8,'x') = nvl(interface.rate_attribute8,'x')) and
                      ( nvl(rates.attribute9,'x') = nvl(interface.rate_attribute9,'x')) and
                      ( nvl(rates.attribute10,'x') = nvl(interface.rate_attribute10,'x')) and
                      ( nvl(rates.attribute11,'x') = nvl(interface.rate_attribute11,'x')) and
                      ( nvl(rates.attribute12,'x') = nvl(interface.rate_attribute12,'x')) and
                      ( nvl(rates.attribute13,'x') = nvl(interface.rate_attribute13,'x')) and
                      ( nvl(rates.attribute14,'x') = nvl(interface.rate_attribute14,'x')) and
                      ( nvl(rates.attribute15,'x') = nvl(interface.rate_attribute15,'x')) and
                      ( nvl(rates.override_rate1,-99) = nvl(interface.override_rate1,-99)) and
                      ( nvl(rates.override_rate2,-99) = nvl(interface.override_rate2,-99)) and
                      ( nvl(rates.override_rate3,-99) = nvl(interface.override_rate3,-99)) and
                      ( nvl(rates.override_rate4,-99) = nvl(interface.override_rate4,-99)) and
                      ( nvl(rates.override_rate5,-99) = nvl(interface.override_rate5,-99)) and
                      ( nvl(rates.override_rate6,-99) = nvl(interface.override_rate6,-99)) and
                      ( nvl(rates.override_rate7,-99) = nvl(interface.override_rate7,-99)) and
                      ( nvl(rates.override_rate8,-99) = nvl(interface.override_rate8,-99)) and
                      ( nvl(rates.override_rate9,-99) = nvl(interface.override_rate9,-99)) and
                      ( nvl(rates.override_rate10,-99) = nvl(interface.override_rate10,-99)) THEN

                     ACTION := 'ALREADY-EXISTS';
                     if pg_debug='Y' then
                       arp_util_tax.debug('Everythings is the same');
                     end if;
                   ELSE
                     ACTION := 'RATE-ADJUST';
                     rates.tax_rate := interface.tax_rate;
                     if pg_debug='Y' then
                       arp_util_tax.debug('Rate is bigger than existing one');
                     end if;
                   END IF; -- Checking Tax Rate and it's attributes

                 END IF; -- Compare Tax Rates

               ELSE

                 ACTION := date_adjust( rates.start_date,
                                        rates.end_date,
                                        interface.start_date,
                                        interface.end_date );
                 if pg_debug='Y' then
                   arp_util_tax.debug('Date ranges are overlapping');
                end if;

               END IF; -- Checking Date Range

           ELSIF  ( ( interface.from_postal_code >= rates.from_postal_code ) and
                    ( interface.to_postal_code <= rates.to_postal_code  ) ) THEN

             if pg_debug='Y' then
               arp_util_tax.debug('Postal Code Range in interface table is Narrower than existing one.');
             end if;

               IF trunc(rates.start_date) = trunc(interface.start_date) and
                  arp_standard.ceil(rates.end_date) = arp_standard.ceil(interface.end_date) THEN
                  ACTION := 'ZIP-RANGE-UPDATED'; -- logic to end date broader range later in the code
                 if pg_debug='Y' then
                    arp_util_tax.debug('Narrower zip range with same geocode and dates same');
                 end if;

               ELSE
                  ACTION := date_adjust( rates.start_date,
                                         rates.end_date,
                                         interface.start_date,
                                         interface.end_date );
                   if pg_debug='Y' then
                     arp_util_tax.debug('Narrower zip range with same geocode and dates different');
                   end if;


                  IF ACTION = 'ALREADY-EXISTS' THEN
                    IF trunc(rates.start_date) = trunc(rates.end_date) and
                       trunc(rates.start_date) = trunc(interface.start_date) then
                       interface.start_date := interface.start_date + 1;
                       action := 'INSERT';
                    END IF;
                  END IF;

               END IF; -- Checking Date Range

  	   ELSE
            if pg_debug='Y' then
                arp_util_tax.debug('Postal Code Range in AR_LOCATION_RATES is included in the one in Interface.');
            end if;

             /* Checking Date Range */
             IF trunc(rates.start_date) = trunc(interface.start_date) and
                arp_standard.ceil(rates.end_date) = arp_standard.ceil(interface.end_date) THEN
               ACTION := 'ZIP-RANGE-UPDATED';

               if pg_debug='Y' then
                 arp_util_tax.debug('Zip ranges are overlapping');
               end if;

             ELSE
               ACTION := date_adjust( rates.start_date,
                                      rates.end_date,
                                      interface.start_date,
                                      interface.end_date );
              if pg_debug='Y' then
                arp_util_tax.debug('Zip and date ranges are overlapping');
              end if;
             END IF; -- Checking Date Range
           END IF; -- Checking Postal Code Range

           if action = 'UPDATE-INSERT' then
             if pg_debug='Y' then
                arp_util_tax.debug( 'UPDATE old data: ' || rates.location_rate_id || ' '  ||
                                rates.from_postal_code || '->' || rates.to_postal_code || '  ' ||
                                rates.start_date || '->' || rates.end_date ||
                                ' = ' || rates.tax_rate );
             end if;

  	     /* BUGFIX: 256136, Updating old records should affect the effective date values
                of the old record; no other columns should be touched */

             update ar_location_rates
             set    start_date = rates.start_date,
                    end_date = rates.end_date,
                    program_id = arp_standard.profile.program_id,
                    program_application_id = arp_standard.profile.program_application_id,
                    program_update_date = sysdate,
                    request_id = arp_standard.profile.request_id,
                    LAST_UPDATED_BY  = arp_standard.profile.user_id,
                    LAST_UPDATE_DATE = sysdate
             where  current of location_rates_c;
             /* BUGFIX 1965591 : Continue in loop till all overlapping records handled */
             --exit when true;

  	   elsif action = 'RATE-ADJUST' then
             if pg_debug='Y' then
               arp_util_tax.debug( 'UPDATE RATE-ADJUST old data: ' || rates.location_rate_id || ' '  ||
                                  rates.from_postal_code || '->' || rates.to_postal_code || '  ' ||
                                  rates.start_date || '->' || rates.end_date ||
                                  ' = ' || rates.tax_rate );
             end if;

             update ar_location_rates
             set    from_postal_code = rates.from_postal_code,
                    to_postal_code = rates.to_postal_code,
                    start_date = rates.start_date,
                    end_date = rates.end_date,
                    tax_rate = rates.tax_rate,
                    override_rate1  = interface.override_rate1,
                    override_rate2  = interface.override_rate2,
                    override_rate3  = interface.override_rate3,
                    override_rate4  = interface.override_rate4,
                    override_rate5  = interface.override_rate5,
                    override_rate6  = interface.override_rate6,
                    override_rate7  = interface.override_rate7,
                    override_rate8  = interface.override_rate8,
                    override_rate9  = interface.override_rate9,
                    override_rate10 = interface.override_rate10,
                    program_id = arp_standard.profile.program_id,
                    program_application_id = arp_standard.profile.program_application_id,
                    program_update_date = sysdate,
                    request_id = arp_standard.profile.request_id,
                    LAST_UPDATED_BY  = arp_standard.profile.user_id,
                    LAST_UPDATE_DATE = sysdate,
                    attribute_category = interface.rate_attribute_category,
                    attribute1  = interface.rate_attribute1,
                    attribute2  = interface.rate_attribute2,
                    attribute3  = interface.rate_attribute3,
                    attribute4  = interface.rate_attribute4,
                    attribute5  = interface.rate_attribute5,
                    attribute6  = interface.rate_attribute6,
                    attribute7  = interface.rate_attribute7,
                    attribute8  = interface.rate_attribute8,
                    attribute9  = interface.rate_attribute9,
                    attribute10 = interface.rate_attribute10,
                    attribute11 = interface.rate_attribute11,
                    attribute12 = interface.rate_attribute12,
                    attribute13 = interface.rate_attribute13,
                    attribute14 = interface.rate_attribute14,
                    attribute15 = interface.rate_attribute15
             where  current of location_rates_c;
            /* BUGFIX 1965591 : Continue in loop till all overlapping records handled */
             --exit when true;
           elsif action = 'ZIP-RANGE-UPDATED' then
             if pg_debug='Y' then
               arp_util_tax.debug( 'ZIP-RANGE-UPDATED old data: ' || rates.location_rate_id || ' '  ||
                                 rates.from_postal_code || '->' || rates.to_postal_code || '  ' ||
                                 rates.start_date || '->' || rates.end_date ||
                                 ' = ' || rates.tax_rate );

             end if;
             update ar_location_rates
             set    end_date = start_date,
                    program_id       = arp_standard.profile.program_id,
                    program_application_id = arp_standard.profile.program_application_id,
                    program_update_date = sysdate,
                    request_id = arp_standard.profile.request_id,
                    LAST_UPDATED_BY  = arp_standard.profile.user_id,
                    LAST_UPDATE_DATE = sysdate
             where  current of location_rates_c;
--             exit when true;

           end if;
         end loop; /* Overlapping Rates */
       end if;  /* Check on new location */

       if action = 'ZIP-RANGE-UPDATED' then
         if (arp_standard.ceil(interface.end_date) = interface.start_date) then
           if interface.end_date is not null  then
             interface.end_date := interface.end_date +1;
           end if;
         end if;
         interface.start_date := interface.start_date +1;
         action := 'UPDATE-INSERT';
       end if;

       /*************************************************************************************
        *  Final Check on database; this extra loop is required to ensure that the database *
        *  never gets duplicate or overlapping rows created                                 *
        *  Bugfix 2377918 narrower overlapping zip ranges will be allowed if geocodes are   *
        *  different                                                                        *
        *************************************************************************************/

       if action = 'INSERT' or
          action = 'UPDATE-INSERT' or
          action = 'NEW-LOCATION-INSERT' then
  -- Bug 2609220 added parameter p_rate_attribute1
         for rates in location_rates_c( location_id(current_level),
                                          interface.from_postal_code,
                                          interface.to_postal_code,
                                          interface.start_date,
                                          interface.end_date,
                                          interface.rate_attribute1 )
         loop
           action := 'ALREADY-EXISTS';
           exit when true;
         end loop;

       end if;

       if pg_debug='Y' then
         arp_util_tax.debug('Action: '||action);
       end if;

       if action = 'INSERT' or
          action = 'UPDATE-INSERT' or
          action = 'NEW-LOCATION-INSERT' then

         if pg_debug='Y' then
           arp_util_tax.debug( 'Row inserted: ' || location_id(current_level) || ' ' ||
                             interface.from_postal_code || '->' || interface.to_postal_code || ' ' ||
                             interface.start_date || '->' || interface.end_date );
         end if;


         /*---------------------------------------------+
          | Upload Basic Information about the Rate,    |
          | A Rate exists within A postal code range    |
          | and an effectivity date range.              |
          | Upload Descriptive Flexfield Information    |
          | From Tax Interface table                    |
          | Upload Rate Information Overrides, supports |
          | State and County Override.                  |
          +---------------------------------------------*/

         arp_adds.ins_location_rates(
                                    location_id(current_level),
                                    interface.from_postal_code,
                                    interface.to_postal_code,
                                    interface.start_date,
                                    interface.end_date,
                                    interface.tax_rate,
                                    interface.rate_attribute_category,
                                    interface.rate_attribute1,
                                    interface.rate_attribute2,
                                    interface.rate_attribute3,
                                    interface.rate_attribute4,
                                    interface.rate_attribute5,
                                    interface.rate_attribute6,
                                    interface.rate_attribute7,
                                    interface.rate_attribute8,
                                    interface.rate_attribute9,
                                    interface.rate_attribute10,
                                    interface.rate_attribute11,
                                    interface.rate_attribute12,
                                    interface.rate_attribute13,
                                    interface.rate_attribute14,
                                    interface.rate_attribute15,
                                    interface.override_structure_id,
                                    interface.override_rate1,
                                    interface.override_rate2,
                                    interface.override_rate3,
                                    interface.override_rate4,
                                    interface.override_rate5,
                                    interface.override_rate6,
                                    interface.override_rate7,
                                    interface.override_rate8,
                                    interface.override_rate9,
                                    interface.override_rate10 );

         if interface.from_postal_code <> arp_standard.sysparm.from_postal_code then

           if interface.from_postal_code < location_from_postal_code( current_level -1 ) and
              interface.level > 1 then

             error_text := arp_standard.fnd_message( arp_standard.md_msg_text,
                                                     'AR_TAXI_BAD_FROM_POSTAL_CODE',
                                                     'FOUND',
                                                     interface.from_postal_code,
                                                     'EXPECTED',
                                                     location_from_postal_code(current_level-1));
           end if;
         end if;

         if interface.to_postal_code <> arp_standard.sysparm.to_postal_code then

           if interface.to_postal_code > location_to_postal_code( current_level -1 ) and
              interface.level > 1 then

             error_text := arp_standard.fnd_message( arp_standard.md_msg_text,
                                                     'AR_TAXI_BAD_TO_POSTAL_CODE',
                                                     'FOUND',
                                                     interface.to_postal_code,
                                                     'EXPECTED',
                                                     location_to_postal_code( current_level -1 ));
           end if;
         end if;

       end if;

       if pg_debug='Y' then
         arp_util_tax.debug( 'ACTION: ' || action || ' Location Segment ID = ' || this_location );
       end if;

    EXCEPTION
      WHEN OTHERS THEN
        BEGIN
          error_code := sqlcode;
          error_text := sqlerrm;
          if pg_debug='Y' then
            arp_util_tax.debug(sqlcode);
            arp_util_tax.debug(sqlerrm);
            arp_util_tax.debug( 'ERROR: ' || action || ' Location Segment ID = ' || this_location );
          end if;

          if error_code = arp_standard.ar_error_number then
            error_text := arp_standard.fnd_message( arp_standard.md_msg_text );
          end if;

          ACTION := 'ORA' || to_char( error_code, '09999' );
          error_count := error_count + 1;

          /*Too Many Extents in table, index or rollback, failed to extend rollback segment, */
          if error_code in ( 1562, 1631, 1630, 1632, 1629 ) THEN
            /**** MB conversion substr to substrb ***/
            arp_standard.fnd_message( 'AR_ALL_SQL_ERROR', 'ROUTINE', 'TAX_INTERFACE',
                                                        'ERR_NUMBER', to_char(error_code, '09999' ),
                                                        'SQL_ERROR', substrb(error_text,1,60) );
          end if;

          if error_count > max_error_count then
            /*** MB conversion, substr to substrb, Note - This could have ***/
            /*** left alone ***/
            if upper(substrb(commit_on_each_senior_segment,1,1)) = 'Y' then
              commit work;
            end if;

	    /**** MB conversion substr to substrb ***/
            arp_standard.fnd_message( 'AR_STAX_TOO_MANY_ERRORS',
                                     'SQLCODE', to_char(error_code, '09999'),
                                     'SQLERRM', substrb(error_text,1,60),
                                     'MAX_ERRORS', to_char(max_error_count, '9999999999')) ;
          end if;

        END;  /* EXCEPTION HANDLER BLOCK */

    END;  /* EXCEPTION PROTECTED BLOCK */

    UPDATE AR_TAX_INTERFACE
    SET    STATUS = action,
           /*** MB conversion substr to substrb ***/
           ERROR_MESSAGE = substrb(error_text,1,240),
           LOCATION_SEGMENT_ID = this_location,
           LAST_UPDATED_BY  = arp_standard.profile.user_id,
           LAST_UPDATE_DATE = sysdate,
           PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id,
           PROGRAM_ID = arp_standard.profile.program_id,
           REQUEST_ID = arp_standard.profile.request_id
    WHERE  interface_line_id = interface.interface_line_id;

  END LOOP; /* For Each line of the Tax Interface Table */

END load_segment_values;


PROCEDURE Upload_Sales_Tax( commit_on_each_senior_segment in varchar2 default 'Y',
                            change_control     in varchar2   default 'N',
                            default_start_date in date       default to_date('01-01-1900', 'dd-mm-yyyy'),
                            senior_segment     in varchar2   default null,
                            max_error_count    in number     default 1000
 ) is
cursor sel_segments_null( senior_segment in varchar2 ) is
 select distinct location_value
 from   ar_tax_interface
 where  parent_location_id is null
 and    rate_type = 'SALES'
 and    location_value like nvl(senior_segment,location_value)
 order by location_value;

cursor sel_segments( senior_segment in varchar2 ) is
 select distinct location_value
 from   ar_tax_interface
 where  parent_location_id is null
 and    rate_type = 'SALES'
 and    location_value like senior_segment
 order by location_value;

BEGIN
   --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
   PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

   error_count := 0;
   if senior_segment is null
   then

      for segment in sel_segments_null(senior_segment)
      loop
         load_segment_values( change_control, default_start_date,
                              segment.location_value, max_error_count, commit_on_each_senior_segment );

	 /*** MB conversion, substr to substrb, Note - This could have ***/
         /*** left alone ***/
         if upper(substrb(commit_on_each_senior_segment,1,1)) = 'Y'
         then
            commit work;
         end if;

      end loop;

   else
      for segment in sel_segments(senior_segment)
      loop
         load_segment_values( change_control, default_start_date,
                              segment.location_value, max_error_count, commit_on_each_senior_segment );

	 /*** MB conversion, substr to substrb, Note - This could have ***/
         /*** left alone ***/
         if upper(substrb(commit_on_each_senior_segment,1,1)) = 'Y'
         then
            commit work;
         end if;

      end loop;

   end if;

END;

BEGIN /* Initialisation Section */

 --PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
 PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

   /*----------------------------------------------------------------------+
    | Setup the data structure: qualifier( 1.. max_number_of_segments ) so |
    | that each entry in the array contains the qualifier for the segment  |
    | in that position of the Sales Tax Location Flexfield.                |
    +----------------------------------------------------------------------*/

   /*----------------------------------------------------------------------+
    |  Get Each Segment Qualifier, in order segment order for the Key      |
    |  flexfield: Sales Tax Location Flexfield.                            |
    |  EG: COUNTRY.STATE.COUNTY.CITY                                       |
    +----------------------------------------------------------------------*/

   LOCATION_SEGMENTS := ltrim(rtrim(
                          replace(replace(
                          replace(replace(
                          arp_flex.expand( arp_flex.location, 'ALL', ' ' ,
                                           '%QUALIFIER%' ),
                          ' TAX_ACCOUNT',null), 'TAX_ACCOUNT ',null),
                          ' EXEMPT_LEVEL', NULL), 'EXEMPT_LEVEL ')));

   segment := 0;
   qualifier( segment ) := null;

   while arp_standard.get_next_word( LOCATION_SEGMENTS, qualifier( segment ) )
   loop
      segment := segment + 1;
      qualifier( segment ) := null;
   end loop;

   /*------------------------------------------------------------------------+
    | Determine the Maximum width of incomming City names, this then becomes |
    | the precission that is used when find_location_segment_id is called    |
    | given a Parent ID and Segment Value.                                   |
    | BUGFIX: INC: 27093                                                     |
    +------------------------------------------------------------------------*/

    BEGIN
       /*** MB skip, we want the character length ***/
       select max(lengthb(location_value))
       into   max_location_width
       from   ar_tax_interface;
    EXCEPTION
       WHEN NO_DATA_FOUND
       THEN max_location_width := null;
    END;


END ARP_TAX_INTERFACE;

/
