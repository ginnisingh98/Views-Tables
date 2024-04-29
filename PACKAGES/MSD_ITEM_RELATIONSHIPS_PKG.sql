--------------------------------------------------------
--  DDL for Package MSD_ITEM_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_ITEM_RELATIONSHIPS_PKG" AUTHID CURRENT_USER AS
/* $Header: msdsupss.pls 120.1 2005/11/22 03:37:27 amitku noship $ */
/* This procedure to collect supersession data from source instance to DP tables*/

PROCEDURE collect_supersession_data (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number
);

/* This procedure to delete events data by instance */

PROCEDURE delete_events_data (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  p_event_id              in number
);

/* This procedure to update supersession events in DP events table */

PROCEDURE update_supersession_events (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_event_name            in varchar2
);

/* This procedure to create supersession events in DP events table */

PROCEDURE create_supersession_events (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  p_event_name            in varchar2
);

/* This procedure to pull supersession data from DP staging table */

PROCEDURE pull_supersession_data (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2
);


/* This procedure will insert supersession data in to DP table */

PROCEDURE insert_event_products (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  l_event_id              in number,
  l_seq_id                in number,
  l_level_id              in number,
  l_inventory_item        in varchar2,
  l_inventory_item_id     in varchar2,
  l_start_time            in date,           --bug 4707819
  l_end_time              in date            --bug 4707819
);

/* This procedure will insert supersession data in to DP table */

PROCEDURE insert_evt_prod_relationships (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  l_event_id              in number,
  l_seq_id                in number,
  l_relation_id           in number,
  l_level_id              in number,
  l_related_item          in varchar2,
  l_related_item_id       in varchar2,
  l_qty_mod_type          in number,
  l_qty_mod_factor        in number,
  l_npi_prd_relshp        in number,
  l_start_time            in date,              --bug 4707819
  l_end_time              in date               --bug 4707819
);


/* This procedure will insert supersession data in to DP table */

PROCEDURE insert_evt_product_details (
  errbuf                  out NOCOPY varchar2,
  retcode                 out NOCOPY varchar2,
  p_instance_id           in number,
  l_event_id              in number,
  l_seq_id                in number,
  l_detail_id             in number,
  l_relation_id           in number,
  l_level_id              in number,
  l_related_item          in varchar2,
  l_related_item_id       in varchar2,
  l_qty_mod_type          in number,
  l_qty_mod_factor        in number
);



END MSD_ITEM_RELATIONSHIPS_PKG;

 

/
