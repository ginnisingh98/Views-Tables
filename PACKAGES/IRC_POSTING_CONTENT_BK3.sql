--------------------------------------------------------
--  DDL for Package IRC_POSTING_CONTENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_POSTING_CONTENT_BK3" AUTHID CURRENT_USER as
/* $Header: iripcapi.pkh 120.7 2008/02/21 14:21:22 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_posting_content_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_posting_content_b
(
 P_POSTING_CONTENT_ID       in number
,P_OBJECT_VERSION_NUMBER    in number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_posting_content_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_posting_content_a
(
 P_POSTING_CONTENT_ID       in number
,P_OBJECT_VERSION_NUMBER    in number
);

end IRC_POSTING_CONTENT_BK3;

/
