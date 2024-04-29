--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_PVT" AS
/* $Header: OEXVBSOB.pls 120.0.12010000.3 2008/11/30 00:05:38 smusanna ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blanket_PVT';
g_header_id                   NUMBER;
g_blaket_header_rec            oe_blanket_pub.header_Rec_type ;

/*----------------------------------------------------------------------
PROCEDURE Header
-----------------------------------------------------------------------*/

PROCEDURE Header
(   p_control_rec                   IN  OE_BLANKET_PUB.Control_Rec_Type
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_x_header_rec         IN OUT NOCOPY OE_Blanket_PUB.header_Rec_Type
,   p_x_old_header_rec     IN OUT NOCOPY OE_Blanket_PUB.header_Rec_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
)
IS
l_old_header_rec OE_Blanket_PUB.header_Rec_Type;
l_return_status varchar2(1);
l_sec_result NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
                   x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSIDE BLANKET HEADER' ,1 ) ;
        END IF;

	-- Query Old Record

		IF p_x_header_rec.operation <> oe_globals.g_opr_create THEN
		oe_blanket_util.query_header( p_header_id =>
					p_x_header_rec.header_id,
		                          x_header_rec => p_x_old_header_rec,
                                          x_return_status => l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
              END IF;
				l_old_header_rec := p_x_old_header_rec;
		END IF;

    OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'BLANKET_HEADER'
  	,p_entity_id         		=> p_x_header_rec.header_id
    	,p_header_id         		=> p_x_header_rec.header_id
    	,p_line_id           		=> null
    	,p_orig_sys_document_ref	=> null
    	,p_orig_sys_document_line_ref	=> null
        ,p_change_sequence              => null
    	,p_source_document_id		=> null
    	,p_source_document_line_id	=> null
	,p_order_source_id            => null
	,p_source_document_type_id    => null);

   -- Check security
   IF    OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    AND  p_control_rec.check_security
    AND (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
         OR p_x_header_rec.operation = OE_GLOBALS.G_OPR_DELETE)  -- hashraf pack J
   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK BLANKET HEADER ATTRIBUTES SECURITY', 1 ) ;
        END IF;
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Blanket_Header_Security.Attributes
                (p_header_rec   	=> p_x_header_rec
                , p_old_header_rec	=> l_old_header_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;


	-- Validate User passed attributes


		IF p_control_rec.validate_attributes THEN
          oe_debug_pub.add(  ' Validate Blanket Attribute ' ,1);
	oe_blanket_util.validate_attributes( p_x_header_Rec => p_x_header_rec,
					  p_old_header_rec => l_old_header_rec,
					  p_validation_level => p_validation_level,
					  x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;
               END IF;


       --   Default Attributes if the operation is create

		IF p_x_header_rec.operation = oe_globals.g_opr_create THEN
			oe_blanket_util.default_attributes (
				 p_x_header_Rec => p_x_header_rec,
                                 x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

		END IF;



        -- Validate entity security
   IF    OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    AND  p_control_rec.check_security
    AND (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
         OR p_x_header_rec.operation = OE_GLOBALS.G_OPR_DELETE) -- hashraf Pack J
   THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK BLANKET HEADER ENTITY SECURITY' ) ;
        END IF;
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Blanket_Header_Security.Entity
                (p_header_rec   	=> p_x_header_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;


	-- Validate entity and check required fields

		IF p_control_rec.validate_entity  THEN
	oe_blanket_util.Validate_entity ( p_header_rec => p_x_header_rec,
		             p_old_header_rec => l_old_header_rec,
		             x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;
		END IF;


         -- Write the record into database

		IF p_control_rec.write_to_db AND
                   x_return_status = FND_API.G_RET_STS_SUCCESS THEN

		IF p_x_header_rec.operation = oe_globals.g_opr_update THEN
 		  oe_blanket_util.update_row (p_header_rec => p_x_header_rec,
                                    x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

		ELSIF p_x_header_rec.operation = oe_globals.g_opr_create THEN
		  oe_blanket_util.insert_row (p_header_rec => p_x_header_rec,
                                    x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

-- hashraf start of pack J
		ELSIF p_x_header_rec.operation = oe_globals.g_opr_delete THEN
		  oe_blanket_util.delete_row (p_header_id => p_x_header_rec.header_id,
                                    x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

-- hashraf end of Pack J

		END IF;

		END IF;

        OE_MSG_PUB.reset_msg_context('BLANKET_HEADER');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
    if l_debug_level > 0 then
          oe_debug_pub.add('delete request1',2);
    end if;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;
        END IF;

        OE_MSG_PUB.reset_msg_context('BLANKET_HEADER');
        p_x_header_rec.return_status  := FND_API.G_RET_STS_ERROR;
	x_return_status 	:= FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          if l_debug_level > 0 then
            oe_debug_pub.add('delete request1',2);
          end if;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;
        END IF;

        OE_MSG_PUB.reset_msg_context('BLANKET_HEADER');
        p_x_header_rec.return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
	x_return_status 		 := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          if l_debug_level > 0 then
            oe_debug_pub.add('delete request1',2);
          end if;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;
        END IF;

        OE_MSG_PUB.reset_msg_context('BLANKET_HEADER');
        p_x_header_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
	 x_return_status 		 := FND_API.G_RET_STS_UNEXP_ERROR;
END Header;



/*---------------------------------------------------------------------- */

PROCEDURE Lines
(   p_control_rec                   IN  oe_blanket_pub.Control_Rec_Type
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_x_line_tbl   IN OUT NOCOPY  OE_Blanket_PUB.line_tbl_Type
,   p_x_old_line_tbl IN OUT NOCOPY OE_Blanket_PUB.line_tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
)
IS
l_old_line_rec  OE_Blanket_PUB.line_rec_Type;
l_line_rec  OE_Blanket_PUB.line_rec_Type;
l_return_status varchar2(1);
I number;
l_sec_result NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
                   x_return_status := FND_API.G_RET_STS_SUCCESS;

		I := p_x_line_tbl.first;
		WHILE I is not null
		LOOP
-- Loop for each line in the table

-- Query the old  record if exists

			l_line_rec := p_x_line_tbl(I);

		IF l_line_rec.operation <> oe_globals.g_opr_create THEN
	l_old_line_rec :=oe_blanket_util.query_row(p_line_id =>
				l_line_rec.line_id );
			p_x_old_line_tbl(I) := l_old_line_rec;
		END IF;

    OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'BLANKET_LINE'
  	,p_entity_id         		=> l_line_rec.line_id
    	,p_header_id         		=> l_line_rec.header_id
    	,p_line_id           		=> l_line_rec.line_id
    	,p_orig_sys_document_ref	=> null
    	,p_orig_sys_document_line_ref	=> null
        ,p_change_sequence              => null
    	,p_source_document_id		=> null
    	,p_source_document_line_id	=> null
	,p_order_source_id            => null
	,p_source_document_type_id    => null);

-- Validate user passed attributes

			IF p_control_rec.validate_attributes THEN
		oe_blanket_util.validate_attributes( p_x_line_Rec => l_line_rec,
					  p_old_line_rec => l_old_line_rec,
					  p_validation_level => p_validation_level,
					  x_return_status => l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           x_return_status := l_return_status;
                         END IF;
               		END IF;

   -- Check security attributes
   IF    OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    AND  p_control_rec.check_security
    AND (l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
OR l_line_rec.operation = OE_GLOBALS.G_OPR_DELETE) -- hashraf pack J
   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK BLANKET LINE ATTRIBUTES SECURITY' ) ;
        END IF;
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Blanket_Line_Security.Attributes
                (p_line_rec   	=> l_line_rec
                , p_old_line_rec	=> l_old_line_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

       --   Default Attributes if the operation is create


		IF l_line_rec.operation = oe_globals.g_opr_create
			  THEN
			oe_blanket_util.default_attributes (
				 p_x_line_rec => l_line_rec,
                               p_default_from_header => p_control_rec.default_from_header,
                              x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

		END IF;


   -- Check security attributes
   IF    OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    AND  p_control_rec.check_security
    AND (l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
         OR l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
OR l_line_rec.operation = OE_GLOBALS.G_OPR_DELETE) -- hashraf pack J
   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CHECK BLANKET LINE ENTITY SECURITY' ) ;
        END IF;
        -- check if this operation is allowed
        -- on all the changed attributes
           OE_Blanket_Line_Security.Entity
                (p_line_rec   	=> l_line_rec
                , x_result      	=> l_sec_result
                , x_return_status 	=> l_return_status
                );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

           IF l_sec_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

    END IF;

	-- Vaildate entity and required fields


		IF p_control_rec.validate_entity  THEN

		oe_blanket_util.Validate_entity ( p_line_rec => l_line_rec,
		             p_old_line_rec => l_old_line_rec,
		             x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

		END IF;


	-- Write the records into database

		IF p_control_rec.write_to_db  AND
                   x_return_status = FND_API.G_RET_STS_SUCCESS THEN

		IF l_line_rec.operation = oe_globals.g_opr_update THEN
	              oe_blanket_util.update_row (p_line_rec => l_line_rec,
                                  x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

		ELSIF l_line_rec.operation = oe_globals.g_opr_create THEN


	oe_blanket_util.insert_row (p_line_rec => l_line_rec,
                                  x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;

-- hashraf start of Pack J
		ELSIF l_line_rec.operation = oe_globals.g_opr_delete THEN


	oe_blanket_util.delete_row (p_line_id => l_line_rec.line_id,
                                  x_return_status => l_return_status);
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     x_return_status := l_return_status;
                  END IF;
-- hashraf end of Pack J

		END IF;


		END IF;
			l_line_rec.return_status := x_return_status;
			p_x_line_tbl(I) := l_line_rec;

                OE_MSG_PUB.reset_msg_context('BLANKET_LINE');

		--  Process next Line

			I := p_x_line_tbl.next(I);
	END LOOP;



NULL;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          if l_debug_level > 0 then
            oe_debug_pub.add('delete request1',2);
          end if;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
              END IF;

        END IF;

        OE_MSG_PUB.reset_msg_context('BLANKET_LINE');
    x_return_status  := FND_API.G_RET_STS_ERROR;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          if l_debug_level > 0 then
            oe_debug_pub.add('delete request1',2);
          end if;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
              END IF;

        END IF;

        OE_MSG_PUB.reset_msg_context('BLANKET_LINE');
	x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;


  WHEN OTHERS THEN
        IF NOT (OE_GLOBALS.G_UI_FLAG) THEN
          if l_debug_level > 0 then
            oe_debug_pub.add('delete request1',2);
          end if;
          OE_Delayed_Requests_Pvt.Clear_Request
                    (x_return_status => l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 x_return_status := l_return_status;
              END IF;

        END IF;

        OE_MSG_PUB.reset_msg_context('BLANKET_LINE');
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;


END Lines;


/*----------------------------------------------------------------
--  Start of Comments
--  API name    Process_Blanket
--  Type        Private
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
----------------------------------------------------------------*/
PROCEDURE Process_Blanket
(   p_org_id                        IN  NUMBER := NULL --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER := 1.0
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_rec            IN  oe_blanket_pub.header_Rec_type :=
                                        oe_blanket_pub.G_MISS_header_rec
,   p_line_tbl              IN  oe_blanket_pub.line_tbl_Type :=
                                        oe_blanket_pub.G_MISS_line_tbl
,   p_control_rec                   IN  oe_blanket_pub.Control_rec_type :=
                                oe_blanket_pub.G_MISS_CONTROL_REC
,   x_header_rec           OUT NOCOPY oe_blanket_pub.header_Rec_type
,   x_line_tbl             OUT NOCOPY oe_blanket_pub.line_tbl_Type
)
IS
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Blanket';
l_return_status               VARCHAR2(1);
l_old_header_rec           OE_Blanket_PUB.header_Rec_Type;
l_header_rec           OE_Blanket_PUB.header_Rec_Type := p_header_rec;
l_line_rec            OE_Blanket_PUB.Line_Rec_Type;
l_line_tbl            OE_Blanket_PUB.line_tbl_Type := p_line_tbl;
l_old_line_rec        OE_Blanket_PUB.Line_rec_Type;
l_old_line_tbl        OE_Blanket_PUB.line_tbl_Type;
I number;

--MOAC
l_org_id                      NUMBER;
l_operating_unit              VARCHAR2(240);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
NULL;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
	G_BATCH_MODE := TRUE;

	   SAVEPOINT Process_Blanket;


    if l_debug_level > 0 then
      oe_debug_pub.add('Entering OE_BLANKET_PVT.PROCESS_BLANKET', 1);
    end if;
    --  Standard call to check for call compatibility


    -------------------------------------------------------
    -- Process Blanket Header
    -------------------------------------------------------
    IF p_header_rec.operation IS NOT NULL THEN

      Header
      (   p_control_rec                 => p_control_rec
      ,   p_validation_level            => p_validation_level
      ,   p_x_header_rec           => l_header_Rec
      ,   p_x_old_header_rec        => l_old_header_Rec
      ,   x_return_status               => l_return_status
      );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
      END IF;
	x_header_rec := l_header_rec;

END IF;


    -------------------------------------------------------
    -- Process Blanket Lines
    -------------------------------------------------------


    IF l_line_tbl.COUNT > 0 THEN

    if l_debug_level > 0 then
      oe_debug_pub.add('before lines processing', 2);
    end if;
		I := l_line_tbl.first;

		While I is not null
		Loop
			IF l_line_tbl(I).operation = oe_globals.g_opr_create AND
				l_line_tbl(I).header_id IS NULL THEN
				l_line_tbl(I).header_id := l_header_rec.header_id;
			END IF;


		I := l_line_tbl.next(I);
		End loop;

    Lines
    (   p_control_rec                 => p_control_rec
    ,   p_validation_level            => p_validation_level
    ,   p_x_line_tbl          => l_line_tbl
    ,   p_x_old_line_tbl      => l_old_line_tbl
    ,   x_return_status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

         RAISE FND_API.G_EXC_ERROR;
    END IF;
    if l_debug_level > 0 then
      oe_debug_pub.add('after lines processing', 2);
    end if;
    END IF;
		x_line_tbl := l_line_tbl;

-- Process Object level requests

	oe_blanket_util.Process_Object( x_return_status => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;


    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


    if l_debug_level > 0 then
      oe_debug_pub.ADD('Exiting OE_BLANKET_PUB.PROCESS_BLANKET', 1);
    end if;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        if l_debug_level > 0 then
          oe_debug_pub.add('BO: Exiting Process Blanket with Error', 2);
        end if;
        x_return_status := FND_API.G_RET_STS_ERROR;

  	      ROLLBACK TO SAVEPOINT Process_blanket;


        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        if l_debug_level > 0 then
         oe_debug_pub.add('bO: Exiting Process Blanket with Unexpected Error', 2);
        end if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	      ROLLBACK TO SAVEPOINT Process_Blanket;


        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
        if l_debug_level > 0 then
          oe_debug_pub.add('bO: Exiting Process Blanket with others Error', 2);
        end if;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     	ROLLBACK TO SAVEPOINT Process_Blanket;


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Blanket'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Blanket;

END OE_Blanket_PVT;

/
