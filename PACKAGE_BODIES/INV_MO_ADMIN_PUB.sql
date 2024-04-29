--------------------------------------------------------
--  DDL for Package Body INV_MO_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MO_ADMIN_PUB" AS
/* $Header: INVPMOAB.pls 120.5.12010000.3 2009/12/28 10:12:48 hjogleka ship $ */

--  Global constant holding the package name

G_PKG_NAME             CONSTANT VARCHAR2(30) := 'INV_MO_Admin_Pub';



/*
     Procedure : Cancel Order

	This procedure should cancel the order and associated lines for
        the header Id provided, If the order is not already closed/cancelled
*/

Procedure Cancel_Order(
			p_api_version  	      In  Number,
			p_init_msg_list	      In  varchar2 ,
			p_commit	      In  varchar2 ,
			p_validation_level    In  varchar2 ,
			p_header_Id	      In  Number,
			x_msg_count	      Out Nocopy Number,
			x_msg_data	      Out Nocopy varchar2,
			x_return_status       Out Nocopy Varchar2
		       ) IS

 l_api_version	          CONSTANT NUMBER := 1.0;
 l_api_name               CONSTANT VARCHAR2(30):= 'Cancel_Order';
 l_return_status        Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
 l_trohdr_rec		INV_Move_Order_PUB.Trohdr_Rec_Type;
 l_trolin_rec           INV_Move_Order_PUB.Trolin_Rec_Type;
 l_trohdr_val_rec       INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
 l_trolin_val_tbl       INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
 l_trolin_tbl           INV_Move_Order_PUB.Trolin_Tbl_Type;
 l_msg_count		Number;
 l_msg_data		Varchar2(100);
 l_header_id		Number := p_header_Id;

 BEGIN

  -- Standard call to check compatibility
	IF NOT FND_API.Compatible_API_Call (	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME  )    THEN
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

 -- Initailize message list
    If  FND_API.To_Boolean( p_init_msg_list ) Then
		FND_MSG_PUB.initialize;
    End If;

 -- API Body
     INV_Move_Order_Pub.Get_Move_Order(
	p_api_version_number	=>	1.0,
	p_init_msg_list		=>	FND_API.G_TRUE,
	x_return_status         =>      l_return_status,
        x_msg_count		=>	l_msg_count,
	x_msg_data		=>	l_msg_data,
	p_header_id		=>      l_header_Id,
	x_trohdr_rec		=> 	l_trohdr_rec,
        x_trohdr_val_rec	=>	l_trohdr_val_rec,
        x_trolin_tbl		=>      l_trolin_tbl,
        x_trolin_val_tbl	=>	l_trolin_val_tbl);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF l_return_status = FND_API.G_RET_STS_ERROR  then
	      RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  then
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  -- Header Status 5 is closed, 6 is canceled
      IF  ( l_trohdr_rec.header_status = 6 )  THEN
	    x_return_status := l_return_status;
            Return;
      END IF;

      IF  ( l_trohdr_rec.header_status = 5 )  THEN
	FND_MESSAGE.SET_NAME('INV','INV_TO_HEADER_STATUS');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      for I in 1..l_trolin_tbl.count  loop
          Cancel_Line(
		        p_api_version		=>   1.0,
			p_line_id 		=>   l_trolin_tbl(I).Line_Id,
        		x_msg_count		=>   l_msg_count,
			x_msg_data		=>   l_msg_data,
			x_return_status         =>   l_return_status
		    );
  		if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  then
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  		elsif l_return_status = FND_API.G_RET_STS_ERROR  then
			RAISE FND_API.G_EXC_ERROR;
  		end if;
      end loop;


      -- Updating the who columns for bug 3277406
      -- Updating status date for bug 8563083
      Update MTL_TXN_REQUEST_HEADERS
      set    header_status = 6,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      last_update_date = sysdate,
      status_date = sysdate
      where
             header_id = l_header_id;

      x_return_status := l_return_status;

 -- Std check  of p_commit
	if FND_API.To_Boolean( p_commit ) then
		COMMIT WORK;
	end if;

 -- Call to get msg count
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data) ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data) ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Cancel_Order');
      END IF;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data) ;
 END CANCEL_ORDER;



/*
     Procedure : Close Order

	This procedure should close the order associated with header Id.
*/

  PROCEDURE Close_Order(
			p_api_version  	      In  Number,
			p_init_msg_list	      In  varchar2 ,
			p_commit	      In  varchar2 ,
			p_validation_level    In  varchar2 ,
			p_header_Id	      In  Number,
			x_msg_count	      Out Nocopy Number,
			x_msg_data	      Out Nocopy varchar2,
			x_return_status       Out Nocopy Varchar2
			) IS

  l_api_version          CONSTANT NUMBER := 1.0;
  l_api_name             CONSTANT VARCHAR2(30):= 'Close_Order';
  l_header_id		Number := p_header_id;
  l_hdr_status		Number;
  --l_request_number	Varchar2(25) := NULL;
  --Bug 9118049, Request_number column in MTRH is defined to accept 30 characters.
  --Stretching the variable from 25 char to 30 chars.
  l_request_number	MTL_TXN_REQUEST_HEADERS.request_number%type := NULL;
  l_return_status       Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  l_trolin_tbl		INV_Move_Order_PUB.Trolin_Tbl_Type;
  l_line_status         NUMBER := 0;

    BEGIN

  -- Standard call to check compatibility
	IF NOT FND_API.Compatible_API_Call (	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME  )    THEN
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

 -- Initailize message list
    If  FND_API.To_Boolean( p_init_msg_list ) Then
		FND_MSG_PUB.initialize;
    End If;

  -- API Body
  BEGIN
		SELECT header_status, request_number
    INTO   l_hdr_status, l_request_number
		FROM   mtl_txn_request_headers
		WHERE  Header_id = l_header_id;
  EXCEPTION
    WHEN No_Data_Found THEN
	    RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Close Order');
	    RAISE FND_API.G_EXC_ERROR;
  END;

      IF ( l_hdr_status = 5 ) THEN
    	x_return_status := l_return_status;
        Return;
      END IF;

      --Bug 3666433
      IF ( l_hdr_status in (2,4,8)) THEN
        Begin
          SELECT 1
          INTO   l_line_status
          FROM   mtl_txn_request_lines
          WHERE  header_id = l_header_id
          AND    line_status in (1,2,8)
          AND    ROWNUM = 1;
        Exception
          WHEN NO_DATA_FOUND THEN
            NULL;
        End;
       END IF;

      IF ( l_hdr_status = 1 OR l_line_status = 1 ) THEN
	FND_MESSAGE.SET_NAME('INV','INV_TO_HEADER_STATUS');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_trolin_tbl := Inv_Trolin_Util.Get_Lines( l_header_id );
      For I in 1..l_trolin_tbl.count Loop
          Close_Line(
		        p_api_version           =>   1.0,
			p_line_id 		=>   l_trolin_tbl(I).Line_Id,
        		x_msg_count		=>   x_msg_count,
			x_msg_data		=>   x_msg_data,
			x_return_status         =>   l_return_status
	            );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  then
			      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
  		    IF l_return_status = FND_API.G_RET_STS_ERROR  then
			      RAISE FND_API.G_EXC_ERROR;
  		    end if;
        END IF;
       End Loop;


      -- Updating the who columns for bug 3277406
      -- Updating status date for bug 8563083
      Update MTL_TXN_REQUEST_HEADERS
      set    header_status = 5,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      last_update_date = sysdate,
      status_date = sysdate
      where
             header_id = l_header_id;

      x_return_status := l_return_status;

 -- Std check  of p_commit
	if FND_API.To_Boolean( p_commit ) then
		COMMIT WORK;
	end if;

 -- Call to get msg count and data
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MSG_PUB.Count_And_Get(
		    p_count		=>  x_msg_count,
		    p_data		=>  x_msg_data) ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_MSG_PUB.Count_And_Get(
		    p_count		=>  x_msg_count,
		    p_data		=>  x_msg_data) ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Close_Order');
    END IF;
	  FND_MSG_PUB.Count_And_Get(
		    p_count		=>  x_msg_count,
		    p_data		=>  x_msg_data) ;
 END CLOSE_ORDER;



/*
     Procedure : Purge Order

	This procedure should purge the order associated with header Id.
*/

  PROCEDURE Purge_Order(
			p_api_version  	      In  Number,
			p_init_msg_list	      In  varchar2 ,
			p_commit	      In  varchar2 ,
			p_validation_level    In  varchar2 ,
			p_header_Id	      In  Number,
			x_msg_count	      Out Nocopy Number,
			x_msg_data	      Out Nocopy varchar2,
			x_return_status       Out Nocopy Varchar2
			)  IS

  l_api_version		CONSTANT NUMBER := 1.0;
  l_api_name            CONSTANT VARCHAR2(30):= 'Purge_Order';
  l_header_id		Number := p_header_id;
  l_hdr_status		Number;
  --l_request_number	Varchar2(25) := NULL;
  --Bug 9118049, Request_number column in MTRH is defined to accept 30 characters.
  --Stretching the variable from 25 char to 30 chars.
  l_request_number	MTL_TXN_REQUEST_HEADERS.request_number%type := NULL;
  l_return_status       Varchar2(1) := FND_API.G_RET_STS_SUCCESS;

    BEGIN

  -- Standard call to check compatibility
	IF NOT FND_API.Compatible_API_Call (	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME  )    THEN
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

 -- Initailize message list
    If  FND_API.To_Boolean( p_init_msg_list ) Then
		FND_MSG_PUB.initialize;
    End If;

 -- API Body
	Begin
		Select header_status, request_number
                into   l_hdr_status, l_request_number
		from mtl_txn_request_headers
		where
                Header_id = l_header_id;
        Exception
        When No_Data_Found Then
	    RAISE FND_API.G_EXC_ERROR;
        When OTHERS then
              FND_MSG_PUB.Add_Exc_Msg
                      (   G_PKG_NAME
                       ,   'purge Order'
                        );

	    RAISE FND_API.G_EXC_ERROR;
       End;

      IF ( l_hdr_status <> 5 ) THEN
	FND_MESSAGE.SET_NAME('INV','INV_TO_HEADER_STATUS');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      Delete MTL_TXN_REQUEST_LINES
      where
             header_id = l_header_id;

      Delete MTL_TXN_REQUEST_HEADERS
      where
             header_id = l_header_id;

      x_return_status := l_return_status;


 -- Std check  of p_commit
	if FND_API.To_Boolean( p_commit ) then
		COMMIT WORK;
	end if;

 -- Call to get msg count and data
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;


    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Purge_Order'
            );
        END IF;
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;

 END PURGE_ORDER;


/*
     Procedure : Cancel Line

	This procedure should Cancel the Line associated with Line Id.
*/

  PROCEDURE Cancel_Line(
			p_api_version  	      In  Number,
			p_init_msg_list	      In  varchar2 ,
			p_commit	      In  varchar2 ,
			p_validation_level    In  varchar2 ,
			p_line_id	      In  Number,
			x_msg_count	      Out Nocopy Number,
			x_msg_data	      Out Nocopy varchar2,
			x_return_status       Out Nocopy Varchar2
			) IS

  l_api_version          CONSTANT NUMBER := 1.0;
  l_api_name             CONSTANT VARCHAR2(30):= 'Cancel_Line';
  l_Line_Id		Number := p_line_Id;
  l_line_status		Number;
  l_request_number	Varchar2(25) := NULL;
  l_return_status       Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  l_old_trolin_tbl      INV_Move_Order_PUB.Trolin_tbl_Type;
  l_new_trolin_tbl      INV_Move_Order_PUB.Trolin_tbl_Type;
  l_x_trohdr_rec        INV_Move_Order_PUB.Trohdr_Rec_Type;
  l_x_trolin_tbl        INV_Move_Order_PUB.Trolin_Tbl_Type;
  l_old_trolin_rec      INV_Move_Order_PUB.Trolin_rec_Type;
  l_msg_count		Number;
  l_msg_data		Varchar2(100);
  l_qty_del		Number;
  l_mo_type		Number;
  l_loaded_lpn_exists	Number;  --Added bug 3254130
  l_delete_mmtt	        Varchar2(3); --Added bug 3524130
  l_org_id              Number;
  l_wms_org_flag        Boolean;

  BEGIN

  -- Standard call to check compatibility
	IF NOT FND_API.Compatible_API_Call (	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME  )    THEN
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

 -- Initailize message list
    If  FND_API.To_Boolean( p_init_msg_list ) Then
		FND_MSG_PUB.initialize;
    End If;

 -- API Body
	Begin
    --Bug 4417695
    --Need to lock the record while updating the MOL since any other form
    --should not hang and should show the correct exception.
		SELECT line_status, quantity_delivered, move_order_type, organization_id
    INTO   l_line_status, l_qty_del, l_mo_type, l_org_id
		FROM   mtl_txn_request_lines_v
		WHERE  Line_Id = l_Line_Id
    FOR UPDATE NOWAIT;
  EXCEPTION
    WHEN No_Data_Found THEN
	    RAISE FND_API.G_EXC_ERROR;
    WHEN app_exceptions.record_lock_exception THEN
 	    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
 	      fnd_message.set_name('ONT', 'OE_LOCK_ROW_ALREADY_LOCKED');
 	      fnd_msg_pub.ADD;
 	    END IF;
 	    RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Cancel Line');
	    RAISE FND_API.G_EXC_ERROR;
  END;


      IF ( l_Line_status = 6 ) THEN
	 x_return_status := l_return_status ;
         Return;
      END IF;

      IF ( l_Line_status = 5 ) THEN
	FND_MESSAGE.SET_NAME('INV','INV_TO_HEADER_STATUS');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( l_mo_type <> 3 ) then /* 3 - pickwave type MO */
         IF ( NVL(l_qty_del,0) <> 0 ) then

		RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

    l_old_trolin_rec := Inv_Trolin_Util.Query_Row( l_line_id );

    l_old_trolin_tbl(1) := l_old_trolin_rec;
    l_new_trolin_tbl(1) := l_old_trolin_rec;

    /*Added bug 3524130*/
    l_loaded_lpn_exists := 0;
    l_wms_org_flag := inv_install.adv_inv_installed
                       (p_organization_id => l_org_id);
    IF ( l_wms_org_flag ) THEN
     Begin
      select  1
      into l_loaded_lpn_exists
      from mtl_material_transactions_temp mmtt,wms_dispatched_tasks wdt
      where mmtt.transaction_temp_id = wdt.transaction_temp_id
      and wdt.status = 4
      and mmtt.transfer_lpn_id is not null
      and mmtt.move_order_line_id = l_line_id
      and rownum = 1;

      if l_loaded_lpn_exists = 1 then
      	l_new_trolin_tbl(1).line_status := 9;
     	l_new_trolin_tbl(1).status_date := sysdate; --bug 5053725
	l_delete_mmtt := 'NO';
      else
	l_new_trolin_tbl(1).line_status := 6;
    	l_new_trolin_tbl(1).status_date := sysdate; --bug 5053725
	l_delete_mmtt := 'YES';
      end if;
     --Bug3640116
      Exception
        When No_Data_Found Then
	  l_new_trolin_tbl(1).line_status := 6;
          l_new_trolin_tbl(1).status_date := sysdate; --bug 5053725
	  l_delete_mmtt := 'YES';
        When OTHERS then
              FND_MSG_PUB.Add_Exc_Msg
                      (   G_PKG_NAME
                       ,   'Cancel Line'
                        );

	RAISE FND_API.G_EXC_ERROR;
       End;
     ELSE
       l_new_trolin_tbl(1).line_status := 6;
       l_new_trolin_tbl(1).status_date := sysdate; --bug 5053725
       l_delete_mmtt := 'YES';
     END IF;

      /*Bug fix3524130 ends*/
      l_new_trolin_tbl(1).operation   := INV_GLOBALS.G_OPR_UPDATE;

     /** call update line API **/
   INV_Transfer_Order_PVT.Process_Transfer_Order
        (  p_api_version_number       => 1.0 ,
           p_init_msg_list            => FND_API.G_TRUE,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data,
           p_trolin_tbl               => l_new_trolin_tbl,
           p_old_trolin_tbl           => l_old_trolin_tbl,
           x_trohdr_rec               => l_x_trohdr_rec,
           x_trolin_tbl               => l_x_trolin_tbl,
	   p_delete_mmtt	      => l_delete_mmtt  --Added bug3524130
        );

 	if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  then
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	elsif l_return_status = FND_API.G_RET_STS_ERROR  then
		RAISE FND_API.G_EXC_ERROR;
  	end if;

        x_return_status := l_return_status;


 -- Std check  of p_commit
	if FND_API.To_Boolean( p_commit ) then
		COMMIT WORK;
	end if;

 -- Call to get msg count and data
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data) ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data) ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Cancel line');
      END IF;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data    ) ;
 END CANCEL_LINE;




/*
     Procedure : Close Line

	This procedure should close the Line associated with Line Id.
*/

  PROCEDURE Close_Line(
			p_api_version  	      In  Number,
			p_init_msg_list	      In  varchar2 ,
			p_commit	      In  varchar2 ,
			p_validation_level    In  varchar2 ,
			p_line_id	      In  Number,
			x_msg_count	      Out Nocopy Number,
			x_msg_data	      Out Nocopy varchar2,
			x_return_status       Out Nocopy Varchar2
			) IS

  l_api_version          CONSTANT NUMBER := 1.0;
  l_api_name             CONSTANT VARCHAR2(30):= 'Close_Line';
  l_Line_Id		Number := p_line_Id;
  l_line_status		Number;
  l_qty_del		Number;
  l_qty			Number;
  l_request_number	Varchar2(25) := NULL;
  l_return_status       Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  l_loaded_lpn_exists   Number; --Added bug3524130
  l_org_id              Number;
  l_wms_org_flag        Boolean;
  l_wrd_exists  NUMBER := 0;

    BEGIN

  -- Standard call to check compatibility
	IF NOT FND_API.Compatible_API_Call (	l_api_version,
						p_api_version,
						l_api_name,
						G_PKG_NAME  )    THEN
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

 -- Initailize message list
    If  FND_API.To_Boolean( p_init_msg_list ) Then
		FND_MSG_PUB.initialize;
    End If;

  -- API Body
	BEGIN
    --Bug 4417695
    --Need to lock the record while updating the MOL since any other form
    --should not hang and should show the correct exception.
		SELECT line_status, quantity_delivered, quantity ,organization_id
    INTO   l_line_status, l_qty_del, l_qty, l_org_id
		FROM   mtl_txn_request_lines
		WHERE  Line_Id = l_Line_Id
    FOR UPDATE NOWAIT;
  EXCEPTION
    WHEN No_Data_Found THEN
	    RAISE FND_API.G_EXC_ERROR;
    WHEN app_exceptions.record_lock_exception THEN
 	    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
 	      fnd_message.set_name('ONT', 'OE_LOCK_ROW_ALREADY_LOCKED');
 	      fnd_msg_pub.ADD;
 	    END IF;
 	    RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Close Line');
	    RAISE FND_API.G_EXC_ERROR;
  END;

      IF ( l_Line_status = 5 ) THEN
	 x_return_status := l_return_status ;
         Return;
      END IF;


      /*IF ( l_line_status in ( 3, 7 ) ) then
         if ( nvl(l_qty_del, 0)  < l_qty ) then
		RAISE FND_API.G_EXC_ERROR;
         end if;
      END IF; 	 */

      IF ( l_Line_status not in (3,4,6,7,9) ) THEN
	FND_MESSAGE.SET_NAME('INV','INV_TO_HEADER_STATUS');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

      /*Added bug3524130*/
      l_loaded_lpn_exists := 0;

      l_wms_org_flag := inv_install.adv_inv_installed
                       (p_organization_id => l_org_id);
      IF ( l_wms_org_flag ) THEN

	 -- For R12.1 Replenishment Project (6808839/6751117) STARTS --
	 -- We can not close the replenishment MO if these are associated with
	 -- delivery details for their replenishment, EVEN if Fill Kill
	 -- profile IS SET TO YES
	 -- For Fill Kill, this proc gets called from WMSTASKB.pls WMSTRSAB.pls INVVTROB.pls
         BEGIN
	    SELECT 1 INTO l_wrd_exists FROM dual WHERE exists
	      (SELECT 1
	       FROM wms_replenishment_details wrd
	       WHERE wrd.source_line_id = l_line_id);
	 EXCEPTION
	    WHEN OTHERS THEN
	       l_wrd_exists := 0;
	 END;

	 IF l_wrd_exists = 1 THEN
	    RETURN;
	 END IF;
	 -- For R12.1 Replenishment Project (6808839/6751117) ENDS --

         BEGIN
	    select  1
	      into l_loaded_lpn_exists
	      from mtl_material_transactions_temp mmtt,wms_dispatched_tasks wdt
	      where mmtt.transaction_temp_id = wdt.transaction_temp_id
	      and wdt.status = 4
	      and mmtt.transfer_lpn_id is not null
		and mmtt.move_order_line_id = l_line_id
		and rownum = 1;
	 EXCEPTION
	    When No_Data_Found Then
	       l_loaded_lpn_exists := 0;
	    When OTHERS then
	       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	 END;
      END IF; -- ( l_wms_org_flag ) THEN


      IF l_loaded_lpn_exists = 1 then

	Update MTL_TXN_REQUEST_LINES
	set    line_status = 9,
	last_updated_by = fnd_global.user_id,
	last_update_login = fnd_global.login_id,
	last_update_date = sysdate,
        status_date = SYSDATE --bug 5053725
	where line_id = l_line_id;

      else /*bug fix3524130 ends*/
       Begin
          Delete MTL_MATERIAL_TRANSACTIONS_TEMP
          Where
                 Move_Order_Line_Id = l_line_id;
       Exception
	  when NO_DATA_FOUND then
              Null;
          when OTHERS then
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END;


       -- Updating the who columns for bug 3277406
       Update MTL_TXN_REQUEST_LINES
       set    line_status = 5,
       last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.login_id,
       last_update_date = sysdate,
       status_date = SYSDATE --bug 5053725
       where
             line_id = l_line_id;
      end if;

      x_return_status := l_return_status;


 -- Std check  of p_commit
	if FND_API.To_Boolean( p_commit ) then
		COMMIT WORK;
	end if;

 -- Call to get msg coount and data
	FND_MSG_PUB.Count_And_Get(
		p_count		=>  x_msg_count,
		p_data		=>  x_msg_data    ) ;

 Exception
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data    ) ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data    ) ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Close line');
      END IF;
	    FND_MSG_PUB.Count_And_Get(
		      p_count		=>  x_msg_count,
		      p_data		=>  x_msg_data    ) ;
 END CLOSE_LINE;


END INV_MO_Admin_Pub;

/
