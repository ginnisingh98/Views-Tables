--------------------------------------------------------
--  DDL for Package Body INV_RMA_SERIAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RMA_SERIAL_PVT" AS
/* $Header: INVRMASB.pls 120.6 2006/06/02 05:59:02 sgumaste ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_RMA_SERIAL_PVT';

--
--Return values for API
--1) x_return_status = S, x_errorcode = 0
--   Serial numbers were populated in temp table
--2) x_return_status = E, x_errorcode = 1
--   No serials were found in oe_lot_serial_numbers
--3) x_return_status = E, x_errorcode > 100
--   There was some problem with the serial numbers entered
--4) x_return_status = U
--   Unexpected error

procedure populate_temp_table(
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 DEFAULT FND_API.G_FALSE ,
   p_commit                     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level           IN   NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2,
   x_errorcode                  OUT  NOCOPY NUMBER,

   p_rma_line_id                IN   NUMBER,
   p_org_id                     IN   NUMBER,
   p_item_id                    IN   NUMBER) IS

   l_api_version CONSTANT NUMBER := 0.9;
   l_api_name CONSTANT VARCHAR2(30) := 'populate_temp_table';

   l_orig_line_id NUMBER;
   l_split_from_line_id NUMBER;
   l_line_set_id NUMBER;
   l_counter NUMBER;
   l_qty NUMBER;
   l_length NUMBER;
   l_number_part NUMBER;
   l_err NUMBER;
   l_padded_length NUMBER;
   l_count NUMBER;
   l_temp_count NUMBER := 0;

-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number VARCHAR2(80);
   l_fm_serial_number VARCHAR2(30);
   l_to_serial_number VARCHAR2(30);
   l_prefix VARCHAR2(30); -- Increased the field width to 30 to match with the return value X_PREFIX
                          -- from mtl_serial_check.inv_serial_info for Bug 4312849
   l_fm_num VARCHAR2(30); -- Increased the field width to 30
   l_to_num VARCHAR2(30); -- Increased the field width to 30
   l_serial_number VARCHAR2(30);

   CURSOR oe_lot_serials(p_line_id IN NUMBER) IS
   SELECT lot_number, from_serial_number, to_serial_number
   FROM   oe_lot_serial_numbers
   WHERE  line_id = p_line_id;

BEGIN

   -- Standard Call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version
     , p_api_version
     , l_api_name
     , G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to true
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   -- Initialisize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_errorcode := 0;
   INV_RMA_SERIAL_PVT.g_return_status := x_return_status; --3572112
   INV_RMA_SERIAL_PVT.g_error_code := x_errorcode; --3572112
   INV_RMA_SERIAL_PVT.g_rma_line_id := p_rma_line_id; --3572112
   --Bug 3363907
   --We will now check if serials already exist in the temp
   --table. Only if the serials are not in temp table will
   --we continue, else we will return success.

   select count(*)
   into   l_temp_count
   from   mtl_rma_serial_temp
   where  line_id = p_rma_line_id;

   IF l_temp_count = 0 THEN

   	--API BODY

   	--Get the line id from oe_order_lines_all
   	--Logic Used
   	--1) Normal Case
   	--   split_from_line_id is null in oe_order_lines_all
   	--   use line_id to join to oe_lot_serial_numbers.
   	--2) Split Case
   	--   split_from_line_id is not null in oe_order_lines_all
   	--   get line_set_id from oe_order_lines_all to join to
   	--   oe_lot_serial_numbers.

       /* Commented the below code and  added the new select statement to get
        * correct value in l_orig_line_id i.e to get always line_id of parent RMA line
	* from which subsequent lines got split.  For bug  5144099 */
        /*
   	SELECT split_from_line_id, line_set_id
   	INTO   l_split_from_line_id, l_line_set_id
   	FROM   oe_order_lines_all
   	WHERE  line_id = p_rma_line_id;

   	IF l_split_from_line_id IS NULL THEN

     		--1) Normal Case
       		l_orig_line_id := p_rma_line_id;

   	ELSIF l_split_from_line_id IS NOT NULL THEN

     		--2) Split Case
       		l_orig_line_id := l_split_from_line_id;
   	END IF;
        */

	SELECT min(line_id)
   	INTO   l_orig_line_id
   	FROM   oe_order_lines_all
	START  WITH line_id = p_rma_line_id
	CONNECT BY PRIOR split_from_line_id = line_id;

	 /* End of fix for bug 5144099*/

   	--Check if there are rows in the oe_lot_serial_numbers
   	--table before opening cursor
   	SELECT count(*)
   	INTO   l_count
   	FROM   oe_lot_serial_numbers
   	WHERE  line_id = l_orig_line_id;

   	--IF count=0 then set x_errorcode=1
   	--and throw G_EXC_ERROR.

   	IF (l_count = 0) THEN
      		x_errorcode := 1;
		INV_RMA_SERIAL_PVT.g_error_code := x_errorcode; --3572112
      		RAISE FND_API.G_EXC_ERROR;
   	ELSIF (l_count > 0) THEN

		OPEN oe_lot_serials(l_orig_line_id);
   		LOOP
			FETCH oe_lot_serials
			INTO  l_lot_number, l_fm_serial_number, l_to_serial_number;

			EXIT WHEN oe_lot_serials%NOTFOUND;


   			IF NOT mtl_serial_check.inv_serial_info(
				P_FROM_SERIAL_NUMBER => l_fm_serial_number,
				P_TO_SERIAL_NUMBER   => l_to_serial_number,
				X_PREFIX	     => l_prefix,
				X_QUANTITY	     => l_qty,
				X_FROM_NUMBER	     => l_fm_num,
				X_TO_NUMBER	     => l_to_num,
        			X_ERRORCODE          => l_err) THEN

	     			BEGIN
					x_errorcode := to_number(l_err);
					INV_RMA_SERIAL_PVT.g_error_code := x_errorcode; --3572112
					RAISE FND_API.G_EXC_ERROR;
	     			END;
   			END IF;

	   		l_number_part := TO_NUMBER(l_fm_num);
	   		l_counter     := 1;
	   		l_length      := LENGTH(l_fm_serial_number);

   			--In the following loop we generat the serial
	   		--one at a time and insert into temp table.
                        --Bug#4411411: l_number_part will be null if the serial has no numeric part.
                        --             Need to do NVL for the length(l_number_part). Prefix will
                        --             be null when serial has ONLY numbers or if serial ends in alphabet.
                        --             Need to do NVL for l_prefix for this case.
                        WHILE (l_counter <= l_qty) LOOP
                         l_padded_length := l_length - nvl(length(l_number_part),0);
                         l_serial_number := rpad(nvl(l_prefix,0),l_padded_length, '0')||l_number_part;
                         l_number_part := nvl(l_number_part,0) + 1;
                         l_counter :=  l_counter + 1;

				--Insert serial into temp table

				INSERT INTO mtl_rma_serial_temp
				(organization_id,
		 		inventory_item_id,
		 		lot_number,
   		 		serial_number,
  	 			line_id) VALUES
				(p_org_id,
		 		p_item_id,
	 			l_lot_number,
		 		l_serial_number,
		 		p_rma_line_id);

   			END LOOP;
		END LOOP;
   	END IF;
   	x_return_status := FND_API.G_RET_STS_SUCCESS;
	INV_RMA_SERIAL_PVT.g_return_status := x_return_status;

    ELSE IF (l_temp_count > 0) THEN
	--Serials are already populated in the temp table
        --return error_code = 0 and success.
	x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_errorcode := 0;
	INV_RMA_SERIAL_PVT.g_return_status := x_return_status; --3572112
	INV_RMA_SERIAL_PVT.g_error_code := x_errorcode; --3572112
    END IF;

   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	INV_RMA_SERIAL_PVT.g_return_status := x_return_status; --3572112

   WHEN OTHERS THEN
   	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	INV_RMA_SERIAL_PVT.g_return_status := x_return_status; --3572112

END populate_temp_table;
-- Added the below function for bug 3572112
function validate_serial_required(p_rma_line_id   IN  NUMBER) return NUMBER IS
BEGIN
  IF ( INV_RMA_SERIAL_PVT.g_return_status = 'S' AND
       INV_RMA_SERIAL_PVT.g_error_code = 0 AND
       INV_RMA_SERIAL_PVT.g_rma_line_id = p_rma_line_id ) THEN
       RETURN 0;
  ELSE
       RETURN 1;
  END IF;
END validate_serial_required;

END INV_RMA_SERIAL_PVT;

/
