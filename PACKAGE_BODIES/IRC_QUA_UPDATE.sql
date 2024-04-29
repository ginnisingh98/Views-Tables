--------------------------------------------------------
--  DDL for Package Body IRC_QUA_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_QUA_UPDATE" AS
/* $Header: irquaupg.pkb 120.0 2005/07/26 15:16 mbocutt noship $*/

-- ----------------------------------------------------------------------------
-- |--------------------------< update_qualification_data >-------------------|
-- ----------------------------------------------------------------------------
procedure update_qualification_data(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
-- This cursor loops over all qualification records which doesn't have a person_id
-- and business_group_id
--
  cursor csr_upd_qualification is
    select pea.person_id person_id
          ,pea.business_group_id business_group_id
          ,pq.attendance_id attendance_id
      from per_qualifications pq
          ,per_establishment_attendances pea
     where pea.attendance_id = pq.attendance_id
       and pea.attendance_id between p_start_pkid and p_end_pkid
       and pq.person_id is null
       and pq.business_group_id is null;
  l_rows_processed number := 0;
--
begin
  for csr_rec in csr_upd_qualification
  loop
    update per_qualifications
       set person_id = csr_rec.person_id
          ,business_group_id = csr_rec.business_group_id
     where attendance_id=csr_rec.attendance_id;
    l_rows_processed := l_rows_processed + 1;
  end loop;
  p_rows_processed := l_rows_processed;
end update_qualification_data;
--
end irc_qua_update;

/
