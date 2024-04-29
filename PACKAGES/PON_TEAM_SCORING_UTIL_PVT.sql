--------------------------------------------------------
--  DDL for Package PON_TEAM_SCORING_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_TEAM_SCORING_UTIL_PVT" AUTHID CURRENT_USER AS
/*$Header: PONVSTUS.pls 120.2 2005/10/13 14:06:28 sahegde noship $*/


--------------------------------------------------------------------------------
--                      Lock_Scoring                                          --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: lock_scoring
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This procedure performs following 2 functions
-- 		 1. Record the supplied auction as locked for scoring
--		 2. Calculate the average of scored attributes and insert into
--		    PON_BID_ATTRIBUTE_VALUES
--
--
-- IN Parameters:
--   p_api_version             NUMBER
--   p_auction_header_id       pon_auction_headers_all%auction_header_id%TYPE
--   p_tpc_id 		   	 pon_auction_headers_all%trading_partner_contact_id
--
-- OUT Parameters
--
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--                               U - Unexpected Error/ S-success
--	 x_msg_data                OUT NOCOPY VARCHAR2
--     x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE lock_scoring(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN  pon_auction_headers_all.auction_header_id%TYPE
	    ,p_tpc_id                  IN pon_auction_headers_all.trading_partner_contact_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          );



--------------------------------------------------------------------------------
--                      delete_member_scores                                  --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: delete_member_scores
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This procedure deletes the scores entered by a member on
--           a particular auction. Scores on all bids will be deleted.
--           Its likely that user may not have entered any scores on
--           this auction and therefore the table pon_team_member_attr_scores
--           does not have any rows for supplied auction header and the user.
--
--
-- IN Parameters:
--   p_api_version             NUMBER
--   p_auction_header_id       pon_auction_headers_all.auction_header_id%TYPE
--   p_team_id 				   pon_scoring_teams.team_id%TYPE
--   p_user_id 		   	       fnd_user.user_id%TYPE
--
-- OUT Parameters
--
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--                               U - Unexpected Error/ S-success
--	 x_msg_data                OUT NOCOPY VARCHAR2
--     x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE delete_member_scores(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN  pon_auction_headers_all.auction_header_id%TYPE
	    ,p_team_id 				   IN  pon_scoring_teams.team_id%TYPE
	    ,p_user_id                 IN  fnd_user.user_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          );


--------------------------------------------------------------------------------
--                      delete_team_scores                                    --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: delete_team_scores
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This procedure deletes the scores entered by members on
--           a team for a particular auction. Scores on all bids will be deleted.
--           Its likely that users may not have entered any scores on
--           this auction and therefore the table pon_team_member_attr_scores
--           does not have any rows for supplied auction header and the team.
--
--
-- IN Parameters:
--   p_api_version             NUMBER
--   p_auction_header_id       pon_auction_headers_all.auction_header_id%TYPE
--   p_team_id 		   	 pon_scoring_teams.team_id%TYPE
--
-- OUT Parameters
--
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--                               U - Unexpected Error/ S-success
--	 x_msg_data                OUT NOCOPY VARCHAR2
--     x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE delete_team_scores(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN  pon_auction_headers_all.auction_header_id%TYPE
	    ,p_team_id                 IN pon_scoring_teams.team_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          );

--------------------------------------------------------------------------------
--                      delete_subjective_scores                                    --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: delete_subjective_scores
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This procedures deletes all subjective scores entered for an auction
--           from the pon_bid_attribute_values. This method will be called only
--           after user confirms the deletion of the scores. This method will be
--           called for those auctions that are subjectively scored but not 'Team Scored'
--           and are enabled for team scoring midway. Scores for all bids will be
--           deleted. Only manually scores attributes will be deleted.
--
--
-- IN Parameters:
--   p_api_version             NUMBER
--   p_auction_header_id       pon_auction_headers_all.auction_header_id%TYPE
--
-- OUT Parameters
--
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--                               U - Unexpected Error/ S-success
--	 x_msg_data                OUT NOCOPY VARCHAR2
--     x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE delete_subjective_scores(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN  pon_auction_headers_all.auction_header_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          );

--------------------------------------------------------------------------------
--                      delete_section_assignment                                    --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: delete_section_assignment
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This procedure deletes the section assignement from the
-- pon_scoring_team_sections on section deletion during either create or manage
-- flow.
--
--
-- IN Parameters:
--   p_api_version             NUMBER
--   p_auction_header_id       pon_auction_headers_all.auction_header_id%TYPE
--   p_section_id              pon_auction_headers_all.section_id%TYPE
--
-- OUT Parameters
--
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--                               U - Unexpected Error/ S-success
--	 x_msg_data                OUT NOCOPY VARCHAR2
--     x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE delete_section_assignment(
          p_api_version              IN  NUMBER
	      ,p_auction_header_id       IN  pon_scoring_team_sections.auction_header_id%TYPE
          ,p_section_id              IN pon_scoring_team_sections.section_id%TYPE
     	  ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          );

--------------------------------------------------------------------------------
--                      Unlock_Scoring                                          --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: unlock_scoring
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This procedure performs following 3 functions
-- 		 1. Record the supplied auction as unlocked or open for scoring
--		 2. Update score and internal note to null on the manually scored attributes
--          for the supplied auction header id in PON_BID_ATTRIBUTE_VALUES
--       3. Erases score override information from the PON_BID_HEADERS
--
-- IN Parameters:
--   p_api_version             NUMBER
--   p_auction_header_id       pon_auction_headers_all%auction_header_id%TYPE
--   p_tpc_id 		   	 pon_auction_headers_all%trading_partner_contact_id
--
-- OUT Parameters
--
--
--	 x_return_status           OUT NOCOPY VARCHAR2
--                               U - Unexpected Error/ S-success
--	 x_msg_data                OUT NOCOPY VARCHAR2
--     x_msg_count               OUT NOCOPY NUMBER
--
-- RETURNS: None
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE unlock_scoring(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN  pon_auction_headers_all.auction_header_id%TYPE
	    ,p_tpc_id                  IN pon_auction_headers_all.trading_partner_contact_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          );


END PON_TEAM_SCORING_UTIL_PVT;

 

/
