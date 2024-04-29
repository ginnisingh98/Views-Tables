--------------------------------------------------------
--  DDL for Package Body INV_ATTACHMENTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ATTACHMENTS_UTILS" AS
/* $Header: INVATCHB.pls 120.1.12010000.2 2009/05/12 09:37:21 asugandh ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_ATTACHMENTS_UTILS';

PROCEDURE print_debug(p_err_msg VARCHAR2,
                      p_level 	NUMBER default 4)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg 	=> p_err_msg,
      p_module 		=> 'INV_ATTACHMENTS_UTILS',
      p_level 		=> p_level);
   END IF;


   /*   dbms_output.put_line(p_err_msg); */
END print_debug;

/*
** -------------------------------------------------------------------------
** Procedure:   get_item_and_catgy_attachments
** Description:
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**	x_attachments_number
**		number of category and item attachments for given item
** 	x_concat_attachment
** 		concatenated string of attachments for given item
** Input:
**	p_inventory_item_id
**		item whose attachment is required
**	p_organization_id
**		organization of item whose attachment is required
**  	p_document_category
**		document category of attached document. this
**		maps to a Mobile Applications functionality
**		1 - 'To Mobile Receiver'
**		2 - 'To Mobile Putaway'
** 		3 - 'To Mobile Picker'
**      p_transaction_temp id
**              unique identifier of the transaction and is null by default.
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure get_item_and_catgy_attachments(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_attachments_number          OUT NOCOPY NUMBER
, x_concat_attachment           OUT NOCOPY VARCHAR2
, p_inventory_item_id           IN         NUMBER
, p_organization_id             IN         NUMBER
, p_document_category           IN         NUMBER
, p_transaction_temp_id         IN         NUMBER default NULL)
is

 l_concat_attachment		varchar2(2000);
 l_short_text        		varchar2(2000);
 l_long_text        		varchar2(2000);
 l_attachments_number           number := 0;
 l_category_id           	number;
 l_trx_source_line_id           number;
/*Fixed for bug#8347410
 When query fnd_document_categories_vl use of user_name should not done since it is translated value. Instead of column 'NAME' should be used which will not be translated and
unique with language_code
*/
l_To_Mobile_Receiver CONSTANT VARCHAR2(30) := 'CUSTOM1323';
l_To_Mobile_Putaway  CONSTANT VARCHAR2(30) := 'CUSTOM1324';
l_To_Mobile_Picker   CONSTANT VARCHAR2(30) := 'CUSTOM1325';

 /* Category - Short Text */
 cursor category_st_cursor(
    k_organization_id    NUMBER
  , k_inventory_item_id  NUMBER
  , k_document_category  NUMBER)
 is
 select f.short_text
 from fnd_attached_documents     a,
      fnd_documents              b,
      fnd_documents_vl           c,
      fnd_document_categories_vl d,
      fnd_documents_short_text   f
 where a.ENTITY_NAME             = 'MTL_CATEGORIES'
 and   a.PK1_VALUE               in (select distinct e.category_id
      				     from   mtl_item_categories_v e
				     where  e.organization_id   = k_organization_id
				     and    e.inventory_item_id = k_inventory_item_id)
 and   a.DOCUMENT_ID             = b.document_id
 and   b.datatype_id             = 1 -- short text
 and   b.category_id             = d.category_id
/*Fixed for bug#8347410
  When query fnd_document_categories_vl use of user_name should not
  done since it is translated value. Instead of column 'NAME'
  should be used which will not be translated and
  unique with language_code
*/
 and   d.NAME               = decode(k_document_category,
                                            1,l_To_Mobile_Receiver,
                                            2,l_To_Mobile_Putaway,
                                            3,l_To_Mobile_Picker)
 --and   d.SOURCE_LANG             = 'US'
 and   b.document_id             = c.document_id
 and   f.media_id                = c.media_id;

 /* Category */
 cursor category_cursor(
    k_organization_id    NUMBER
  , k_inventory_item_id  NUMBER)
 is
 select distinct category_id
 from mtl_item_categories_v
 where organization_id   = k_organization_id
 and   inventory_item_id = k_inventory_item_id;

 /* Category - Long Text */
 cursor category_lt_cursor(
    k_document_category  NUMBER
  , k_category_id        NUMBER)
 is
 select f.long_text
 from fnd_attached_documents    a,
      fnd_documents             b,
     fnd_documents_vl           c,
     fnd_document_categories_vl d,
     fnd_documents_long_text    f
 where a.ENTITY_NAME             = 'MTL_CATEGORIES'
 and   a.PK1_VALUE               = k_category_id
 and   a.DOCUMENT_ID             = b.document_id
 and   b.datatype_id             = 2 -- long text
 and   b.category_id             = d.category_id
/*Fixed for bug#8347410
  When query fnd_document_categories_vl use of user_name should not
  done since it is translated value. Instead of column 'NAME'
  should be used which will not be translated and
  unique with language_code
*/

 and   d.NAME               = decode(k_document_category,
                                            1,l_To_Mobile_Receiver,
                                            2,l_To_Mobile_Putaway,
                                            3,l_To_Mobile_Picker)
 --and   d.SOURCE_LANG             = 'US'
 and   b.document_id             = c.document_id
 and   f.media_id                = c.media_id;

 /* Item Attachment - Short Text */
 cursor item_st_cursor(
    k_organization_id    NUMBER
  , k_inventory_item_id  NUMBER
  , k_document_category  NUMBER)
 is
 select f.short_text
 from fnd_attached_documents     a,
      fnd_documents              b,
      fnd_documents_vl           c,
      fnd_document_categories_vl d,
      fnd_documents_short_text   f
 where a.ENTITY_NAME             = 'MTL_SYSTEM_ITEMS'
 and   a.PK1_VALUE               = k_organization_id
 and   a.PK2_VALUE               = k_inventory_item_id
 and   a.DOCUMENT_ID             = b.document_id
 and   b.datatype_id             = 1 -- short text
 and   b.category_id             = d.category_id
/*Fixed for bug#8347410
  When query fnd_document_categories_vl use of user_name should not
  done since it is translated value. Instead of column 'NAME'
  should be used which will not be translated and
  unique with language_code
*/
 and   d.NAME               = decode(p_document_category,
                                          1,l_To_Mobile_Receiver,
                                          2,l_To_Mobile_Putaway,
                                          3,l_To_Mobile_Picker)
 --and   d.SOURCE_LANG             = 'US'
 and   b.document_id             = c.document_id
 and   f.media_id                = c.media_id;



 /* Item Attachment - Long Text */
 cursor item_lt_cursor(
    k_organization_id    NUMBER
  , k_inventory_item_id  NUMBER
  , k_document_category  NUMBER)
 is
 select f.long_text
 from fnd_attached_documents     a,
      fnd_documents              b,
      fnd_documents_vl           c,
      fnd_document_categories_vl d,
      fnd_documents_long_text    f
 where a.ENTITY_NAME             = 'MTL_SYSTEM_ITEMS'
 and   a.PK1_VALUE               = k_organization_id
 and   a.PK2_VALUE               = k_inventory_item_id
 and   a.DOCUMENT_ID             = b.document_id
 and   b.datatype_id             = 2 -- long text
 and   b.category_id             = d.category_id
/*Fixed for bug#8347410
  When query fnd_document_categories_vl use of user_name should not
  done since it is translated value. Instead of column 'NAME'
  should be used which will not be translated and
  unique with language_code
*/
 and   d.NAME               = decode(p_document_category,
                                          1,l_To_Mobile_Receiver,
                                          2,l_To_Mobile_Putaway,
                                          3,l_To_Mobile_Picker)
 --and   d.SOURCE_LANG             = 'US'
 and   b.document_id             = c.document_id
 and   f.media_id                = c.media_id;


/* Transaction Source Line Id cursor */

 cursor trx_source_line_cursor(k_transaction_temp_id  NUMBER)
 is
 select distinct trx_source_line_id
 from   mtl_material_transactions_temp
 where  transaction_source_type_id in (2,8,12)
 and    ( nvl(parent_transaction_temp_id,0) = k_transaction_temp_id
        or
          (transaction_temp_id = k_transaction_temp_id
           and
           not exists ( select 1
                        from   mtl_material_transactions_temp
                        where
                          nvl(parent_transaction_temp_id,0) = k_transaction_temp_id
                      )
          )
        );

/* Sales Order Line Short Text cursor */
cursor sales_order_line_st_cursor(
    k_trx_source_line_id    NUMBER )
 is
select f.short_text
from fnd_attached_documents 	a,
     fnd_documents          	b,
     fnd_documents_vl       	c,
     fnd_document_categories_vl	d,
     fnd_documents_short_text   f
where a.ENTITY_NAME 		= 'OE_ORDER_LINES'
and   a.PK1_VALUE   		= k_trx_source_line_id
and   a.DOCUMENT_ID 		= b.document_id
and   b.datatype_id 		= 1 -- short text
and   b.category_id 		= d.category_id
/*Fixed for bug#8347410
  When query fnd_document_categories_vl use of user_name should not
  done since it is translated value. Instead of column 'NAME'
  should be used which will not be translated and
  unique with language_code
*/
and   d.NAME           = l_To_Mobile_Picker
--and   d.SOURCE_LANG         = 'US'
and   b.document_id 		= c.document_id
and   f.media_id 	     	= c.media_id;

/* Sales Order Line Long Text cursor */

cursor sales_order_line_lt_cursor(
   k_trx_source_line_id  NUMBER)
 is
select f.long_text
from fnd_attached_documents     a,
     fnd_documents              b,
     fnd_documents_vl           c,
     fnd_document_categories_vl d,
     fnd_documents_long_text   f
where a.ENTITY_NAME             = 'OE_ORDER_LINES'
and   a.PK1_VALUE               = k_trx_source_line_id
and   a.DOCUMENT_ID             = b.document_id
and   b.datatype_id             = 2 -- long text
and   b.category_id             = d.category_id
/*Fixed for bug#8347410
  When query fnd_document_categories_vl use of user_name should not
  done since it is translated value. Instead of column 'NAME'
  should be used which will not be translated and
  unique with language_code
*/
and   d.NAME               = l_To_Mobile_Picker
--and   d.SOURCE_LANG             = 'US'
and   b.document_id             = c.document_id
and   f.media_id                = c.media_id;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
  	x_return_status := fnd_api.g_ret_sts_success;

	IF (l_debug = 1) THEN
   	print_debug('Item ID : ' || p_inventory_item_id, 1);
   	print_debug('Org ID : ' || to_char(p_organization_id), 1);
   	print_debug('Document Category: ' || to_char(p_document_category), 1);
	END IF;

  	-- Open Category Attachments Short Text cursor
        open category_st_cursor(
          p_organization_id
        , p_inventory_item_id
        , p_document_category);

	IF (l_debug = 1) THEN
   	print_debug('category_st_cursor open', 1);
	END IF;

	while(1 > 0)
        loop
                fetch category_st_cursor into
                  l_short_text;

                if category_st_cursor%notfound then
			IF (l_debug = 1) THEN
   			print_debug('Count attach: ' || to_char(l_attachments_number), 1);
			END IF;
                        exit;
                end if;

 		l_attachments_number := l_attachments_number + 1;

                l_concat_attachment := l_concat_attachment || l_short_text;

		IF (l_debug = 1) THEN
   		print_debug('Count attach: ' || to_char(l_attachments_number), 1 );
   		print_debug('Text : ' || l_short_text, 1);
   		print_debug('Total Text : ' || l_concat_attachment, 1);
		END IF;
        end loop;

        /*
	** Not very elegant, BUT....
	** To get unique category_ids for an item,
        ** Adding category to category_lt_cursor like category_st_cursor
	** doesn't work. It gives invalid operation of long datatype
	** Hence adopting this method where we will have 2 cursors -
	** category cursor and category_lt_cursor
	*/

  	-- Open Category cursor
        open category_cursor(
          p_organization_id
        , p_inventory_item_id);

	IF (l_debug = 1) THEN
   	print_debug('category_cursor open', 1);
	END IF;

	while(1 > 0)
        loop
                fetch category_cursor into
                  l_category_id;

                if category_cursor%notfound then
			IF (l_debug = 1) THEN
   			print_debug('Count attach: ' || to_char(l_attachments_number), 1);
			END IF;
                        exit;
                end if;

  		-- Open Category Attachments Long Text cursor
        	open category_lt_cursor(
        	  p_document_category
        	, l_category_id);

		while(1 > 0)
        	loop
                	fetch category_lt_cursor into
                  		l_long_text;

                	if category_lt_cursor%notfound then
				IF (l_debug = 1) THEN
   				print_debug('Count attach: ' || to_char(l_attachments_number), 1);
				END IF;
                        	exit;
                	end if;

 			l_attachments_number := l_attachments_number + 1;

                	l_concat_attachment := l_concat_attachment || l_long_text;

                 	IF (l_debug = 1) THEN
                    	print_debug('Count attach: ' || to_char(l_attachments_number), 1);
                    	print_debug('Text : ' || l_long_text, 1);
                   	print_debug('Total Text : ' || l_concat_attachment, 1);
                 	END IF;
        	end loop;

      		IF (category_lt_cursor%isopen) THEN
        		close category_lt_cursor;
      		END IF;
        end loop;

  	-- Open Item Attachments Short Text cursor
        open item_st_cursor(
          p_organization_id
        , p_inventory_item_id
        , p_document_category);

	IF (l_debug = 1) THEN
   	print_debug('item_st_cursor open', 1);
	END IF;

	while(1 > 0)
        loop
                fetch item_st_cursor into
                  l_short_text;

                if item_st_cursor%notfound then
			IF (l_debug = 1) THEN
   			print_debug('Count attach: ' || to_char(l_attachments_number), 1);
			END IF;
                        exit;
                end if;

 		l_attachments_number := l_attachments_number + 1;

                l_concat_attachment := l_concat_attachment || l_short_text;

                IF (l_debug = 1) THEN
                   print_debug('Count attach: ' || to_char(l_attachments_number), 1);
                   print_debug('Text : ' || l_short_text, 1);
                   print_debug('Total Text : ' || l_concat_attachment, 1);
                END IF;

        end loop;

  	-- Open Item Attachments Long Text cursor
        open item_lt_cursor(
          p_organization_id
        , p_inventory_item_id
        , p_document_category);

	IF (l_debug = 1) THEN
   	print_debug('item_lt_cursor open', 1);
	END IF;

	while(1 > 0)
        loop
                fetch item_lt_cursor into
                  l_long_text;

                if item_lt_cursor%notfound then
			IF (l_debug = 1) THEN
   			print_debug('Count attach: ' || to_char(l_attachments_number), 1);
			END IF;
                        exit;
                end if;

 		l_attachments_number := l_attachments_number + 1;

                l_concat_attachment := l_concat_attachment || l_long_text;
                IF (l_debug = 1) THEN
                   print_debug('Count attach: ' || to_char(l_attachments_number), 1);
                   print_debug('Text : ' || l_long_text, 1);
                   print_debug('Total Text : ' || l_concat_attachment, 1);
                END IF;

        end loop;


    -- sales order Line Attachment begins

    if ( p_transaction_temp_id is not null and p_transaction_temp_id > 0) then

      -- Open Transaction source line id cursor
          open trx_source_line_cursor(p_transaction_temp_id);

	  IF (l_debug = 1) THEN
   	  print_debug('Transaction source line id cursor open', 1);
	  END IF;

	while(1 > 0)
        loop
                fetch trx_source_line_cursor into l_trx_source_line_id;

                if trx_source_line_cursor%notfound then
                  IF (l_debug = 1) THEN
                     print_debug('Count attach: ' || to_char(l_attachments_number), 1);
                  END IF;
                  exit;
                 end if;

  		-- Open Sales Order Line Short Text cursor
        	open sales_order_line_st_cursor(l_trx_source_line_id);

		while(1 > 0)
        	loop
                	fetch sales_order_line_st_cursor into l_short_text;

                	if sales_order_line_st_cursor%notfound then
                           IF (l_debug = 1) THEN
                              print_debug('Count attach: ' ||to_char(l_attachments_number), 1);
                           END IF;
                           exit;
                	end if;

 			l_attachments_number := l_attachments_number + 1;

                	l_concat_attachment := l_concat_attachment || l_short_text;

                 	IF (l_debug = 1) THEN
                    	print_debug('Count attach: ' || to_char(l_attachments_number), 1);
                    	print_debug('Text : ' || l_short_text, 1);
                   	print_debug('Total Text : ' || l_concat_attachment, 1);
                 	END IF;
        	end loop;

      		IF (sales_order_line_st_cursor%isopen) THEN
        		close sales_order_line_st_cursor;
      		END IF;

  		-- Open Sales Order Line Long Text cursor
        	open sales_order_line_lt_cursor(
        	  l_trx_source_line_id);

		while(1 > 0)
        	loop
                	fetch sales_order_line_lt_cursor into  l_long_text;

                	if sales_order_line_lt_cursor%notfound then
		           IF (l_debug = 1) THEN
   		           print_debug('Count attach: ' || to_char(l_attachments_number),1);
		           END IF;
                           exit;
                	end if;

 			l_attachments_number := l_attachments_number + 1;

                	l_concat_attachment := l_concat_attachment || l_long_text;
                        IF (l_debug = 1) THEN
                           print_debug('Count attach: ' || to_char(l_attachments_number), 1);
                    	print_debug('Text : ' || l_long_text, 1);
                   	print_debug('Total Text : ' || l_concat_attachment, 1);
                        END IF;
        	end loop;

      		IF (sales_order_line_lt_cursor%isopen) THEN
        		close sales_order_line_lt_cursor;
      		END IF;

        end loop;

    end if;

    if (l_attachments_number > 0) then
		x_concat_attachment  := l_concat_attachment;
                x_attachments_number := l_attachments_number;
	else
		x_concat_attachment  := NULL;
                x_attachments_number := 0;
	end if;

        IF (l_debug = 1) THEN
           print_debug('Count attach: ' || to_char(l_attachments_number), 1);
           print_debug('Total Text : ' || l_concat_attachment, 1);
        END IF;

       	IF (category_st_cursor%isopen) THEN
        	CLOSE category_st_cursor;
      	END IF;

      	IF (category_cursor%isopen) THEN
        	close category_cursor;
      	END IF;

      	IF (category_lt_cursor%isopen) THEN
        	CLOSE category_lt_cursor;
      	END IF;

      	IF (item_st_cursor%isopen) THEN
        	CLOSE item_st_cursor;
      	END IF;

        IF (trx_source_line_cursor%isopen) THEN
      		close trx_source_line_cursor;
      	END IF;

        IF (sales_order_line_st_cursor%isopen) THEN
      		close sales_order_line_st_cursor;
        END IF;

      	IF (sales_order_line_lt_cursor%isopen) THEN
      		close sales_order_line_lt_cursor;
      	END IF;


exception
   when fnd_api.g_exc_error THEN
      x_return_status      := fnd_api.g_ret_sts_error;
      x_concat_attachment  := NULL;
      x_attachments_number := 0;

      IF (l_debug = 1) THEN
         print_debug('g_ret_sts_error', 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (category_st_cursor%isopen) THEN
        CLOSE category_st_cursor;
      END IF;

      IF (category_cursor%isopen) THEN
    	close category_cursor;
      END IF;

      IF (category_lt_cursor%isopen) THEN
        CLOSE category_lt_cursor;
      END IF;

      IF (item_st_cursor%isopen) THEN
        CLOSE item_st_cursor;
      END IF;

      IF (item_lt_cursor%isopen) THEN
        CLOSE item_lt_cursor;
      END IF;

      IF (trx_source_line_cursor%isopen) THEN
      	close trx_source_line_cursor;
      END IF;

      IF (sales_order_line_st_cursor%isopen) THEN
        close sales_order_line_st_cursor;
      END IF;

      IF (sales_order_line_lt_cursor%isopen) THEN
        close sales_order_line_lt_cursor;
      END IF;


   when fnd_api.g_exc_unexpected_error THEN
      x_return_status      := fnd_api.g_ret_sts_unexp_error ;
      x_concat_attachment  := NULL;
      x_attachments_number := 0;

      IF (l_debug = 1) THEN
         print_debug('g_ret_sts_unexp_error', 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (category_st_cursor%isopen) THEN
        CLOSE category_st_cursor;
      END IF;

      IF (category_cursor%isopen) THEN
    	close category_cursor;
      END IF;

      IF (category_lt_cursor%isopen) THEN
        CLOSE category_lt_cursor;
      END IF;

      IF (item_st_cursor%isopen) THEN
        CLOSE item_st_cursor;
      END IF;

      IF (item_lt_cursor%isopen) THEN
        CLOSE item_lt_cursor;
      END IF;

      IF (trx_source_line_cursor%isopen) THEN
      	close trx_source_line_cursor;
      END IF;

      IF (sales_order_line_st_cursor%isopen) THEN
        close sales_order_line_st_cursor;
      END IF;

      IF (sales_order_line_lt_cursor%isopen) THEN
        close sales_order_line_lt_cursor;
      END IF;


    when others THEN

      x_return_status 	   := fnd_api.g_ret_sts_unexp_error ;
      x_concat_attachment  := NULL;
      x_attachments_number := 0;
      --
      IF (l_debug = 1) THEN
         print_debug('others', 1);
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'get_item_and_catgy_attachments'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      IF (category_st_cursor%isopen) THEN
        CLOSE category_st_cursor;
      END IF;

      IF (category_cursor%isopen) THEN
	    close category_cursor;
      END IF;

      IF (category_lt_cursor%isopen) THEN
        CLOSE category_lt_cursor;
      END IF;

      IF (item_st_cursor%isopen) THEN
        CLOSE item_st_cursor;
      END IF;

      IF (item_lt_cursor%isopen) THEN
        CLOSE item_lt_cursor;
      END IF;

      IF (trx_source_line_cursor%isopen) THEN
      	close trx_source_line_cursor;
      END IF;


      IF (sales_order_line_st_cursor%isopen) THEN
       	close sales_order_line_st_cursor;
      END IF;

      IF (sales_order_line_lt_cursor%isopen) THEN
       	close sales_order_line_lt_cursor;
      END IF;


end get_item_and_catgy_attachments;

end inv_attachments_utils;

/
