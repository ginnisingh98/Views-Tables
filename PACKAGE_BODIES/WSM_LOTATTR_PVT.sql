--------------------------------------------------------
--  DDL for Package Body WSM_LOTATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_LOTATTR_PVT" as
/* $Header: WSMVATRB.pls 120.7.12010000.2 2008/08/06 07:46:26 amayadav ship $ */

procedure lot_exists(x_err_code OUT NOCOPY NUMBER,
                     x_err_msg  OUT NOCOPY VARCHAR2,
                     p_org_id   IN       NUMBER,
                     p_lot_number IN     VARCHAR2,
                     p_inventory_item_id IN NUMBER,
                     x_lot_exists OUT NOCOPY VARCHAR2) is

    -- To check if lot already exists
BEGIN
          x_err_code:=0;
          SELECT 'Y'
            INTO x_lot_exists
            FROM mtl_lot_numbers
           WHERE organization_id = p_org_id
             AND inventory_item_id = p_inventory_item_id
             AND lot_number = p_lot_number;

EXCEPTION
           WHEN no_data_found THEN
              x_lot_exists:='N';
           WHEN OTHERS THEN
                x_err_code := SQLCODE;
                x_err_msg := 'WSMVATRB.lot_exists' || SUBSTR(SQLERRM,1,60);
END;


/*
PROCEDURE create_update_lotattr(x_err_code    OUT NOCOPY  NUMBER,
                                x_err_msg     OUT NOCOPY  varchar2,
                                p_lot_number    VARCHAR2,
                                p_inv_item_id   NUMBER,
                                p_org_id        NUMBER) IS
BEGIN
        create_update_lotattr(  x_err_code   => x_err_code,
                                x_err_msg    => x_err_msg,
                                p_lot_number => p_lot_number,
                                p_inv_item_id => p_inv_item_id,
                                p_org_id => p_org_id,
                                p_src_lot_number => NULL,
                                p_src_inv_item_id => NULL);

END create_update_lotattr; */

procedure pdebug(x_mesg varchar2) is
begin
    --dbms_output.put_line(x_mesg);
    fnd_file.put_line(fnd_file.log,x_mesg);
end;

Procedure create_update_lotattr(x_err_code       OUT NOCOPY VARCHAR2,
                                x_err_msg        OUT NOCOPY VARCHAR2,
                                p_lot_number     IN   VARCHAR2,
                                p_inv_item_id    IN   NUMBER,
                                p_org_id         IN   NUMBER,
                                p_intf_txn_id    IN   NUMBER,
                                p_intf_src_code  IN   VARCHAR2,
                                p_src_lot_number IN   VARCHAR2 DEFAULT NULL,
                                p_src_inv_item_id IN  NUMBER   DEFAULT NULL) is

l_wms_installed     BOOLEAN:=FALSE;
x_context_code      MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE:=NULL;
x_src_context_code  MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE:=NULL;
l_copy_from_src     BOOLEAN:=FALSE;
l_intf_rec_found    BOOLEAN:=FALSE;
l_inv_attr_required BOOLEAN:=FALSE;
l_wms_attr_required BOOLEAN:=FALSE;
l_call_inv_lotapi   BOOLEAN:=FALSE;

l_lot_attribute_category varchar2(30):=NULL;
l_attribute_category   varchar2(30):=NULL;
l_description          mtl_lot_numbers.description%TYPE:=NULL;
l_invattr_tbl          inv_lot_api_pub.char_tbl;
l_Cattr_tbl            inv_lot_api_pub.char_tbl;
l_Nattr_tbl            inv_lot_api_pub.number_tbl;
l_Dattr_tbl            inv_lot_api_pub.date_tbl;

l_grade_code         mtl_lot_numbers.grade_code%TYPE:=NULL;
l_origination_date   DATE:=NULL;
l_date_code          mtl_lot_numbers.date_code%TYPE:=NULL;
l_change_date        DATE:=NULL;
l_age                NUMBER:=NULL;
l_retest_date        DATE:=NULL;
l_maturity_date      DATE:=NULL;
l_item_size          NUMBER:=NULL;
l_color              mtl_lot_numbers.color%TYPE:=NULL;
l_volume             NUMBER:=NULL;
l_volume_uom         mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_place_of_origin    mtl_lot_numbers.place_of_origin%TYPE:=NULL;
l_best_by_date       DATE:=NULL;
l_length             NUMBER:=NULL;
l_length_uom         mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_recycled_content   NUMBER:=NULL;
l_thickness          NUMBER:=NULL;
l_thickness_uom      mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_width              NUMBER:=NULL;
l_width_uom          mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_vendor_id          NUMBER:=NULL;
l_vendor_name        mtl_lot_numbers.vendor_name%TYPE:=NULL;
l_territory_code     mtl_lot_numbers.territory_code%TYPE:=NULL;
l_supplier_lot_number mtl_lot_numbers.supplier_lot_number%TYPE:=NULL;
l_curl_wrinkle_fold  mtl_lot_numbers.supplier_lot_number%TYPE:=NULL;
l_status_id          number;

-- Source lot variables
l_Sinvattr_tbl inv_lot_api_pub.char_tbl;
l_SCattr_tbl   inv_lot_api_pub.char_tbl;
l_SNattr_tbl   inv_lot_api_pub.number_tbl;
l_SDattr_tbl   inv_lot_api_pub.date_tbl;

l_Sgrade_code         mtl_lot_numbers.grade_code%TYPE:=NULL;
l_Sorigination_date   DATE:=NULL;
l_Sdate_code          mtl_lot_numbers.date_code%TYPE:=NULL;
l_Schange_date        DATE:=NULL;
l_Sage                NUMBER:=NULL;
l_Sretest_date        DATE:=NULL;
l_Smaturity_date      DATE:=NULL;
l_Sitem_size          NUMBER:=NULL;
l_Scolor              mtl_lot_numbers.color%TYPE:=NULL;
l_Svolume             NUMBER:=NULL;
l_Svolume_uom         mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_Splace_of_origin    mtl_lot_numbers.place_of_origin%TYPE:=NULL;
l_Sbest_by_date       DATE:=NULL;
l_Slength             NUMBER:=NULL;
l_Slength_uom         mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_Srecycled_content   NUMBER:=NULL;
l_Sthickness          NUMBER:=NULL;
l_Sthickness_uom      mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_Swidth              NUMBER:=NULL;
l_Swidth_uom          mtl_lot_numbers.volume_uom%TYPE:=NULL;
l_Svendor_id          NUMBER:=NULL;
l_Svendor_name        mtl_lot_numbers.vendor_name%TYPE:=NULL;
l_Sterritory_code     mtl_lot_numbers.territory_code%TYPE:=NULL;
l_Ssupplier_lot_number mtl_lot_numbers.supplier_lot_number%TYPE:=NULL;
l_Scurl_wrinkle_fold  mtl_lot_numbers.supplier_lot_number%TYPE:=NULL;

x_lot_exists          VARCHAR2(1):='N';
x_src_lot_exists      VARCHAR2(1):='N';
l_mtli_txn_id         NUMBER;
x_return_status       VARCHAR2(1);
x_msg_count           NUMBER;

l_intf_temp           NUMBER;   -- added for bug 5126021.


-- Bug 5367283 Added the following variables

l_context_r                    fnd_dflex.context_r;
l_contexts_dr                  fnd_dflex.contexts_dr;
l_dflex_r                      fnd_dflex.dflex_r;
l_segments_dr                  fnd_dflex.segments_dr;
l_context                      VARCHAR2(1000);
l_global_context               BINARY_INTEGER;
wms_context_index              NUMBER;

l_temp_lot_attribute_category  varchar2(30):=NULL;

l_temp_Cattr_tbl   	inv_lot_api_pub.char_tbl;
l_temp_Nattr_tbl   	inv_lot_api_pub.number_tbl;
l_temp_Dattr_tbl   	inv_lot_api_pub.date_tbl;

l_temp_description        mtl_lot_numbers.description%type:=null;
l_temp_grade_code         mtl_lot_numbers.grade_code%type:=null;
l_temp_origination_date   date:=null;
l_temp_date_code          mtl_lot_numbers.date_code%type:=null;
l_temp_change_date        date:=null;
l_temp_age                number:=null;
l_temp_retest_date        date:=null;
l_temp_maturity_date      date:=null;
l_temp_item_size          number:=null;
l_temp_color              mtl_lot_numbers.color%type:=null;
l_temp_volume             number:=null;
l_temp_volume_uom         mtl_lot_numbers.volume_uom%type:=null;
l_temp_place_of_origin    mtl_lot_numbers.place_of_origin%type:=null;
l_temp_best_by_date       date:=null;
l_temp_length             number:=null;
l_temp_length_uom         mtl_lot_numbers.volume_uom%type:=null;
l_temp_recycled_content   number:=null;
l_temp_thickness          number:=null;
l_temp_thickness_uom      mtl_lot_numbers.volume_uom%type:=null;
l_temp_width              number:=null;
l_temp_width_uom     	  mtl_lot_numbers.volume_uom%type:=null;
l_temp_vendor_id          number:=null;
l_temp_vendor_name        mtl_lot_numbers.vendor_name%type:=null;
l_temp_territory_code     mtl_lot_numbers.territory_code%type:=null;
l_temp_supplier_lot_number mtl_lot_numbers.supplier_lot_number%type:=null;
l_temp_curl_wrinkle_fold  mtl_lot_numbers.supplier_lot_number%type:=null;

-- Bug 5367283 the above variables are added

BEGIN
    fnd_msg_pub.initialize;
    if g_debug then
       pdebug('Entering wsmvatrb.create_update_lotattr lot#= ' || p_lot_number);
       pdebug('inv itemid= ' || p_inv_item_id || ' org_id= ' || p_org_id);
    end if;
    IF (p_lot_number IS NULL OR
       p_inv_item_id IS NULL OR
       p_org_id IS NULL) THEN
        fnd_message.set_name('WSM','WSM_INVALID_FIELD');
        fnd_message.set_token('FLD_NAME', 'Lot Number');
        x_err_msg :=  fnd_message.get;
        x_err_code:= -1;
        return;
    END IF;

    --IF (p_lot_number IS NULL OR
    x_err_code:=0;
    lot_exists(x_err_code, x_err_msg,p_org_id,p_lot_number,
                        p_inv_item_id,x_lot_exists);
    if g_debug then
      pdebug('x_lot_exists=' || x_lot_exists);
    end if;
    if (x_err_code <> 0) THEN
       return;
    end if;
    IF (p_src_lot_number IS NOT NULL   AND
        p_src_inv_item_id IS NOT NULL) THEN
        lot_exists(x_err_code, x_err_msg,p_org_id,p_src_lot_number,
                        p_src_inv_item_id,x_src_lot_exists);
        if (x_err_code <> 0) THEN
           return;
        end if;
        if g_debug then
           pdebug('x_src_lot_exists=' || x_src_lot_exists);
           pdebug('p_src_inv_item_id=' ||p_src_inv_item_id);
           pdebug('p_src_lot_number=' ||p_src_lot_number);
	    end if;
    ELSE
        x_src_lot_exists:='N';
		if g_debug then    -- added for bug 5126021.
           pdebug('x_src_lot_exists=' || x_src_lot_exists);
           pdebug('x_src_lot_number=' || p_src_lot_number);
		end if;
    END IF;

	FOR cntr in 1..10 LOOP       -- added for bug 5126021:Start .
	  	l_invattr_tbl(cntr):=null;
	  	l_Cattr_tbl(cntr):=null;
	  	l_Nattr_tbl(cntr):=null;
	  	l_Dattr_tbl(cntr):=null;
    END LOOP;

	FOR cntr in 11..15 LOOP
	  	l_invattr_tbl(cntr):=null;
	  	l_Cattr_tbl(cntr):=null;
    END LOOP;

	FOR cntr in 16..20 LOOP
	  	l_Cattr_tbl(cntr):=null;
	END LOOP;

    begin
	          select 1
              into l_intf_temp
              from mtl_transaction_lots_interface mtli
              where mtli.product_transaction_id=p_intf_txn_id
              and mtli.product_code=p_intf_src_code
              and mtli.lot_number=p_lot_number;

			  l_intf_rec_found :=TRUE;

			  if g_debug then
                 pdebug('l_intf_rec_found= TRUE');
              end if;

	exception
	when NO_DATA_FOUND THEN
	          l_intf_rec_found :=FALSE;
	          if g_debug then
                  pdebug('l_intf_rec_found= FALSE');
              end if;
	end;                 -- added for bug 5126021:End.

    --IF (inv_install.adv_inv_installed(p_org_id) = TRUE) THEN
    IF (inv_install.adv_inv_installed(NULL) = TRUE) THEN
       l_wms_installed  := TRUE;
	   if g_debug then
                  pdebug('l_wms_installed = TRUE');
       end if;
       IF x_src_lot_exists='Y' THEN
          inv_lot_sel_attr.get_context_code(
                        x_context_code,
                        p_org_id,
                        p_inv_item_id,
                        'Lot Attributes');
          -- Commented for bug 5463921
          /* inv_lot_sel_attr.get_context_code(
                        x_src_context_code,
                        p_org_id,
                        p_src_inv_item_id,
                        'Lot Attributes'); */
           -- Added for bug 5463921.
           select lot_attribute_category
	       into x_src_context_code
	       from mtl_lot_numbers
	       where lot_number=p_src_lot_number
           and inventory_item_id=p_src_inv_item_id
	       and organization_id= p_org_id;

           -- IF (x_src_context_code=x_context_code  AND
           --   x_src_context_code IS NOT NULL    AND
           --   x_context_code IS NOT NULL )      THEN
           -- ST Fix for Bug 4881542
           --IF (nvl(x_src_context_code,'&&$$$') = nvl(x_context_code,'&&$$$')) THEN
           --   l_copy_from_src:=TRUE;
           --END IF;   -- added for bug 5126021.
		   If ( x_src_context_code=x_context_code or
	   		         x_context_code is null) THEN
				l_copy_from_src:=TRUE;
		   else
				l_copy_from_src:=FALSE;
		   end if;
       ELSE
	       l_copy_from_src:=TRUE;
       END IF; -- x_src_lot_exists='Y'
    END IF; -- inv_install.adv_inv_installed(NULL) = TRUE

    /* A big section  of commented out code was present here. It has been removed
       for code readability and clarity. For some reason, if you would like to know
       more about the commented out code, please refer to file version 120.4
    */

    if NOT (x_lot_exists='N' and x_src_lot_exists='N') THEN --Bug 5282172.
	   if l_copy_from_src then

	    if g_debug then
           pdebug('l_copy_from_src= TRUE ');
        end if;

		SELECT
        description  -- This is Not a named attr, right?
        ,grade_code
        ,origination_date
        ,date_code
        ,change_date
        ,age
        ,retest_date
        ,maturity_date
        ,item_size
        ,color
        ,volume
        ,volume_uom
        ,place_of_origin
        ,best_by_date
        ,length
        ,length_uom
        ,recycled_content
        ,thickness
        ,thickness_uom
        ,width
        ,width_uom
        ,vendor_id           -- are vendor_id is missing in create_inv_lot
        ,vendor_name
        ,territory_code      --MISSING in named record
        ,supplier_lot_number --MISSING in named record
        ,curl_wrinkle_fold   --MISSING in named record
        ,lot_attribute_category
        ,c_attribute1
        ,c_attribute2
        ,c_attribute3
        ,c_attribute4
        ,c_attribute5
        ,c_attribute6
        ,c_attribute7
        ,c_attribute8
        ,c_attribute9
        ,c_attribute10
        ,c_attribute11
        ,c_attribute12
        ,c_attribute13
        ,c_attribute14
        ,c_attribute15
        ,c_attribute16
        ,c_attribute17
        ,c_attribute18
        ,c_attribute19
        ,c_attribute20
        ,d_attribute1
        ,d_attribute2
        ,d_attribute3
        ,d_attribute4
        ,d_attribute5
        ,d_attribute6
        ,d_attribute7
        ,d_attribute8
        ,d_attribute9
        ,d_attribute10
        ,n_attribute1
        ,n_attribute2
        ,n_attribute3
        ,n_attribute4
        ,n_attribute5
        ,n_attribute6
        ,n_attribute7
        ,n_attribute8
        ,n_attribute9
        ,n_attribute10
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        INTO
        l_description
        ,l_grade_code
        ,l_origination_date
        ,l_date_code
        ,l_change_date
        ,l_age
        ,l_retest_date
        ,l_maturity_date
        ,l_item_size
        ,l_color
        ,l_volume
        ,l_volume_uom
        ,l_place_of_origin
        ,l_best_by_date
        ,l_length
        ,l_length_uom
        ,l_recycled_content
        ,l_thickness
        ,l_thickness_uom
        ,l_width
        ,l_width_uom
        ,l_vendor_id
        ,l_vendor_name
        ,l_territory_code
        ,l_supplier_lot_number
        ,l_curl_wrinkle_fold
        ,l_lot_attribute_category
        ,l_Cattr_tbl(1)
        ,l_Cattr_tbl(2)
        ,l_Cattr_tbl(3)
        ,l_Cattr_tbl(4)
        ,l_Cattr_tbl(5)
        ,l_Cattr_tbl(6)
        ,l_Cattr_tbl(7)
        ,l_Cattr_tbl(8)
        ,l_Cattr_tbl(9)
        ,l_Cattr_tbl(10)
        ,l_Cattr_tbl(11)
        ,l_Cattr_tbl(12)
        ,l_Cattr_tbl(13)
        ,l_Cattr_tbl(14)
        ,l_Cattr_tbl(15)
        ,l_Cattr_tbl(16)
        ,l_Cattr_tbl(17)
        ,l_Cattr_tbl(18)
        ,l_Cattr_tbl(19)
        ,l_Cattr_tbl(20)
        ,l_Dattr_tbl(1)
        ,l_Dattr_tbl(2)
        ,l_Dattr_tbl(3)
        ,l_Dattr_tbl(4)
        ,l_Dattr_tbl(5)
        ,l_Dattr_tbl(6)
        ,l_Dattr_tbl(7)
        ,l_Dattr_tbl(8)
        ,l_Dattr_tbl(9)
        ,l_Dattr_tbl(10)
        ,l_Nattr_tbl(1)
        ,l_Nattr_tbl(2)
        ,l_Nattr_tbl(3)
        ,l_Nattr_tbl(4)
        ,l_Nattr_tbl(5)
        ,l_Nattr_tbl(6)
        ,l_Nattr_tbl(7)
        ,l_Nattr_tbl(8)
        ,l_Nattr_tbl(9)
        ,l_Nattr_tbl(10)
        ,l_attribute_category
        ,l_invattr_tbl(1)
        ,l_invattr_tbl(2)
        ,l_invattr_tbl(3)
        ,l_invattr_tbl(4)
        ,l_invattr_tbl(5)
        ,l_invattr_tbl(6)
        ,l_invattr_tbl(7)
        ,l_invattr_tbl(8)
        ,l_invattr_tbl(9)
        ,l_invattr_tbl(10)
        ,l_invattr_tbl(11)
        ,l_invattr_tbl(12)
        ,l_invattr_tbl(13)
        ,l_invattr_tbl(14)
        ,l_invattr_tbl(15)
        FROM mtl_lot_numbers
        WHERE lot_number=nvl(p_src_lot_number,p_lot_number) /* modified for fixing bug 5126021 */
        AND   inventory_item_id=nvl(p_src_inv_item_id,p_inv_item_id)  /* modified for fixing bug 5126021 */
        AND   organization_id=p_org_id;

        l_call_inv_lotapi :=TRUE;

      else

	if g_debug then
          pdebug('l_copy_from_src= FALSE ');
        end if;



-- Bug 5367283 Begin adding code

        if (l_wms_installed ) then

        SELECT
         description
        ,grade_code
        ,origination_date
        ,date_code
        ,change_date
        ,age
        ,retest_date
        ,maturity_date
        ,item_size
        ,color
        ,volume
        ,volume_uom
        ,place_of_origin
        ,best_by_date
        ,length
        ,length_uom
        ,recycled_content
        ,thickness
        ,thickness_uom
        ,width
        ,width_uom
        ,vendor_id
        ,vendor_name
        ,territory_code
        ,supplier_lot_number
        ,curl_wrinkle_fold
        ,lot_attribute_category
        ,c_attribute1
        ,c_attribute2
        ,c_attribute3
        ,c_attribute4
        ,c_attribute5
        ,c_attribute6
        ,c_attribute7
        ,c_attribute8
        ,c_attribute9
        ,c_attribute10
        ,c_attribute11
        ,c_attribute12
        ,c_attribute13
        ,c_attribute14
        ,c_attribute15
        ,c_attribute16
        ,c_attribute17
        ,c_attribute18
        ,c_attribute19
        ,c_attribute20
        ,d_attribute1
        ,d_attribute2
        ,d_attribute3
        ,d_attribute4
        ,d_attribute5
        ,d_attribute6
        ,d_attribute7
        ,d_attribute8
        ,d_attribute9
        ,d_attribute10
        ,n_attribute1
        ,n_attribute2
        ,n_attribute3
        ,n_attribute4
        ,n_attribute5
        ,n_attribute6
        ,n_attribute7
        ,n_attribute8
        ,n_attribute9
        ,n_attribute10
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        INTO
         l_temp_description
        ,l_temp_grade_code
        ,l_temp_origination_date
        ,l_temp_date_code
        ,l_temp_change_date
        ,l_temp_age
        ,l_temp_retest_date
        ,l_temp_maturity_date
        ,l_temp_item_size
        ,l_temp_color
        ,l_temp_volume
        ,l_temp_volume_uom
        ,l_temp_place_of_origin
        ,l_temp_best_by_date
        ,l_temp_length
        ,l_temp_length_uom
        ,l_temp_recycled_content
        ,l_temp_thickness
        ,l_temp_thickness_uom
        ,l_temp_width
        ,l_temp_width_uom
        ,l_temp_vendor_id
        ,l_temp_vendor_name
        ,l_temp_territory_code
        ,l_temp_supplier_lot_number
        ,l_temp_curl_wrinkle_fold
        ,l_temp_lot_attribute_category
        ,l_temp_Cattr_tbl(1)
        ,l_temp_Cattr_tbl(2)
        ,l_temp_Cattr_tbl(3)
        ,l_temp_Cattr_tbl(4)
        ,l_temp_Cattr_tbl(5)
        ,l_temp_Cattr_tbl(6)
        ,l_temp_Cattr_tbl(7)
        ,l_temp_Cattr_tbl(8)
        ,l_temp_Cattr_tbl(9)
        ,l_temp_Cattr_tbl(10)
        ,l_temp_Cattr_tbl(11)
        ,l_temp_Cattr_tbl(12)
        ,l_temp_Cattr_tbl(13)
        ,l_temp_Cattr_tbl(14)
        ,l_temp_Cattr_tbl(15)
        ,l_temp_Cattr_tbl(16)
        ,l_temp_Cattr_tbl(17)
        ,l_temp_Cattr_tbl(18)
        ,l_temp_Cattr_tbl(19)
        ,l_temp_Cattr_tbl(20)
        ,l_temp_Dattr_tbl(1)
        ,l_temp_Dattr_tbl(2)
        ,l_temp_Dattr_tbl(3)
        ,l_temp_Dattr_tbl(4)
        ,l_temp_Dattr_tbl(5)
        ,l_temp_Dattr_tbl(6)
        ,l_temp_Dattr_tbl(7)
        ,l_temp_Dattr_tbl(8)
        ,l_temp_Dattr_tbl(9)
        ,l_temp_Dattr_tbl(10)
        ,l_temp_Nattr_tbl(1)
        ,l_temp_Nattr_tbl(2)
        ,l_temp_Nattr_tbl(3)
        ,l_temp_Nattr_tbl(4)
        ,l_temp_Nattr_tbl(5)
        ,l_temp_Nattr_tbl(6)
        ,l_temp_Nattr_tbl(7)
        ,l_temp_Nattr_tbl(8)
        ,l_temp_Nattr_tbl(9)
        ,l_temp_Nattr_tbl(10)
        ,l_attribute_category
        ,l_invattr_tbl(1)
        ,l_invattr_tbl(2)
        ,l_invattr_tbl(3)
        ,l_invattr_tbl(4)
        ,l_invattr_tbl(5)
        ,l_invattr_tbl(6)
        ,l_invattr_tbl(7)
        ,l_invattr_tbl(8)
        ,l_invattr_tbl(9)
        ,l_invattr_tbl(10)
        ,l_invattr_tbl(11)
        ,l_invattr_tbl(12)
        ,l_invattr_tbl(13)
        ,l_invattr_tbl(14)
        ,l_invattr_tbl(15)
        FROM mtl_lot_numbers
        WHERE lot_number=nvl(p_src_lot_number,p_lot_number)
        AND   inventory_item_id=nvl(p_src_inv_item_id,p_inv_item_id)
        AND   organization_id=p_org_id;



-- Populate the flex field record

 	l_dflex_r.application_id  := 401;
 	l_dflex_r.flexfield_name  := 'Lot Attributes';

-- Get all contexts

 	fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);

-- From the l_contexts_dr, get the position of the global context

        l_global_context   := NULL;
        l_context         := NULL;
  	l_global_context   := l_contexts_dr.global_context;
        l_context          := l_contexts_dr.context_code(l_global_context);

-- Prepare the l_context_r type for getting the segments associated with the global context

        l_context_r.flexfield     := l_dflex_r;
        l_context_r.context_code  := l_context;

-- Get the segments for the context

        fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

-- Loop through the global segments

	FOR wms_context_index IN 1 .. l_segments_dr.nsegments LOOP

		IF SUBSTR(l_segments_dr.application_column_name(wms_context_index),
                            INSTR(l_segments_dr.application_column_name(wms_context_index),'ATTRIBUTE')
                            -2,2) = 'C_'
			THEN
                       	l_Cattr_tbl(SUBSTR( l_segments_dr.application_column_name(wms_context_index)
                                   ,INSTR(l_segments_dr.application_column_name(wms_context_index),
                                   'ATTRIBUTE') + 9))
                       	:=

			l_temp_Cattr_tbl(SUBSTR( l_segments_dr.application_column_name(wms_context_index)
                                         ,INSTR(l_segments_dr.application_column_name(wms_context_index),
                                         'ATTRIBUTE') + 9));


 		ELSIF SUBSTR(l_segments_dr.application_column_name(wms_context_index),
                            INSTR(l_segments_dr.application_column_name(wms_context_index),'ATTRIBUTE')
                            -2,2) = 'N_'
			THEN
                       	l_Nattr_tbl(SUBSTR( l_segments_dr.application_column_name(wms_context_index)
                                   ,INSTR(l_segments_dr.application_column_name(wms_context_index),
                                   'ATTRIBUTE') + 9))
                       	:=

			l_temp_Nattr_tbl(SUBSTR( l_segments_dr.application_column_name(wms_context_index)
                                         ,INSTR(l_segments_dr.application_column_name(wms_context_index),
                                         'ATTRIBUTE') + 9));


		ELSIF SUBSTR(l_segments_dr.application_column_name(wms_context_index),
                            INSTR(l_segments_dr.application_column_name(wms_context_index),'ATTRIBUTE')
                            -2,2) = 'D_'
			THEN
                       	l_Dattr_tbl(SUBSTR( l_segments_dr.application_column_name(wms_context_index)
                                   ,INSTR(l_segments_dr.application_column_name(wms_context_index),
                                   'ATTRIBUTE') + 9))
                       	:=

			l_temp_Dattr_tbl(SUBSTR( l_segments_dr.application_column_name(wms_context_index)
                                         ,INSTR(l_segments_dr.application_column_name(wms_context_index),
                                         'ATTRIBUTE') + 9));


 		ELSIF l_segments_dr.application_column_name(wms_context_index) = 'GRADE_CODE' THEN
                 	l_grade_code := l_temp_grade_code;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'ORIGINATION_DATE' THEN
                 	l_origination_date := l_temp_origination_date;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'DATE_CODE' THEN
                 	l_date_code := l_temp_date_code;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'CHANGE_DATE' THEN
                 	l_change_date := l_temp_change_date;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'AGE' THEN
                 	l_age := l_temp_age;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'RETEST_DATE' THEN
                 	l_retest_date := l_temp_retest_date;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'MATURITY_DATE' THEN
                 	l_maturity_date := l_temp_maturity_date;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'ITEM_SIZE' THEN
                 	l_item_size := l_temp_item_size;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'COLOR' THEN
                 	l_color := l_temp_color;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'VOLUME' THEN
                 	l_volume := l_temp_volume;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'VOLUME_UOM' THEN
                 	l_volume_uom := l_temp_volume_uom;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'PLACE_OF_ORIGIN' THEN
                 	l_place_of_origin := l_temp_place_of_origin;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'BEST_BY_DATE' THEN
                 	l_best_by_date := l_temp_best_by_date;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'LENGTH' THEN
                 	l_length := l_temp_length;
 		ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'LENGTH_UOM' THEN
                 	l_length_uom := l_temp_length_uom;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'RECYCLED_CONTENT' THEN
                 	l_recycled_content := l_temp_recycled_content;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'THICKNESS' THEN
                 	l_thickness := l_temp_thickness;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'THICKNESS_UOM' THEN
                 	l_thickness_uom := l_temp_thickness_uom;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'WIDTH' THEN
                 	l_width := l_temp_width;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'WIDTH_UOM' THEN
                 	l_width_uom := l_temp_width_uom;
		ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'VENDOR_ID' THEN
                 	l_vendor_id := l_temp_vendor_id;
		ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'VENDOR_NAME' THEN
                 	l_vendor_name := l_temp_vendor_name;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'TERRITORY_CODE' THEN
                 	l_territory_code := l_temp_territory_code;
              	ELSIF l_segments_dr.application_column_name(wms_context_index) = 'SUPPLIER_LOT_NUMBER' THEN
                 	l_supplier_lot_number := l_temp_supplier_lot_number;
              	ELSIF  l_segments_dr.application_column_name(wms_context_index) = 'CURL_WRINKLE_FOLD' THEN
                 	l_curl_wrinkle_fold := l_curl_wrinkle_fold;
              	END IF;

	END LOOP;



      else -- Bug 5367283 if wms is not installed

        SELECT
        attribute_category
        , attribute1
        , attribute2
        , attribute3
        , attribute4
        , attribute5
        , attribute6
        , attribute7
        , attribute8
        , attribute9
        , attribute10
        , attribute11
        , attribute12
        , attribute13
        , attribute14
        , attribute15
        INTO
        l_attribute_category
        ,l_invattr_tbl(1)
        ,l_invattr_tbl(2)
        ,l_invattr_tbl(3)
        ,l_invattr_tbl(4)
        ,l_invattr_tbl(5)
        ,l_invattr_tbl(6)
        ,l_invattr_tbl(7)
        ,l_invattr_tbl(8)
        ,l_invattr_tbl(9)
        ,l_invattr_tbl(10)
        ,l_invattr_tbl(11)
        ,l_invattr_tbl(12)
        ,l_invattr_tbl(13)
        ,l_invattr_tbl(14)
        ,l_invattr_tbl(15)
        FROM mtl_lot_numbers
        WHERE lot_number=nvl(p_src_lot_number,p_lot_number)  -- modified for fixing bug 5126021
        AND   inventory_item_id=nvl(p_src_inv_item_id,p_inv_item_id) --  modified for fixing bug 5126021
        AND   organization_id=p_org_id;


      end if; -- bug 5367283 if clause for wms installed

      l_call_inv_lotapi :=TRUE;

      end if;  -- l_copy_from_src
    end if; --  NOT (x_lot_exists='N' and x_src_lot_exists='N') Bug 5282172.
    --END IF; -- x_lot_exists='N'

    if g_debug then
       pdebug('before select from mtli');
    end if;

	/* Added for fixing bug 5126021 */

	if l_intf_rec_found then
       SELECT
	   transaction_interface_id
	   ,decode(description,l_miss_char, NULL,NULL,l_description,description)
	   ,decode(grade_code,l_miss_char, NULL,NULL,l_grade_code,grade_code)
	   ,decode(origination_date,l_miss_date, NULL,NULL,l_origination_date,origination_date)
	   ,decode(date_code,l_miss_char, NULL,NULL,l_date_code,date_code)
	   ,decode(change_date,l_miss_date, NULL,NULL,l_change_date,change_date)
	   ,decode(age,l_miss_num, NULL,NULL,l_age,age)
	   ,decode(retest_date,l_miss_date, NULL,NULL,l_retest_date,retest_date)
	   ,decode(maturity_date,l_miss_date, NULL,NULL,l_maturity_date,maturity_date)
	   ,decode(item_size,l_miss_num, NULL,NULL,l_item_size,item_size)
	   ,decode(color,l_miss_char, NULL,NULL,l_color,color)
	   ,decode(volume,l_miss_num, NULL,NULL,l_volume,volume)
	   ,decode(volume_uom,l_miss_char, NULL,NULL,l_volume_uom,volume_uom)
	   ,decode(place_of_origin,l_miss_char, NULL,NULL,l_place_of_origin,place_of_origin)
	   ,decode(best_by_date,l_miss_date, NULL,NULL,l_best_by_date,best_by_date)
	   ,decode(length,l_miss_num, NULL,NULL,l_length,length)
	   ,decode(length_uom,l_miss_char, NULL,NULL,l_length_uom,length_uom)
	   ,decode(recycled_content,l_miss_num, NULL,NULL,l_recycled_content,recycled_content)
	   ,decode(thickness,l_miss_num, NULL,NULL,l_thickness,thickness)
	   ,decode(thickness_uom,l_miss_char, NULL,NULL,l_thickness_uom,thickness_uom)
	   ,decode(width,l_miss_num, NULL,NULL,l_width,width)
	   ,decode(width_uom,l_miss_char, NULL,NULL,l_width_uom,width_uom)
	   ,decode(vendor_id,l_miss_num, NULL,NULL,l_vendor_id,vendor_id)
	   ,decode(vendor_name,l_miss_char, NULL,NULL,l_vendor_name,vendor_name)
	   ,decode(territory_code,l_miss_char,NULL,NULL,l_territory_code,territory_code)
	   ,decode(supplier_lot_number,l_miss_char, NULL,NULL,l_supplier_lot_number,supplier_lot_number)
	   ,decode(curl_wrinkle_fold,l_miss_char, NULL,NULL,l_curl_wrinkle_fold,curl_wrinkle_fold)
	   ,decode(lot_attribute_category,l_miss_char, NULL,NULL,l_lot_attribute_category,lot_attribute_category)
	   ,decode(c_attribute1,l_miss_char, NULL,NULL,l_Cattr_tbl(1),c_attribute1)
	   ,decode(c_attribute2,l_miss_char, NULL,NULL,l_Cattr_tbl(2),c_attribute2)
	   ,decode(c_attribute3,l_miss_char, NULL,NULL,l_Cattr_tbl(3),c_attribute3)
	   ,decode(c_attribute4,l_miss_char, NULL,NULL,l_Cattr_tbl(4),c_attribute4)
       ,decode(c_attribute5,l_miss_char, NULL,NULL,l_Cattr_tbl(5),c_attribute5)
       ,decode(c_attribute6,l_miss_char, NULL,NULL,l_Cattr_tbl(6),c_attribute6)
       ,decode(c_attribute7,l_miss_char, NULL,NULL,l_Cattr_tbl(7),c_attribute7)
       ,decode(c_attribute8,l_miss_char, NULL,NULL,l_Cattr_tbl(8),c_attribute8)
       ,decode(c_attribute9,l_miss_char, NULL,NULL,l_Cattr_tbl(9),c_attribute9)
       ,decode(c_attribute10,l_miss_char, NULL,NULL,l_Cattr_tbl(10),c_attribute10)
       ,decode(c_attribute11,l_miss_char, NULL,NULL,l_Cattr_tbl(11),c_attribute11)
       ,decode(c_attribute12,l_miss_char, NULL,NULL,l_Cattr_tbl(12),c_attribute12)
       ,decode(c_attribute13,l_miss_char, NULL,NULL,l_Cattr_tbl(13),c_attribute13)
       ,decode(c_attribute14,l_miss_char, NULL,NULL,l_Cattr_tbl(14),c_attribute14)
       ,decode(c_attribute15,l_miss_char, NULL,NULL,l_Cattr_tbl(15),c_attribute15)
       ,decode(c_attribute16,l_miss_char, NULL,NULL,l_Cattr_tbl(16),c_attribute16)
       ,decode(c_attribute17,l_miss_char, NULL,NULL,l_Cattr_tbl(17),c_attribute17)
       ,decode(c_attribute18,l_miss_char, NULL,NULL,l_Cattr_tbl(18),c_attribute18)
       ,decode(c_attribute19,l_miss_char, NULL,NULL,l_Cattr_tbl(19),c_attribute19)
       ,decode(c_attribute20,l_miss_char, NULL,NULL,l_Cattr_tbl(20),c_attribute20)
       ,decode(d_attribute1,l_miss_date, NULL,NULL,l_Dattr_tbl(1),d_attribute1)
       ,decode(d_attribute2,l_miss_date, NULL,NULL,l_Dattr_tbl(2),d_attribute2)
       ,decode(d_attribute3,l_miss_date, NULL,NULL,l_Dattr_tbl(3),d_attribute3)
       ,decode(d_attribute4,l_miss_date, NULL,NULL,l_Dattr_tbl(4),d_attribute4)
       ,decode(d_attribute5,l_miss_date, NULL,NULL,l_Dattr_tbl(5),d_attribute5)
       ,decode(d_attribute6,l_miss_date, NULL,NULL,l_Dattr_tbl(6),d_attribute6)
       ,decode(d_attribute7,l_miss_date, NULL,NULL,l_Dattr_tbl(7),d_attribute7)
       ,decode(d_attribute8,l_miss_date, NULL,NULL,l_Dattr_tbl(8),d_attribute8)
       ,decode(d_attribute9,l_miss_date, NULL,NULL,l_Dattr_tbl(9),d_attribute9)
       ,decode(d_attribute10,l_miss_date, NULL,NULL,l_Dattr_tbl(10),d_attribute10)
       ,decode(n_attribute1,l_miss_num, NULL,NULL,l_Nattr_tbl(1),n_attribute1)
       ,decode(n_attribute2,l_miss_num, NULL,NULL,l_Nattr_tbl(2),n_attribute2)
       ,decode(n_attribute3,l_miss_num, NULL,NULL,l_Nattr_tbl(3),n_attribute3)
       ,decode(n_attribute4,l_miss_num, NULL,NULL,l_Nattr_tbl(4),n_attribute4)
       ,decode(n_attribute5,l_miss_num, NULL,NULL,l_Nattr_tbl(5),n_attribute5)
       ,decode(n_attribute6,l_miss_num, NULL,NULL,l_Nattr_tbl(6),n_attribute6)
       ,decode(n_attribute7,l_miss_num, NULL,NULL,l_Nattr_tbl(7),n_attribute7)
       ,decode(n_attribute8,l_miss_num, NULL,NULL,l_Nattr_tbl(8),n_attribute8)
       ,decode(n_attribute9,l_miss_num, NULL,NULL,l_Nattr_tbl(9),n_attribute9)
       ,decode(n_attribute10,l_miss_num, NULL,NULL,l_Nattr_tbl(10),n_attribute10)
	   ,decode(attribute_category,l_miss_char, NULL,NULL,l_attribute_category,attribute_category)
       ,decode(attribute1,l_miss_char, NULL,NULL,l_invattr_tbl(1),attribute1)
       ,decode(attribute2,l_miss_char, NULL,NULL,l_invattr_tbl(2),attribute2)
       ,decode(attribute3,l_miss_char, NULL,NULL,l_invattr_tbl(3),attribute3)
       ,decode(attribute4,l_miss_char, NULL,NULL,l_invattr_tbl(4),attribute4)
       ,decode(attribute5,l_miss_char, NULL,NULL,l_invattr_tbl(5),attribute5)
       ,decode(attribute6,l_miss_char, NULL,NULL,l_invattr_tbl(6),attribute6)
       ,decode(attribute7,l_miss_char, NULL,NULL,l_invattr_tbl(7),attribute7)
       ,decode(attribute8,l_miss_char, NULL,NULL,l_invattr_tbl(8),attribute8)
       ,decode(attribute9,l_miss_char, NULL,NULL,l_invattr_tbl(9),attribute9)
       ,decode(attribute10,l_miss_char, NULL,NULL,l_invattr_tbl(10),attribute10)
       ,decode(attribute11,l_miss_char, NULL,NULL,l_invattr_tbl(11),attribute11)
       ,decode(attribute12,l_miss_char, NULL,NULL,l_invattr_tbl(12),attribute12)
       ,decode(attribute13,l_miss_char, NULL,NULL,l_invattr_tbl(13),attribute13)
       ,decode(attribute14,l_miss_char, NULL,NULL,l_invattr_tbl(14),attribute14)
       ,decode(attribute15,l_miss_char, NULL,NULL,l_invattr_tbl(15),attribute15)
       INTO
   	   l_mtli_txn_id
	   ,l_description
	   ,l_grade_code
	   ,l_origination_date
	   ,l_date_code
	   ,l_change_date
	   ,l_age
	   ,l_retest_date
	   ,l_maturity_date
	   ,l_item_size
	   ,l_color
	   ,l_volume
	   ,l_volume_uom
	   ,l_place_of_origin
	   ,l_best_by_date
	   ,l_length
	   ,l_length_uom
	   ,l_recycled_content
	   ,l_thickness
	   ,l_thickness_uom
	   ,l_width
	   ,l_width_uom
	   ,l_vendor_id
	   ,l_vendor_name
	   ,l_territory_code
	   ,l_supplier_lot_number
	   ,l_curl_wrinkle_fold
	   ,l_lot_attribute_category
	   ,l_Cattr_tbl(1)
	   ,l_Cattr_tbl(2)
	   ,l_Cattr_tbl(3)
	   ,l_Cattr_tbl(4)
	   ,l_Cattr_tbl(5)
	   ,l_Cattr_tbl(6)
	   ,l_Cattr_tbl(7)
	   ,l_Cattr_tbl(8)
	   ,l_Cattr_tbl(9)
	   ,l_Cattr_tbl(10)
	   ,l_Cattr_tbl(11)
	   ,l_Cattr_tbl(12)
	   ,l_Cattr_tbl(13)
	   ,l_Cattr_tbl(14)
	   ,l_Cattr_tbl(15)
	   ,l_Cattr_tbl(16)
	   ,l_Cattr_tbl(17)
	   ,l_Cattr_tbl(18)
	   ,l_Cattr_tbl(19)
	   ,l_Cattr_tbl(20)
	   ,l_Dattr_tbl(1)
	   ,l_Dattr_tbl(2)
	   ,l_Dattr_tbl(3)
	   ,l_Dattr_tbl(4)
	   ,l_Dattr_tbl(5)
	   ,l_Dattr_tbl(6)
	   ,l_Dattr_tbl(7)
	   ,l_Dattr_tbl(8)
	   ,l_Dattr_tbl(9)
	   ,l_Dattr_tbl(10)
	   ,l_Nattr_tbl(1)
	   ,l_Nattr_tbl(2)
	   ,l_Nattr_tbl(3)
	   ,l_Nattr_tbl(4)
	   ,l_Nattr_tbl(5)
	   ,l_Nattr_tbl(6)
	   ,l_Nattr_tbl(7)
	   ,l_Nattr_tbl(8)
	   ,l_Nattr_tbl(9)
	   ,l_Nattr_tbl(10)
	   ,l_attribute_category
	   ,l_invattr_tbl(1)
	   ,l_invattr_tbl(2)
	   ,l_invattr_tbl(3)
	   ,l_invattr_tbl(4)
	   ,l_invattr_tbl(5)
	   ,l_invattr_tbl(6)
	   ,l_invattr_tbl(7)
	   ,l_invattr_tbl(8)
	   ,l_invattr_tbl(9)
	   ,l_invattr_tbl(10)
	   ,l_invattr_tbl(11)
	   ,l_invattr_tbl(12)
	   ,l_invattr_tbl(13)
	   ,l_invattr_tbl(14)
	   ,l_invattr_tbl(15)
	   FROM mtl_transaction_lots_interface
	   WHERE product_transaction_id=p_intf_txn_id
	   AND product_code=p_intf_src_code
	   AND lot_number=p_lot_number;

	   l_call_inv_lotapi :=TRUE;

	   if g_debug then
          pdebug('l_intf_rec_found=TRUE l_call_inv_lotapi=TRUE and l_copy_from_src=FALSE');
       end if;

    else

	   if g_debug then
          pdebug('intf txnid=' || p_intf_txn_id);
          pdebug('product_code=' || p_intf_src_code ||' lotnumber=' || p_lot_number);
       end if;
            l_intf_rec_found:=FALSE;
    end if; -- l_intf_rec_found

	/* Added for fixing bug 5126021 */

 if (NOT l_call_inv_lotapi)  and x_lot_exists='N' THEN
    if inv_lot_sel_attr.is_enabled('Lot Attributes',
           p_org_id,p_inv_item_id) >= 2  THEN
           l_wms_attr_required:=TRUE;
    end if;
    if inv_lot_sel_attr.is_enabled('MTL_LOT_NUMBERS',
                p_org_id,p_inv_item_id) >= 2  THEN
           l_inv_attr_required:=TRUE;
    end if;
    if (l_wms_attr_required OR l_inv_attr_required) THEN
           fnd_message.set_name('WSM','WSM_REQUIRED_ATTR_NO_INTF');
           x_err_msg:=FND_MESSAGE.GET;
           x_err_code:=-1;
           return;
    end if;
  end if;

 if l_call_inv_lotapi THEN
    if x_lot_exists='Y' THEN
       if g_debug then
	      pdebug('x_lot_exists=Y');
          pdebug('Before Calling inv_lot_api_pub.Update_inv_lot lot attrcat ' ||
                l_lot_attribute_category ||
                ' attr_category='|| l_attribute_category);
        end if;
        inv_lot_api_pub.Update_inv_lot(
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_err_msg,
        p_inventory_item_id     => p_inv_item_id,
        p_organization_id       => p_org_id,
        p_lot_number            => p_lot_number,
        p_expiration_date       => NULL,
        p_disable_flag          => NULL,
        p_attribute_category    => l_attribute_category,
        p_lot_attribute_category=> l_lot_attribute_category,
        p_attributes_tbl        => l_Invattr_tbl,
        p_c_attributes_tbl      => l_CAttr_tbl,
        p_n_attributes_tbl      => l_NAttr_tbl,
        p_d_attributes_tbl      => l_DAttr_tbl,
        p_grade_code            => l_grade_code,
        p_origination_date      => l_origination_date,
        p_date_code             => l_date_code,
        p_status_id             => l_status_id,
        p_change_date           => l_change_date,
        p_age                   => l_age,
        p_retest_date           => l_retest_date,
        p_maturity_date         => l_maturity_date,
        p_item_size             => l_item_size,
        p_color                 => l_color,
        p_volume                => l_volume,
        p_volume_uom            => l_volume_uom,
        p_place_of_origin       => l_place_of_origin,
        p_best_by_date          => l_best_by_date,
        p_length                => l_length,
        p_length_uom            => l_length_uom,
        p_recycled_content      => l_recycled_content,
        p_thickness             => l_thickness,
        p_thickness_uom         => l_thickness_uom,
        p_width                 => l_width,
        p_width_uom             => l_width_uom,
        p_territory_code        => l_territory_code,
        p_supplier_lot_number   => l_supplier_lot_number,
        p_vendor_name           => l_vendor_name,
        p_source                => 2);
   ELSE                                         -- x_lot_exists='N'
        if g_debug then
		   pdebug('x_lot_exists=N');
           pdebug('Before Calling inv_lot_api_pub.Update_inv_lot lot attrcat ' ||
                l_lot_attribute_category ||
                 'attr_category=' || l_attribute_category);
        end if;
        inv_lot_api_pub.create_inv_lot(
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_err_msg,
        p_inventory_item_id     => p_inv_item_id,
        p_organization_id       => p_org_id,
        p_lot_number            => p_lot_number,
        p_expiration_date       => NULL,
        p_disable_flag          => NULL,
        p_attribute_category    => l_attribute_category,
        p_lot_attribute_category=> l_lot_attribute_category,
        p_attributes_tbl        => l_Invattr_tbl,
        p_c_attributes_tbl      => l_CAttr_tbl,
        p_n_attributes_tbl      => l_NAttr_tbl,
        p_d_attributes_tbl      => l_DAttr_tbl,
        p_grade_code            => l_grade_code,
        p_origination_date      => l_origination_date,
        p_date_code             => l_date_code,
        p_status_id             => l_status_id,
        p_change_date           => l_change_date,
        p_age                   => l_age,
        p_retest_date           => l_retest_date,
        p_maturity_date         => l_maturity_date,
        p_item_size             => l_item_size,
        p_color                 => l_color,
        p_volume                => l_volume,
        p_volume_uom            => l_volume_uom,
        p_place_of_origin       => l_place_of_origin,
        p_best_by_date          => l_best_by_date,
        p_length                => l_length,
        p_length_uom            => l_length_uom,
        p_recycled_content      => l_recycled_content,
        p_thickness             => l_thickness,
        p_thickness_uom         => l_thickness_uom,
        p_width                 => l_width,
        p_width_uom             => l_width_uom,
        p_territory_code        => l_territory_code,
        p_supplier_lot_number   => l_supplier_lot_number,
        p_vendor_name           => l_vendor_name,
        p_source                => 2);
   END IF; -- x_lot_exists='Y'
   if g_debug then
      pdebug('Return status= ' || x_return_status);
   end if;
   if x_return_status <> 'S' THEN
      pdebug('Error msg=' || x_err_msg);
      x_err_code:=-1;
   end if;
END IF;    -- l_call_inv_lotapi

EXCEPTION
    WHEN OTHERS THEN
    x_err_code := SQLCODE;
    x_err_msg := 'WSM_LotAttr_PVT.create_update_lotattr '|| SUBSTR(SQLERRM,1,2000);
    return;
END create_update_lotattr;

Procedure create_update_lotattr(x_err_code       OUT NOCOPY VARCHAR2,
                                x_err_msg        OUT NOCOPY VARCHAR2,
                                p_wip_entity_id  IN   NUMBER,
                                p_org_id         IN   NUMBER,
                                p_intf_txn_id    IN   NUMBER,
                                p_intf_src_code  IN   VARCHAR2,
                                p_src_lot_number IN   VARCHAR2 DEFAULT NULL,
                                p_src_inv_item_id IN  NUMBER   DEFAULT NULL) is

l_lot_number VARCHAR2(80):=NULL;        -- Changed for OPM Convergence project
l_inv_item_id NUMBER:=NULL;

BEGIN
        SELECT lot_number, primary_item_id
          INTO l_lot_number, l_inv_item_id
          FROM wip_discrete_jobs
         WHERE wip_entity_id=p_wip_entity_id;

        WSM_LotAttr_PVT.create_update_lotattr(x_err_code,
                                x_err_msg,
                                l_lot_number,
                                l_inv_item_id,
                                p_org_id,
                                p_intf_txn_id,
                                p_intf_src_code,
                                p_src_lot_number,
                                p_src_inv_item_id);

 EXCEPTION
        WHEN OTHERS THEN
             fnd_message.set_name('WSM','WSM_INVALID_FIELD');
             fnd_message.set_token('FLD_NAME','WIP_ENTITY_ID');
             x_err_msg:=fnd_message.get;
             x_err_code:=-1;
             return;

END create_update_lotattr;

END WSM_LotAttr_PVT;

/
