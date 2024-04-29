--------------------------------------------------------
--  DDL for Package PON_CONSOLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_CONSOLE_PVT" AUTHID CURRENT_USER AS
/* $Header: PONVCONS.pls 120.0 2005/06/01 16:30:32 appldev noship $ */

---
--- +=======================================================================+
--- |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
--- |                         All rights reserved.                          |
--- +=======================================================================+
--- |
--- | FILENAME
--- |     PONVCONS.pls
--- |
--- |
--- | DESCRIPTION
--- |
--- |     This package contains procedures called from the live console
--- |     for Supplier activites
--- |
--- | HISTORY
--- |
--- |     14-Jun-2004 sparames   Initial version
--- |     30-Jun-2004 sahegde    Added procedrues for supplier activities,
--- |                            debugging
--- |     02-Dec-2004 sahegde    Added procedure for calculate_console_summary
--- |
--- |
--- +=======================================================================+
---

--------------------------------------------------------------------------------
--                   get_time_axis_tick_labels                                --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: get_time_axis_tick_labels
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API provides the live console UI with the values of the ticks
--           for the time-axis graphs.  Time-axis graphs have been implemented
--           in FPK using BI Beans.  However, the time-axis graphs available
--           in BI Beans do not have all the features required by Sourcing.
--           Hence these graphs have been implemented as regular scatter graphs
--           which plot numeric values on the x and y-axes.  Since the requirement
--           was to plot time on the x-axis, this procedure helps define the
--           ticks on the x-axis and other parameters that help the calling
--           function plot values correctly
--
-- Parameters:
--
--              p_auction_header_id     IN           NUMBER
--                   Auction header id - required
--
--              p_graph_start_date      IN           DATE,
--                   If the caller knows the starting point of the graph,
--                   then passing this parameter in will help this procedure
--                   recognize that it does not need to determine it
--                   independently.  The first time this procedure is called
--                   for the header or a line, this will be NULL.  The procedure
--                   will determine this date and pass it back in
--                   x_graph_start_date
--
--              p_auction_close_date    IN           DATE,
--                   This is the final date of the graph.  All the graphs are
--                   used to plot bids coming in and since all bids have to be
--                   in by the close date, this will determine the end point of
--                   the graph
--
--              x_graph_start_date      OUT NOCOPY   DATE,
--                   As mentioned above, this is the starting point of the graph
--                   on the x-axis.  This is also the value that the caller must
--                   use to determine the offset so that it can be converted to
--                   a number.  For example, if the start date is 01-Jan-04 and
--                   the end date is 30-Jan-04, then the entire graph spans 30
--                   days or a little more.  This 30 days is made equivalent to
--                   a constant defined in the package body - 2882880.  If a bid
--                   comes in on 04-Jan-04, then it is 3 days after the start date
--                   and is plotted proportionately. The start date may not be
--                   the date of the first bid but may be at a convenient point
--                   in time slightly before it so that dates are displayed
--                   pleasingly to the user.  This is in the server timezone.
--
--              x_graph_end_date        OUT NOCOPY   DATE,
--                   The end date of the graph.  This may not be the auction
--                   but will be the date of the last tick.  Currently not
--                   used by the caller.  This is in the server timezone.
--
--              x_number_of_ticks       OUT NOCOPY   NUMBER,
--                   This tells the caller the number of divisions on the
--                   graph.  This does not include the starting point of the
--                   graph.  Hence if there are three divisions, this field
--                   will be 3 but 4 points will be plotted on the x-axis
--
--              x_multiplier            OUT NOCOPY   NUMBER,
--                  The caller will multiply the difference between the date
--                  to be plotted and the start date of the graph with this value
--                  to obtain a numeric value that is passed to BI Beans
--
--              x_tick_length           OUT NOCOPY   NUMBER,
--                  This contains the length of each tick as a numeric value.
--                  This is sent to BI Beans so that it knows where to plot
--                  each tick.  It is the range of the graph / number of ticks.
--
--              x_tick_label_1-14       OUT NOCOPY   VARCHAR2,
--                  This is the tick label as plotted on the graph
--                  Depending on the scale of the graph, this will include
--                  the date or date and time or just time.  e.g. of values:
--                  07jun, 07jun 10:40, 10:40
--                  These are coded as individual elements and not as a
--                  table because Java does not understand tables.  These times
--                  are in the client's timezone since these have to be displayed
--                  to the user.
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE  get_time_axis_tick_labels(
		 p_auction_header_id     IN           NUMBER,
		 p_graph_start_date      IN           DATE,
		 p_auction_close_date    IN           DATE,
                 x_graph_start_date      OUT NOCOPY   DATE,
		 x_graph_end_date        OUT NOCOPY   DATE,
		 x_number_of_ticks       OUT NOCOPY   NUMBER,
		 x_multiplier            OUT NOCOPY   NUMBER,
		 x_tick_length           OUT NOCOPY   NUMBER,
                 x_tick_label_1          OUT NOCOPY   VARCHAR2,
                 x_tick_label_2          OUT NOCOPY   VARCHAR2,
                 x_tick_label_3          OUT NOCOPY   VARCHAR2,
                 x_tick_label_4          OUT NOCOPY   VARCHAR2,
                 x_tick_label_5          OUT NOCOPY   VARCHAR2,
                 x_tick_label_6          OUT NOCOPY   VARCHAR2,
                 x_tick_label_7          OUT NOCOPY   VARCHAR2,
                 x_tick_label_8          OUT NOCOPY   VARCHAR2,
                 x_tick_label_9          OUT NOCOPY   VARCHAR2,
                 x_tick_label_10         OUT NOCOPY   VARCHAR2,
                 x_tick_label_11         OUT NOCOPY   VARCHAR2,
                 x_tick_label_12         OUT NOCOPY   VARCHAR2,
                 x_tick_label_13         OUT NOCOPY   VARCHAR2,
                 x_tick_label_14         OUT NOCOPY   VARCHAR2);

--------------------------------------------------------------------------------
--                      check_estimated_qty_available                         --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: check_estimated_qty_available
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API is called by the live console UI for a blanket or CPA
--           that has lines.  It determines whether the estimated quantity is
--           available on all lines.  If estimated quantity is not available,
--           then certain graphs like the savings or amount graphs cannot
--           be shown.
--
--
-- Parameters:
--
--              p_auction_header_id       IN      NUMBER
--                   Auction header id - required
--
--              p_auction_line_number     IN      NUMBER
--                   If the graph is being plotted for a line, then the line
--                   number is required. If this is omitted, the procedure
--                   assumes that a header-level graph is being plotted.
--                   The caller can pass -1 or null to indicate that this
--                   is a header level graph
--
--              x_est_qty_available_flag OUT      VARCHAR2
--                   Returns Y if estimated quantity is available N if not
--
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE  check_estimated_qty_available(
			       p_auction_header_id       IN        NUMBER,
			       p_auction_line_number     IN        NUMBER,
			       x_est_qty_available_flag OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------
--                      upgrade_bid_colors                                    --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: upgrade_bid_colors
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API is called by the live console UI when a negotiation
--           that is being handled does not have colors set for bids.
--
--           Colors are assigned to each bid for the first time.  If
--           a rebid occurs, the color is carried forward.  This enables
--           the graph to plot all related bids with the same color and
--           shape icon.  Though only 16 colors are handled today,
--           color ids are assigned sequentially ascending and can exceed
--           any number.   The console does a mod 16 to display the color.
--           This allows the solution to be scalable - in case it is
--           decided to show more colors, the data in the bids does not have
--           to be changed.
--
--           Related bids are identified as having the same supplier,
--           supplier site and creator
--
--           Use of this procedure eliminates the need to do a costly
--           upgrade of all the pre-FPK data.  Data is "upgraded" on
--           a need basis and the display will only be a little slow
--           for the first time any user accesses an old negotiation.
--
--           The procedure is an autonomous transaction so that it can
--           perform its updates without affecting the transaction of
--           the caller
--
-- Parameters:
--
--              p_auction_header_id     IN           NUMBER
--                   Identifier of the auction that for which the live
--                   console is being shown
--
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE  upgrade_bid_colors( p_auction_header_id  IN  NUMBER);

--------------------------------------------------------------------------------
--                      record_supplier_activity                              --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: record_supplier_activities
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This API is called from within the recordSupplierActivity Util
-- method in the class java/util/SourcingCommonUtil
--
-- Effectively it will be called from controllers of all the pages that a
-- supplier might visit during the course of bidding on a negotiation.
--
-- IN Parameters:
-- p_auction_header_id NUMBER
-- p_auction_header_id_orig_amend NUMBER
-- p_trading_partner_id NUMBER
-- p_trading_partner_contact_id NUMBER
-- p_session_id NUMBER
-- p_activity_code VARCHAR2(25)
-- OUT Parameters:
-- p_record_status BOOLEAN
--               TRUE - activity recorded successfully
--               FALSE - activity recording failed
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE  record_supplier_activity(   p_auction_header_id            IN  NUMBER
	                             , p_auction_header_id_orig_amend IN NUMBER
	                             , p_trading_partner_id           IN NUMBER
	                             , p_trading_partner_contact_id   IN NUMBER
	                             , p_session_id                   IN NUMBER
	                             , p_last_activity_code           IN VARCHAR2
	                             , x_record_status        OUT NOCOPY VARCHAR2);


--------------------------------------------------------------------------------
--                      update_supplier_access                                --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: update_supplier_access
--
-- Type: Private
--
-- Pre-reqs: None
--
-- Function: This API is called from within the updateSupplierAccess Util
-- method in the class java/util/SourcingCommonUtil
--
-- Effectively it will be called from the Manage Supplier Activities page
-- to update the access for a supplier on a negotiation
--
-- IN Parameters:
-- p_auction_header_id NUMBER
-- p_auction_header_id_orig_amend NUMBER
-- p_supplier_trading_partner_id NUMBER
-- p_buyer_contact_id NUMBER
-- p_action VARCHAR2(25)
-- OUT Parameters:
-- p_record_status BOOLEAN
--               TRUE - access update/insert successfully
--               FALSE - access updation failed
--
-- End of Comments
--------------------------------------------------------------------------------

PROCEDURE  update_supplier_access( p_auction_header_id            IN  NUMBER
	                         , p_auction_header_id_orig_amend IN NUMBER
	                         , p_supplier_trading_partner_id  IN NUMBER
	                         , p_buyer_tp_contact_id          IN NUMBER
	                         , p_lock_status                  IN VARCHAR2
	                         , p_lock_reason                  IN VARCHAR2
	                         , x_record_status                OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------
----              calculate_console_summary                        ----
-----------------------------------------------------------------
--
-- Start of Comments
--
-- API Name: calculate_console_summary
--
-- Type    : public
--
-- Pre-reqs: None
--
-- Function: This API is called from ConsoleAMImpl.java to calculate
--           Auction Value, Current Value, Optimal Value(based on Auto
--           Award Recommendation), no bid value and num of lines without bids
--
-- Parameters:
--
--       P_AUCTION_ID         IN  NUMBER
--            Required - Auction_header_id of the negotiation
--
--       x_auction_value     OUT NUMBER
--            Total value of the negotiation, calculated based on
--            line qty and current price
--       x_current_value     OUT NUMBER
--            Total current value of the negotiation, calculated based on
--            awarded qty and current price
--       x_optimal_value     OUT NUMBER
--            Total Value of the negotiation, calculated based on
--            awarded qty and bid price
--       x_no_bid_value     OUT NUMBER
--            Total value of the lines that didn't receive bids, calculated
--            based on line qty and current price
--       x_no_bid_lines     OUT NUMBER
--            Number of lines without bids
-----------------------------------------------------------------
PROCEDURE calculate_console_summary( p_auction_id    IN NUMBER,
                                     x_auction_value OUT NOCOPY NUMBER,
                                     x_current_value OUT NOCOPY NUMBER,
                                     x_optimal_value OUT NOCOPY NUMBER,
                                     x_no_bid_value  OUT NOCOPY NUMBER,
                                     x_no_bid_lines  OUT NOCOPY NUMBER
                                     );

END PON_CONSOLE_PVT;

 

/
