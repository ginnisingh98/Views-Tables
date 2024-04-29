--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_WORKFLOW" AS
/* $Header: INVRSVWB.pls 120.2 2005/10/11 10:23:11 methomas noship $*/

-- Procedure
--   get_item_number
-- Description
--   find the item number using the input p_organization_id and
--   p_inventory_item_id
-- Output Parameters
--   x_item_number   item number or null if error occurred
PROCEDURE get_item_number
  (  p_organization_id   IN  NUMBER
   , p_inventory_item_id IN  NUMBER
   , x_item_number       OUT NOCOPY VARCHAR2
   ) IS
      l_val 	     BOOLEAN;
      l_nseg  	     NUMBER;
      l_seglist      fnd_flex_key_api.segment_list;
      l_segs1  	     fnd_flex_ext.segmentarray;
      l_segs2  	     fnd_flex_ext.segmentarray;
      l_fftype	     fnd_flex_key_api.flexfield_type;
      l_ffstru	     fnd_flex_key_api.structure_type;
      l_segment_type fnd_flex_key_api.segment_type;
      l_item_number  VARCHAR2(32000);
      l_delim        VARCHAR2(1);
      l_index        NUMBER;
BEGIN
   -- find flex field type
   l_fftype := fnd_flex_key_api.find_flexfield('INV', 'MSTK');
   -- find flex structure type
   l_ffstru := fnd_flex_key_api.find_structure(l_fftype, 101);
   -- find segment list for the key flex field
   fnd_flex_key_api.get_segments(l_fftype, l_ffstru, TRUE, l_nseg, l_seglist);
   -- get the corresponding clolumn for all segments
   FOR l_loop IN 1..l_nseg LOOP
      l_segment_type := fnd_flex_key_api.find_segment(l_fftype, l_ffstru, l_seglist(l_loop));
      l_segs2(l_loop) := l_segment_type.column_name;
   END LOOP;

   -- get all segments from the item table
   SELECT
     segment1, segment2, segment3, segment4, segment5,
     segment6, segment7, segment8, segment9, segment10,
     segment11, segment12, segment13, segment14, segment15,
     segment16, segment17, segment18, segment19, segment20
   INTO
     l_segs1(1), l_segs1(2), l_segs1(3), l_segs1(4), l_segs1(5),
     l_segs1(6), l_segs1(7), l_segs1(8), l_segs1(9), l_segs1(10),
     l_segs1(11), l_segs1(12), l_segs1(13), l_segs1(14), l_segs1(15),
     l_segs1(16), l_segs1(17), l_segs1(18), l_segs1(19), l_segs1(20)
   FROM mtl_system_items
   WHERE organization_id = p_organization_id
     AND inventory_item_id = p_inventory_item_id;

   -- get delimiter for segment concatenation
   l_delim := fnd_flex_ext.get_delimiter('INV', 'MSTK', 101);

   -- concatenate segments based on the order defined by the flex
   -- field structure
   FOR l_loop IN 1..l_nseg LOOP
      l_index := To_number(Substr(l_segs2 (l_loop), 8,1));
      IF l_loop = 1 THEN
	 l_item_number := l_segs1(l_index);
       ELSE
	 l_item_number := l_item_number || l_delim || l_segs1(l_index);
      END IF;
   END LOOP;

   x_item_number := l_item_number;

EXCEPTION
   WHEN OTHERS THEN
      x_item_number := NULL;

END get_item_number;

-- Procedure
--   get_locator
-- Description
--   find the locator using the input p_organization_id and
--   p_locator_id
-- Output Parameters
--   x_locator   locator or null if error occurred
PROCEDURE get_locator
  (  p_organization_id IN  NUMBER
   , p_locator_id      IN  NUMBER
   , x_locator         OUT NOCOPY VARCHAR2
   ) IS
      l_nseg           NUMBER;
      l_seglist        fnd_flex_key_api.segment_list;
      l_segs1  	       fnd_flex_ext.segmentarray;
      l_segs2  	       fnd_flex_ext.segmentarray;
      l_fftype	       fnd_flex_key_api.flexfield_type;
      l_ffstru	       fnd_flex_key_api.structure_type;
      l_segment_type   fnd_flex_key_api.segment_type;
      l_locator        VARCHAR2(32000);
      l_structure_list fnd_flex_key_api.structure_list;
      l_nstru          NUMBER;
      l_index          NUMBER;
      l_delim          VARCHAR2(1);
BEGIN
   -- find flex field type
   l_fftype := fnd_flex_key_api.find_flexfield('INV', 'MTLL');

   -- find flex structure type
   l_ffstru := fnd_flex_key_api.find_structure(l_fftype, 101);

   -- find segment list for the key flex field
   fnd_flex_key_api.get_segments(l_fftype, l_ffstru, TRUE, l_nseg, l_seglist);

   -- get the corresponding clolumn for all segments
   FOR l_loop IN 1..l_nseg LOOP
      l_segment_type := fnd_flex_key_api.find_segment(l_fftype, l_ffstru, l_seglist(l_loop));
      l_segs2(l_loop) := l_segment_type.column_name;
   END LOOP;

   -- get all segments from the item table
   SELECT
     segment1, segment2, segment3, segment4, segment5,
     segment6, segment7, segment8, segment9, segment10,
     segment11, segment12, segment13, segment14, segment15,
     segment16, segment17, segment18, segment19, segment20
   INTO
     l_segs1(1), l_segs1(2), l_segs1(3), l_segs1(4), l_segs1(5),
     l_segs1(6), l_segs1(7), l_segs1(8), l_segs1(9), l_segs1(10),
     l_segs1(11), l_segs1(12), l_segs1(13), l_segs1(14), l_segs1(15),
     l_segs1(16), l_segs1(17), l_segs1(18), l_segs1(19), l_segs1(20)
   FROM mtl_item_locations
   WHERE organization_id = p_organization_id
     AND inventory_location_id = p_locator_id;

   -- get delimiter for segment concatenation
   l_delim := fnd_flex_ext.get_delimiter('INV', 'MTLL', 101);

   -- concatenate segments based on the order defined by the flex
   -- field structure
   FOR l_loop IN 1..l_nseg LOOP
      l_index := To_number(Substr(l_segs2 (l_loop), 8,1));
      IF l_loop = 1 THEN
	 l_locator := l_segs1(l_index);
       ELSE
	 l_locator := l_locator || l_delim || l_segs1(l_index);
      END IF;
   END LOOP;

   x_locator := l_locator;

EXCEPTION
   WHEN OTHERS THEN
      x_locator := NULL;

END get_locator;

-- Procedure
--   handle_broken_reservation
-- Description
--   Start the work flow process to handle broken reservation
-- Output Parameters
--   x_return_status    'T' if succeeded, 'F' if failed
PROCEDURE handle_broken_reservation
  (
     p_item_type                     IN  VARCHAR2 DEFAULT 'INVRSVWF'
   , p_item_key                      IN  VARCHAR2
   , p_reservation_id                IN  NUMBER
   , p_organization_id               IN  NUMBER
   , p_organization_code             IN  VARCHAR2
   , p_inventory_item_id             IN  NUMBER
   , p_inventory_item_number         IN  VARCHAR2
   , p_revision                      IN  VARCHAR2
   , p_lot_number		     IN  VARCHAR2
   , p_subinventory_code	     IN  VARCHAR2
   , p_locator_id		     IN  NUMBER
   , p_locator                       IN  VARCHAR2
   , p_demand_source_type_id	     IN  NUMBER
   , p_demand_source_type            IN  VARCHAR2
   , p_demand_source_header_id	     IN  NUMBER
   , p_demand_source_line_id	     IN  NUMBER
   , p_demand_source_name            IN  VARCHAR2
   , p_supply_source_type_id	     IN  NUMBER
   , p_supply_source_type            IN  VARCHAR2
   , p_supply_source_header_id	     IN  NUMBER
   , p_supply_source_line_id	     IN  NUMBER
   , p_supply_source_name            IN  VARCHAR2
   , p_supply_source_line_detail     IN  NUMBER
   , p_primary_uom_code              IN  VARCHAR2
   , p_primary_reservation_quantity  IN  NUMBER
   , p_from_user_name                IN  VARCHAR2
   , p_to_notify_role                IN  VARCHAR2
  ) IS
BEGIN

   wf_engine.createprocess
     (
        itemtype => p_item_type
      , itemkey  => p_item_key
      );

   wf_engine.setitemowner
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , owner    => 'OPERATIONS'
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'FROM_USER_NAME'
     , avalue   => p_from_user_name
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'RESERVATION_ID'
     , avalue   => p_reservation_id
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'ORGANIZATION_ID'
     , avalue   => p_organization_id
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'ORGANIZATION_CODE'
     , avalue   => p_organization_code
     );

 wf_engine.setitemattrnumber
   (
      itemtype => p_item_type
    , itemkey  => p_item_key
    , aname    => 'INVENTORY_ITEM_ID'
    , avalue   => p_inventory_item_id
    );

 wf_engine.setitemattrtext
   (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'ITEM_NUMBER'
     , avalue   => p_inventory_item_number
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'REVISION'
     , avalue   => p_revision
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'LOT_NUMBER'
     , avalue   => p_lot_number
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'SUBINVENTORY_CODE'
     , avalue   => p_subinventory_code
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
      , itemkey  => p_item_key
      , aname    => 'LOCATOR_ID'
      , avalue   => p_locator_id
      );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'LOCATOR'
     , avalue   => p_locator
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'DEMAND_SOURCE_TYPE'
     , avalue   => To_char(p_demand_source_type_id)
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'DEMAND_SOURCE_HEADER_ID'
     , avalue   => p_demand_source_header_id
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'DEMAND_SOURCE_LINE_ID'
     , avalue   => p_demand_source_line_id
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'DEMAND_SOURCE_NAME'
     , avalue   => p_demand_source_name
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'SUPPLY_SOURCE_TYPE'
     , avalue   => To_char(p_supply_source_type_id)
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'SUPPLY_SOURCE_HEADER_ID'
     , avalue   => p_supply_source_header_id
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'SUPPLY_SOURCE_LINE_ID'
     , avalue   => p_supply_source_line_id
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'SUPPLY_SOURCE_LINE_DETAIL'
     , avalue   => p_supply_source_line_detail
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'SUPPLY_SOURCE_NAME'
     , avalue   => p_supply_source_name
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'PRIMARY_UOM_CODE'
     , avalue   => p_primary_uom_code
     );

  wf_engine.setitemattrnumber
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'PRIMARY_RESERVATION_QUANTITY'
     , avalue   => p_primary_reservation_quantity
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'FROM_USER_NAME'
     , avalue   => p_from_user_name
     );

  wf_engine.setitemattrtext
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     , aname    => 'TO_NOTIFY_ROLE'
     , avalue   => p_to_notify_role
     );

  wf_engine.startprocess
    (
       itemtype => p_item_type
     , itemkey  => p_item_key
     );

EXCEPTION
   WHEN OTHERS THEN
	wf_core.context(
			'INV_RESERVATION_WORKFLOW'
			, 'HANDLE_BROKEN_RESERVATION'
			, p_item_type
			, p_item_key
			);
	RAISE;

END handle_broken_reservation;

-- Procedure
--   handle_broken_reservation
-- Description
--   Start the work flow process to handle broken reservation
-- Output Parameters
--   x_return_status    'T' if succeeded, 'F' if failed
PROCEDURE handle_broken_reservation
  (
     p_item_type                     IN  VARCHAR2 DEFAULT 'INVRSVWF'
   , p_item_key                      IN  VARCHAR2
   , p_reservation_id                IN  NUMBER
   , p_from_user_name                IN  VARCHAR2
   , p_to_notify_role                IN  VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   ) IS
      l_organization_code             VARCHAR2(3);
      l_organization_id               NUMBER;
      l_inventory_item_id             NUMBER;
      l_inventory_item_number         VARCHAR2(240);
      l_revision                      VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot_number		      VARCHAR2(80);
      l_subinventory_code	      VARCHAR2(10);
      l_locator_id		      NUMBER;
      l_locator                       VARCHAR2(240);
      l_demand_source_type_id	      NUMBER;
      l_demand_source_type            VARCHAR2(30);
      l_demand_source_header_id	      NUMBER;
      l_demand_source_line_id	      NUMBER;
      l_demand_source_name            VARCHAR2(30);
      l_supply_source_type_id	      NUMBER;
      l_supply_source_type            VARCHAR2(30);
      l_supply_source_header_id	      NUMBER;
      l_supply_source_line_id	      NUMBER;
      l_supply_source_name            VARCHAR2(30);
      l_supply_source_line_detail     NUMBER;
      l_primary_uom_code              VARCHAR2(3);
      l_primary_reservation_quantity  NUMBER;
      l_requestor_user_name           VARCHAR2(100);
      l_user_to_notify                VARCHAR2(100);
BEGIN
   IF p_reservation_id IS NULL THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   SELECT
       organization_id
     , inventory_item_id
     , revision
     , lot_number
     , subinventory_code
     , locator_id
     , demand_source_type_id
     , demand_source_header_id
     , demand_source_line_id
     , demand_source_name
     , supply_source_type_id
     , supply_source_header_id
     , supply_source_line_id
     , supply_source_name
     , supply_source_line_detail
     , primary_uom_code
     , primary_reservation_quantity
     INTO
       l_organization_id
     , l_inventory_item_id
     , l_revision
     , l_lot_number
     , l_subinventory_code
     , l_locator_id
     , l_demand_source_type_id
     , l_demand_source_header_id
     , l_demand_source_line_id
     , l_demand_source_name
     , l_supply_source_type_id
     , l_supply_source_header_id
     , l_supply_source_line_id
     , l_supply_source_name
     , l_supply_source_line_detail
     , l_primary_uom_code
     , l_primary_reservation_quantity
     FROM mtl_reservations
     WHERE reservation_id = p_reservation_id;

   SELECT organization_code
     INTO l_organization_code
     FROM mtl_parameters
     WHERE organization_id = l_organization_id;

   -- find out item number here
   get_item_number(l_organization_id
		   , l_inventory_item_id
		   , l_inventory_item_number);
   IF l_inventory_item_number IS NULL THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   -- find out locator
   get_locator(l_organization_id
	       , l_locator_id
	       , l_locator);
   IF l_locator IS NULL THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   SELECT transaction_source_type_name INTO l_demand_source_type
     FROM mtl_txn_source_types
     WHERE transaction_source_type_id = l_demand_source_type_id;

   SELECT transaction_source_type_name INTO l_supply_source_type
     FROM mtl_txn_source_types
     WHERE transaction_source_type_id = l_supply_source_type_id;

   handle_broken_reservation
     (
        p_item_type                     => 'INVRSVWF'
      , p_item_key                      => p_item_key
      , p_reservation_id                => p_reservation_id
      , p_organization_id               => l_organization_id
      , p_organization_code         	=> l_organization_code
      , p_inventory_item_id         	=> l_inventory_item_id
      , p_inventory_item_number         => l_inventory_item_number
      , p_revision                  	=> l_revision
      , p_lot_number		    	=> l_lot_number
      , p_subinventory_code	        => l_subinventory_code
      , p_locator_id		    	=> l_locator_id
      , p_locator                   	=> l_locator
      , p_demand_source_type_id	    	=> l_demand_source_type_id
      , p_demand_source_type        	=> l_demand_source_type
      , p_demand_source_header_id   	=> l_demand_source_header_id
      , p_demand_source_line_id	    	=> l_demand_source_line_id
      , p_demand_source_name        	=> l_demand_source_name
      , p_supply_source_type_id	    	=> l_supply_source_type_id
      , p_supply_source_type            => l_supply_source_type
      , p_supply_source_header_id   	=> l_supply_source_header_id
      , p_supply_source_line_id	      	=> l_supply_source_line_id
      , p_supply_source_name            => l_supply_source_name
      , p_supply_source_line_detail     => l_supply_source_line_detail
      , p_primary_uom_code              => l_primary_uom_code
      , p_primary_reservation_quantity  => l_primary_reservation_quantity
      , p_from_user_name                => p_from_user_name
      , p_to_notify_role                => p_to_notify_role
     );

EXCEPTION
   WHEN OTHERS THEN
	wf_core.context(
			'INV_RESERVATION_WORKFLOW'
			, 'HANDLE_BROKEN_RESERVATION'
			, p_item_type
			, p_item_key
			);
	RAISE;
END handle_broken_reservation;

PROCEDURE selector
  ( itemtype IN  VARCHAR2,
    itemkey  IN  VARCHAR2,
    actid    IN  NUMBER,
    command  IN  VARCHAR2,
    result   OUT NOCOPY VARCHAR2
    ) IS
BEGIN
      If ( command = 'RUN' ) then
         result := 'HANDLE_BROKEN_RESERVATION';
         return;
      end if;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context(
		        'INV_RESERVATION_WORKFLOW'
		      , 'SELECTOR'
		      , itemtype
		      , itemkey
		      , To_char(actid)
		      , command
		      );
      RAISE fnd_api.g_exc_error;
END selector;

END inv_reservation_workflow;

/
