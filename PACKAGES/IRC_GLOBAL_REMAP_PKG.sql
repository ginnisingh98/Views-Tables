--------------------------------------------------------
--  DDL for Package IRC_GLOBAL_REMAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_GLOBAL_REMAP_PKG" AUTHID CURRENT_USER AS
/* $Header: ircremap.pkh 120.0 2005/07/26 15:00:35 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< remap_employee >------------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure remaps  single person/all employees global data
--
--
procedure remap_employee
(
   p_person_id   IN number default null
  ,p_effective_date IN date
);
-- ----------------------------------------------------------------------------
-- |--------------------------< remap_employee >------------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure will be called from the concurrent program.
--   This procedure is overloaded and will in turn call remap_employee(person_id)
--   and commit the data
--
procedure remap_employee
(
   errbuf          out nocopy varchar2
  ,retcode         out nocopy varchar2
  ,p_effective_date in varchar2
  ,p_person_id     in number
);

end irc_global_remap_pkg;

 

/
