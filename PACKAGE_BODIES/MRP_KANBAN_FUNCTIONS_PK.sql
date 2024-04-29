--------------------------------------------------------
--  DDL for Package Body MRP_KANBAN_FUNCTIONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_KANBAN_FUNCTIONS_PK" AS
    /* $Header: MRPPKANB.pls 115.7 2003/05/30 10:12:01 nrajpal ship $ */

PROCEDURE UPDATE_PULL_SEQUENCES
       (x_return_status                 OUT   NOCOPY VARCHAR2,
	x_msg_count			OUT   NOCOPY NUMBER,
	x_msg_data			OUT   NOCOPY VARCHAR2,
        p_pull_sequence_id              IN      NUMBER,
        p_organization_id               IN      NUMBER,
        p_kanban_plan_id                IN      NUMBER,
        p_inventory_item_id             IN      NUMBER,
        p_subinventory_name             IN      VARCHAR2,
        p_locator_id                    IN      NUMBER,
	p_kanban_size			IN	NUMBER,
	p_number_of_cards		IN	NUMBER,
        p_source_type                   IN      NUMBER := FND_API.G_MISS_NUM,
        p_source_organization_id        IN      NUMBER := FND_API.G_MISS_NUM,
        p_source_subinventory           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
        p_source_locator_id             IN      NUMBER := FND_API.G_MISS_NUM,
        p_line_id                       IN      NUMBER := FND_API.G_MISS_NUM,
        p_supplier_id                   IN      NUMBER := FND_API.G_MISS_NUM,
        p_supplier_site_id              IN      NUMBER := FND_API.G_MISS_NUM,
        p_calculate_kanban_flag         IN      NUMBER := FND_API.G_MISS_NUM,
        p_replenishment_lead_time       IN      NUMBER := FND_API.G_MISS_NUM,
        p_release_kanban_flag		IN      NUMBER := FND_API.G_MISS_NUM,
        p_minimum_order_quantity	IN      NUMBER := FND_API.G_MISS_NUM,
        p_fixed_lot_multiplier		IN      NUMBER := FND_API.G_MISS_NUM,
        p_safety_stock_days		IN      NUMBER := FND_API.G_MISS_NUM) IS

  l_pull_sequence_rec			INV_Kanban_PVT.pull_sequence_rec_type;
  l_return_status			VARCHAR2(1);
BEGIN

  l_pull_sequence_rec.pull_sequence_id := p_pull_sequence_id;
  l_pull_sequence_rec.organization_id := p_organization_id;
  l_pull_sequence_rec.kanban_plan_id := p_kanban_plan_id;
  l_pull_sequence_rec.inventory_item_id := p_inventory_item_id;
  l_pull_sequence_rec.subinventory_name := p_subinventory_name;
  l_pull_sequence_rec.locator_id := p_locator_id;
  l_pull_sequence_rec.kanban_size := p_kanban_size;
  l_pull_sequence_rec.number_of_cards := p_number_of_cards;

  -- If source type is passed as -1 then only update size and number
  -- information.  Set values to default.
  IF (p_source_type = -1) THEN
    l_pull_sequence_rec.source_type := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.source_organization_id := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.source_subinventory := FND_API.G_MISS_CHAR;
    l_pull_sequence_rec.source_locator_id := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.wip_line_id := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.supplier_id := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.supplier_site_id := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.calculate_kanban_flag := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.replenishment_lead_time := FND_API.G_MISS_NUM;

    l_pull_sequence_rec.release_kanban_flag := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.minimum_order_quantity := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.fixed_lot_multiplier := FND_API.G_MISS_NUM;
    l_pull_sequence_rec.safety_stock_days := FND_API.G_MISS_NUM;
  ELSE
    l_pull_sequence_rec.source_type := p_source_type;
    l_pull_sequence_rec.source_organization_id := p_source_organization_id;
    l_pull_sequence_rec.source_subinventory := p_source_subinventory;
    l_pull_sequence_rec.source_locator_id := p_source_locator_id;
    l_pull_sequence_rec.wip_line_id := p_line_id;
    l_pull_sequence_rec.supplier_id := p_supplier_id;
    l_pull_sequence_rec.supplier_site_id := p_supplier_site_id;
    l_pull_sequence_rec.calculate_kanban_flag := p_calculate_kanban_flag;
    l_pull_sequence_rec.replenishment_lead_time := p_replenishment_lead_time;

    l_pull_sequence_rec.release_kanban_flag := p_release_kanban_flag;
    l_pull_sequence_rec.minimum_order_quantity := p_minimum_order_quantity;
    l_pull_sequence_rec.fixed_lot_multiplier := p_fixed_lot_multiplier;
    l_pull_sequence_rec.safety_stock_days := p_safety_stock_days;
  END IF;


  INV_Kanban_PVT.update_pull_sequence(l_return_status,
					l_pull_sequence_rec);

  x_return_status := l_return_status;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    commit work;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );
    WHEN OTHERS THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );

END UPDATE_PULL_SEQUENCES;

PROCEDURE DELETE_PULL_SEQUENCES
       (x_return_status        	        OUT   NOCOPY  VARCHAR2,
	x_msg_count			OUT   NOCOPY	NUMBER,
	x_msg_data			OUT   NOCOPY	VARCHAR2,
        p_kanban_plan_id		IN      NUMBER) IS
  l_return_status	VARCHAR2(1);
BEGIN
  INV_Kanban_PVT.delete_pull_sequence(l_return_status,
					p_kanban_plan_id);
  x_return_status := l_return_status;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );
    WHEN OTHERS THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );

END DELETE_PULL_SEQUENCES;


PROCEDURE INSERT_PULL_SEQUENCES (
	x_return_status		OUT	NOCOPY  VARCHAR2,
	x_msg_count		OUT   	NOCOPY  NUMBER,
	x_msg_data		OUT    	NOCOPY  VARCHAR2,
        p_plan_pull_sequence_id	IN	NUMBER ) IS
  l_return_status	VARCHAR2(1);
  l_Pull_Sequence_Rec  	INV_Kanban_PVT.Pull_Sequence_Rec_Type;

BEGIN
	  l_pull_sequence_rec := INV_PullSequence_PKG.Query_Row(p_plan_pull_sequence_id);
	  l_pull_sequence_rec.pull_sequence_id := NULL;
	  l_pull_sequence_rec.kanban_plan_id :=-1;

    	  INV_Kanban_PVT.Insert_Pull_Sequence(l_return_status,l_pull_sequence_rec);

	  x_return_status := l_return_status;

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSE
	    commit work;
	  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );
    WHEN OTHERS THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );
End INSERT_PULL_SEQUENCES;

PROCEDURE UPDATE_AND_PRINT_KANBANS (
        x_return_status                 OUT   NOCOPY  VARCHAR2,
        x_msg_count                     OUT   NOCOPY  NUMBER,
        x_msg_data                      OUT   NOCOPY  VARCHAR2,
        p_query_id                      IN      NUMBER,
        p_update_flag                   IN      VARCHAR2 ) IS

l_pull_seq_id		NUMBER;
l_counter		NUMBER;
l_return_status		VARCHAR2(1);
l_pull_seq_tbl		INV_Kanban_PVT.Pull_sequence_Id_Tbl_Type;
l_operation_tbl		INV_Kanban_PVT.operation_tbl_type;

l_update		constant number := 0;
l_insert		constant number := 1;
l_delplan		constant number :=2;
l_delplanprod		constant number :=3;
l_delplanprodcards	constant number :=4;
l_flag			number :=0;		/*For the operation being performed*/
l_prod_pull_Sequence_id mtl_kanban_pull_sequences.pull_sequence_id%TYPE;

Cursor cur_pull_seq is
SELECT number1,nvl(number2,l_update),nvl(number3,0)
FROM   mrp_form_query
WHERE  query_id = p_query_id;

BEGIN

  OPEN cur_pull_seq;
  l_counter := 0;

  -- load up the pull_seq_tbl to be passed to the INV API
  WHILE TRUE LOOP

	    FETCH cur_pull_seq
	    INTO  l_pull_seq_id,l_flag,l_prod_pull_Sequence_id;

	    EXIT WHEN cur_pull_seq%NOTFOUND;

	    if(( l_flag = l_update)  or (l_flag=l_insert)) then
		    l_counter := l_counter + 1;
		    l_pull_seq_tbl(l_counter) := l_pull_seq_id;
		    if( l_flag = l_update) then
			    l_operation_tbl(l_counter) :=l_update;
		    else
			    l_operation_tbl(l_counter) :=l_insert;
		    end if;
	    else
		    if(l_flag=l_delplanprodcards) then	 --Delete cards
			DELETE
			FROM 	MTL_KANBAN_CARDS
			WHERE	pull_sequence_id =  l_prod_pull_sequence_id;
		    end if;
		    if( (l_flag=l_delplanprodcards ) or ( l_flag = l_delplanprod) ) then  -- Delete Production
				INV_pullsequence_PKG.delete_row(l_return_status,l_prod_pull_sequence_id);
				IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				    RAISE FND_API.G_EXC_ERROR;
				ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

		    end if;
	--    	    Delete planning pull sequence

		    INV_pullsequence_pkg.delete_row(l_return_status,l_pull_seq_id);
		    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			    RAISE FND_API.G_EXC_ERROR;
		    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		    END IF;
		    commit;	--The above procedure does not do a commit ,so we add it here
	    end if;

  END LOOP;

  -- call the INV API that updates/inserts
  INV_Kanban_PVT.Update_Pull_sequence_Tbl (
	l_return_status,
 	l_pull_seq_tbl,
	p_update_flag,
	l_operation_tbl);

  x_return_status := l_return_status;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    DELETE FROM mrp_form_query
    WHERE query_id = p_query_id;

    COMMIT WORK;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );
    WHEN OTHERS THEN
      FND_MSG_PUB.count_and_get
	(p_count	=> 	x_msg_count,
	 p_data		=>	x_msg_data );

END UPDATE_AND_PRINT_KANBANS;

END MRP_KANBAN_FUNCTIONS_PK;

/
