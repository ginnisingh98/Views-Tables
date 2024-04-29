--------------------------------------------------------
--  DDL for Package Body OTA_EXTRA_COMPETENCE_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EXTRA_COMPETENCE_CHK" as
/* $Header: otcmpchk.pkb 115.2 2001/12/09 02:29:24 pkm ship        $ */

procedure chk_competence
  (p_competence_id                   in     number
   ) is

l_competence_id  number;

Cursor c_comp
is
select competence_id
from ota_competence_languages
where competence_id = p_competence_id;

begin
   --
   --

   open c_comp;
   fetch c_comp into l_competence_id;
   close c_comp;

   if l_competence_id is not null then
       fnd_message.set_name('OTA','OTA_COMP_EXIST');
       fnd_message.raise_error;
   end if;

end chk_competence;

end ota_extra_competence_chk;

/
