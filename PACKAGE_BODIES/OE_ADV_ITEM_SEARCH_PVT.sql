--------------------------------------------------------
--  DDL for Package Body OE_ADV_ITEM_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ADV_ITEM_SEARCH_PVT" AS
/* $Header: OEXVAISB.pls 120.1 2005/06/27 10:08:32 appldev ship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):='OE_ADV_ITEM_SEARCH_PVT';

PROCEDURE Create_Items_Selected(p_session_id IN NUMBER,
				p_header_id  IN NUMBER,
				x_ais_items_tbl OUT NOCOPY /* file.sql.39 change */ ais_item_tbl,
				x_msg_count OUT NOCOPY /* file.sql.39 change */ NUMBER,
				x_msg_data OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
  IS

      CURSOR selected_items IS
 	SELECT inventory_item_id
 	  FROM oe_selected_items
	  WHERE session_id = p_session_id;

     l_line_tbl oe_order_pub.line_tbl_type;
     l_old_line_tbl oe_order_pub.line_tbl_type;
     l_line_rec oe_order_pub.line_rec_type;

     l_control_rec oe_globals.control_rec_type;

--     l_booked_flag VARCHAR2(1) := 'N';

     l_index NUMBER := 1;
     l_return_status VARCHAR2(1);

BEGIN

   l_control_rec.controlled_operation := TRUE;
   l_control_rec.process_partial := TRUE;

   l_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;
   l_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
   l_line_rec.header_id := p_header_id;
   l_line_rec.ordered_quantity := 1;

/*   SELECT booked_flag
     INTO l_booked_flag
     FROM oe_order_headers
     WHERE header_id = p_header_id;

   IF l_booked_flag = 'Y' THEN
      l_line_rec.ordered_quantity := 1;
   END IF;*/

   -- Loop on the cursor to load

   FOR l_item IN selected_items LOOP

      l_line_rec.inventory_item_id := l_item.inventory_item_id;
      l_line_tbl(l_index) := l_line_rec;

      l_index := l_index + 1;

   END LOOP;

   -- Call Process Order API to create the lines

   oe_debug_pub.add('No of Items Selected in Advanced Search : ' || To_char(l_index - 1), 1);

   IF l_index > 1 THEN

      oe_order_pvt.lines
	( p_validation_level => fnd_api.g_valid_level_none
	  , p_control_rec      => l_control_rec
	  , p_x_line_tbl       => l_line_tbl
	  , p_x_old_line_tbl   => l_old_line_tbl
	  , x_return_status    => l_return_status );


      oe_debug_pub.add('After call to Lines Procedure : ' || l_return_status, 1 );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OE_ORDER_PVT.Process_Requests_And_notify
	( p_process_requests       => TRUE
	  , p_notify                 => TRUE
	  , x_return_status          => l_return_status
	  , p_line_tbl               => l_line_tbl
	  , p_old_line_tbl           => l_old_line_tbl);


      oe_debug_pub.add('After call to Process Request Notify : ' || l_return_status, 1 );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Now the call goes back to the pld and needs to be handled.

      l_index := l_line_tbl.first;
      oe_debug_pub.add( 'Copying Items to AIS table ' || To_char(l_index) );

      WHILE l_index IS NOT NULL LOOP
	 x_ais_items_tbl(l_index).inventory_item_id := l_line_tbl(l_index).inventory_item_id;
	 x_ais_items_tbl(l_index).return_status := l_line_tbl(l_index).return_status;
	 l_index := l_line_tbl.next(l_index);
      END LOOP;

      oe_msg_pub.count_and_get
	( p_count      => x_msg_count
	  , p_data       => x_msg_data  );

      x_return_status := l_return_status;

    ELSE -- No items have been selected.

      -- insert a row into  OE_SELECTED_ITEMS with inventory_item_id as -1 for the passed session_id
      insert_unused_session( p_session_id );

   END IF;

   oe_debug_pub.add('Leaving Create_Items_Selected  : ' || l_return_status, 1 );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      oe_msg_pub.count_and_get
	( p_count   => x_msg_count
	, p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      oe_msg_pub.count_and_get
	( p_count   => x_msg_count
        , p_data    => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)  THEN
	 oe_msg_pub.Add_Exc_Msg
	   ( G_PKG_NAME
	   , 'Create_Items_Selected' );
      END IF;
      oe_msg_pub.count_and_get
	( p_count   => x_msg_count
	, p_data    => x_msg_data);

END  create_items_selected;

PROCEDURE delete_selection ( p_session_id NUMBER ) IS

BEGIN

   DELETE FROM oe_selected_items
     WHERE session_id = p_session_id;

END delete_selection;

PROCEDURE Update_Used_Flag ( p_session_id NUMBER ) IS

BEGIN

   UPDATE oe_selected_items
     SET used_flag = 'Y'
     WHERE session_id = p_session_id;

END Update_Used_Flag;

PROCEDURE Insert_unused_session ( p_session_id NUMBER ) IS

BEGIN

   INSERT INTO  oe_selected_items
     (session_id, inventory_item_id, used_flag)
     VALUES ( p_session_id, -1, 'Y' );

END insert_unused_session;

END OE_ADV_ITEM_SEARCH_PVT;

/
