--------------------------------------------------------
--  DDL for Package PQH_DE_TKTDTLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_TKTDTLS_API" AUTHID CURRENT_USER as
/* $Header: pqtktapi.pkh 120.0 2005/05/29 02:49:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_TKTDTLS_API> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API Creates the the master definition of Tatikeigt details
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure Insert_TKT_DTLS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_TATIGKEIT_NUMBER              In  Varchar2 Default NULL
  ,P_DESCRIPTION                   In  Varchar2
  ,P_TATIGKEIT_DETAIL_ID           out nocopy Number
  ,p_object_version_number         out nocopy number);

procedure Update_TKT_DTLS
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_TATIGKEIT_NUMBER              In  Varchar2 Default hr_api.g_Varchar2
  ,P_DESCRIPTION                   In  Varchar2 Default hr_api.g_Varchar2
  ,P_TATIGKEIT_DETAIL_ID           In  Number
  ,p_object_version_number         in out nocopy number);

procedure delete_TKT_DTLS
  (p_validate                      in     boolean  default false
  ,p_TATIGKEIT_DETAIL_ID           In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_TKTDTLS_API;

 

/
