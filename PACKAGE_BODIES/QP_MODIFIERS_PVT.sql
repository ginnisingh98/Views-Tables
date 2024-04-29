--------------------------------------------------------
--  DDL for Package Body QP_MODIFIERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIERS_PVT" AS
/* $Header: QPXVMLSB.pls 120.7 2006/03/02 06:35:38 prarasto ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Modifiers_PVT';


--- added by svdeshmu

PROCEDURE  Get_Parent_List_Line_Id
(  p_child_list_line_id IN NUMBER
 , x_parent_list_line_id out NOCOPY /* file.sql.39 change */ number
 , x_list_line_type_code out NOCOPY /* file.sql.39 change */ varchar2
 , x_status  out NOCOPY /* file.sql.39 change */ varchar2
 ) IS

 cursor c_parent_list_line_id(p_child_list_line_id in number) is
  SELECT from_rltd_modifier_id
  FROM   QP_RLTD_MODIFIERS
  WHERE  to_rltd_modifier_id = p_child_list_line_id;

 cursor c_parent_list_line_type_code(p_parent_list_line_id in number) is
  SELECT list_line_type_code
  FROM   QP_LIST_LINES
  WHERE list_line_id = p_parent_list_line_id;


  BEGIN

    OPEN  c_parent_list_line_id(p_child_list_line_id);
    FETCH c_parent_list_line_id into x_parent_list_line_id;

    /* Added for 2634375 */
    IF c_parent_list_line_id%notfound then
        x_status :='F';
    ELSE
        x_status :='T';
    END IF;

    CLOSE c_parent_list_line_id;

    --Commented out for 2634375
/*
    IF SQL%NOTFOUND THEN

         x_status := 'F';
    ELSE

         x_status := 'T';
*/
   IF x_status='T' then  --2634375
         OPEN c_parent_list_line_type_code(x_parent_list_line_id);
         FETCH c_parent_list_line_type_code into x_list_line_type_code;
         CLOSE c_parent_list_line_type_code;


    END IF;

 EXCEPTION

	 WHEN NO_DATA_FOUND then

		x_status := 'F';

 END Get_Parent_List_Line_Id;


--- end of additions by svdeshmu


--  Modifier_List

PROCEDURE Modifier_List
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_old_MODIFIER_LIST_rec         OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type := p_MODIFIER_LIST_rec;
l_p_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type := p_MODIFIER_LIST_rec;
l_old_MODIFIER_LIST_rec       QP_Modifiers_PUB.Modifier_List_Rec_Type := p_old_MODIFIER_LIST_rec;
BEGIN

    oe_debug_pub.add('BEGIN modifier list in Private');
    --dbms_output.put_line('BEGIN modifier list in Private');

    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_MODIFIER_LIST_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --added for moac for BSA --fix for bug 4748511
    if l_MODIFIER_LIST_rec.operation in (QP_GLOBALS.G_OPR_CREATE, QP_GLOBALS.G_OPR_UPDATE)
    and l_control_rec.called_from_ui = 'N'
    and l_MODIFIER_LIST_rec.list_source_code IS NOT NULL
    and l_MODIFIER_LIST_rec.global_flag = 'N'
    and nvl(QP_SECURITY.security_on, 'N') = 'N' then
      l_MODIFIER_LIST_rec.global_flag := 'Y';
      l_MODIFIER_LIST_rec.org_id := null;
    end if;

    --  Prepare record.

    oe_debug_pub.add('Operation'||l_MODIFIER_LIST_rec.operation);
    --dbms_output.put_line('Operation'||l_MODIFIER_LIST_rec.operation);
    IF l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

    oe_debug_pub.add('Private 01');
    --dbms_output.put_line('Private 01');
        l_MODIFIER_LIST_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_MODIFIER_LIST_rec :=
        QP_Modifier_List_Util.Convert_Miss_To_Null (l_old_MODIFIER_LIST_rec);

    oe_debug_pub.add('Private 02');
    --dbms_output.put_line('Private 02');
    ELSIF l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN
OE_Debug_Pub.add('update on header');
    --dbms_output.put_line('update on header');
        l_MODIFIER_LIST_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_MODIFIER_LIST_rec.list_header_id = FND_API.G_MISS_NUM
        THEN

OE_Debug_Pub.add('query'||to_char(l_modifier_list_rec.list_header_id));
--dbms_output.put_line('query'||to_char(l_modifier_list_rec.list_header_id));
            l_old_MODIFIER_LIST_rec := QP_Modifier_List_Util.Query_Row
            (   p_list_header_id              => l_MODIFIER_LIST_rec.list_header_id
            );

OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
        ELSE

            --  Set missing old record elements to NULL.

            l_old_MODIFIER_LIST_rec :=
            QP_Modifier_List_Util.Convert_Miss_To_Null (l_old_MODIFIER_LIST_rec);

        END IF;

        --  Complete new record from old

        l_MODIFIER_LIST_rec := QP_Modifier_List_Util.Complete_Record
        (   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
        ,   p_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
        );
OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);

    END IF;

    --  Attribute level validation.

    oe_debug_pub.add('Private 03');

    --dbms_output.put_line('just before if');

    IF l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE
    OR    l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

    oe_debug_pub.add('in Private 03');
    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

    oe_debug_pub.add('if Private 03');
        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

    oe_debug_pub.add('2if Private 03');
OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
            QP_Validate_Modifier_List.Attributes
            (   x_return_status               => l_return_status
            ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
            ,   p_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
            );

OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

    oe_debug_pub.add('Private 04');
        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes THEN

OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
       l_p_MODIFIER_LIST_rec := l_MODIFIER_LIST_rec;
        QP_Modifier_List_Util.Clear_Dependent_Attr
        (   p_MODIFIER_LIST_rec           => l_p_MODIFIER_LIST_rec
        ,   p_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
        ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
        );

OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
    END IF;

    oe_debug_pub.add('Private 05');
    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

    oe_debug_pub.add('Private 05');
        l_p_MODIFIER_LIST_rec := l_MODIFIER_LIST_rec;
        QP_Default_Modifier_List.Attributes
        (   p_MODIFIER_LIST_rec           => l_p_MODIFIER_LIST_rec
        ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
        );

    END IF;

    oe_debug_pub.add('Private 05.1');
    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
        l_p_MODIFIER_LIST_rec := l_MODIFIER_LIST_rec;
        QP_Modifier_List_Util.Apply_Attribute_Changes
        (   p_MODIFIER_LIST_rec           => l_p_MODIFIER_LIST_rec
        ,   p_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
        ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
        );

OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Validate_Modifier_List.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
            );

        ELSE

    oe_debug_pub.add('Private 06');
            QP_Validate_Modifier_List.Entity
            (   x_return_status               => l_return_status
            ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
            ,   p_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
            );
OE_Debug_Pub.add('query'||l_modifier_list_rec.version_no);
null;

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    --  Step 4. Write to DB

    oe_debug_pub.add('Private 07');
    IF l_control_rec.write_to_db THEN

        IF l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            FND_MESSAGE.SET_NAME('QP','QP_CANNOT_DELETE_MODIFIER');
            OE_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;
/*
            QP_Modifier_List_Util.Delete_Row
            (   p_list_header_id              => l_MODIFIER_LIST_rec.list_header_id
            );
*/
        ELSE

            --  Get Who Information

            l_MODIFIER_LIST_rec.last_update_date := SYSDATE;
            l_MODIFIER_LIST_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_MODIFIER_LIST_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

OE_Debug_Pub.add('query'||p_modifier_list_rec.version_no);
                QP_Modifier_List_Util.Update_Row (l_MODIFIER_LIST_rec);

            ELSIF l_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                l_MODIFIER_LIST_rec.creation_date := SYSDATE;
                l_MODIFIER_LIST_rec.created_by := FND_GLOBAL.USER_ID;

                QP_Modifier_List_Util.Insert_Row (l_MODIFIER_LIST_rec);

            END IF;

        END IF;

    END IF;

   END IF; -- For Operation create, update or delete


    --  Load OUT parameters

    x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
    x_old_MODIFIER_LIST_rec        := l_old_MODIFIER_LIST_rec;

    oe_debug_pub.add('END modifier list in Private');
    --dbms_output.put_line('END modifier list in Private');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
        x_old_MODIFIER_LIST_rec        := l_old_MODIFIER_LIST_rec;

        oe_debug_pub.add('manoj - value of called_from_ui before delete_reqs_for_deleted_entity = ' || l_control_rec.called_from_ui);
        -- mkarya If process_modifiers has been called from public package, then ONLY call
        -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
		 p_entity_id => l_MODIFIER_LIST_rec.list_header_id,
		 x_return_status => l_return_status );
        end if;

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
        x_old_MODIFIER_LIST_rec        := l_old_MODIFIER_LIST_rec;

        -- mkarya If process_modifiers has been called from public package, then ONLY call
        -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
		 p_entity_id => l_MODIFIER_LIST_rec.list_header_id,
		 x_return_status => l_return_status );
        end if;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modifier_List'
            );
        END IF;

        l_MODIFIER_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
        x_old_MODIFIER_LIST_rec        := l_old_MODIFIER_LIST_rec;

        -- mkarya If process_modifiers has been called from public package, then ONLY call
        -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
		 p_entity_id => l_MODIFIER_LIST_rec.list_header_id,
		 x_return_status => l_return_status );
        end if;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modifier_List;

--  Modifierss

PROCEDURE Modifierss
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_MODIFIERS_tbl                 IN  QP_Modifiers_PUB.Modifiers_Tbl_Type
,   p_old_MODIFIERS_tbl             IN  QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_old_MODIFIERS_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_rltd_modifiers_s            NUMBER;
l_to_rltd_modifier_id         NUMBER;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_p_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_old_MODIFIERS_rec           QP_Modifiers_PUB.Modifiers_Rec_Type;
l_old_MODIFIERS_tbl           QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_product_attribute			varchar2(30) := null;
l_product_attr_value		varchar2(240) := null;
l_pricing_phase_id			number;

BEGIN

    oe_debug_pub.add('BEGIN modifierss in Private');
    --dbms_output.put_line('BEGIN modifierss in Private');
    --  Init local table variables.

    l_MODIFIERS_tbl                := p_MODIFIERS_tbl;
    l_old_MODIFIERS_tbl            := p_old_MODIFIERS_tbl;

    FOR I IN 1..l_MODIFIERS_tbl.COUNT LOOP
    BEGIN

        l_MODIFIERS_rec := l_MODIFIERS_tbl(I);

	--hw
	-- delayed request for changed lines
	if QP_PERF_PVT.enabled = 'Y' then
	if (l_MODIFIERS_rec.operation = OE_GLOBALS.G_OPR_CREATE
		and (l_MODIFIERS_rec.list_line_type_code in ('OID', 'PRG', 'RLTD')
			or l_MODIFIERS_rec.modifier_level_code = 'LINEGROUP'
			or (l_MODIFIERS_rec.rltd_modifier_grp_type = 'BENEFIT'
				and l_MODIFIERS_rec.list_line_type_code = 'DIS'))) then

 		qp_delayed_requests_pvt.log_request(
          	p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
       	  	p_entity_id => l_MODIFIERS_rec.list_line_id,
          	p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
          	p_requesting_entity_id => l_MODIFIERS_rec.list_line_id,
          	p_request_type => QP_GLOBALS.G_UPDATE_CHANGED_LINES_ADD,
       	  	p_param1 => l_MODIFIERS_rec.pricing_phase_id,
       	  	p_param2 => l_MODIFIERS_rec.list_header_id,
          	x_return_status => l_return_status);

	end if;
	end if;

        --  Load local records.

        IF l_old_MODIFIERS_tbl.EXISTS(I) THEN
            l_old_MODIFIERS_rec := l_old_MODIFIERS_tbl(I);
        ELSE
            l_old_MODIFIERS_rec := QP_Modifiers_PUB.G_MISS_MODIFIERS_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_MODIFIERS_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_MODIFIERS_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_MODIFIERS_rec :=
            QP_Modifiers_Util.Convert_Miss_To_Null (l_old_MODIFIERS_rec);

        ELSIF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_MODIFIERS_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_MODIFIERS_rec.list_line_id = FND_API.G_MISS_NUM
            THEN

                l_old_MODIFIERS_rec := QP_Modifiers_Util.Query_Row
                (   p_list_line_id                => l_MODIFIERS_rec.list_line_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_MODIFIERS_rec :=
                QP_Modifiers_Util.Convert_Miss_To_Null (l_old_MODIFIERS_rec);

            END IF;

            --  Complete new record from old

            l_MODIFIERS_rec := QP_Modifiers_Util.Complete_Record
            (   p_MODIFIERS_rec               => l_MODIFIERS_rec
            ,   p_old_MODIFIERS_rec           => l_old_MODIFIERS_rec
            );

        END IF;

        --  Attribute level validation.

    IF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE
    OR    l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Modifiers.Attributes
                (   x_return_status               => l_return_status
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   p_old_MODIFIERS_rec           => l_old_MODIFIERS_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

--dbms_output.put_line('here 1');
            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN
            l_p_MODIFIERS_rec := l_MODIFIERS_rec;
            QP_Modifiers_Util.Clear_Dependent_Attr
            (   p_MODIFIERS_rec               => l_p_MODIFIERS_rec
            ,   p_old_MODIFIERS_rec           => l_old_MODIFIERS_rec
            ,   x_MODIFIERS_rec               => l_MODIFIERS_rec
            );

        END IF;

        --  Default missing attributes

    oe_debug_pub.add('from id = '|| to_char(l_MODIFIERS_rec.from_rltd_modifier_id) );
        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

    oe_debug_pub.add('before default atributeeee');
            l_p_MODIFIERS_rec := l_MODIFIERS_rec;
            QP_Default_Modifiers.Attributes
            (   p_MODIFIERS_rec               => l_p_MODIFIERS_rec
            ,   x_MODIFIERS_rec               => l_MODIFIERS_rec
            );

        END IF;

    oe_debug_pub.add('after from id = '|| to_char(l_MODIFIERS_rec.from_rltd_modifier_id) );
--dbms_output.put_line('here 2');
        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_MODIFIERS_rec := l_MODIFIERS_rec;
            QP_Modifiers_Util.Apply_Attribute_Changes
            (   p_MODIFIERS_rec               => l_p_MODIFIERS_rec
            ,   p_old_MODIFIERS_rec           => l_old_MODIFIERS_rec
            ,   x_MODIFIERS_rec               => l_MODIFIERS_rec
            );

        END IF;

        --  Entity level validation.

    oe_debug_pub.add('after apply from id = '|| to_char(l_MODIFIERS_rec.from_rltd_modifier_id) );
--dbms_output.put_line('here 3');
        IF l_control_rec.validate_entity THEN

            IF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Modifiers.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                );

            ELSE

-- Vivek

		    --dbms_output.put_line('before if');

		   IF ((l_MODIFIERS_rec.modifier_parent_index IS NOT NULL)
		   AND (l_MODIFIERS_rec.modifier_parent_index <> FND_API.G_MISS_NUM)
		   AND l_MODIFIERS_rec.list_line_type_code not in ('PBH', 'OID','PRG')
		   AND l_MODIFIERS_tbl(l_MODIFIERS_rec.modifier_parent_index).list_line_type_code IN ('PBH', 'OID', 'PRG')) THEN

		    --dbms_output.put_line('inside if');
		    oe_debug_pub.add('in if');

		   	l_MODIFIERS_rec.from_rltd_modifier_id :=
			l_MODIFIERS_tbl(l_MODIFIERS_rec.modifier_parent_index).list_line_id;

		        l_MODIFIERS_rec.to_rltd_modifier_id := l_MODIFIERS_rec.list_line_id;

                   ELSIF   l_MODIFIERS_rec.list_line_type_code = 'CIE'
                   THEN

                       l_MODIFIERS_rec.rltd_modifier_grp_type := 'COUPON';
		       l_MODIFIERS_rec.from_rltd_modifier_id := l_MODIFIERS_rec.list_line_id;

			ELSIF l_MODIFIERS_rec.modifier_parent_index IS NULL OR
				l_MODIFIERS_rec.modifier_parent_index = FND_API.G_MISS_NUM THEN
			--added this else clause for CRM requirement bug 1615344

		    --dbms_output.put_line('inside elsif');
			l_MODIFIERS_rec.to_rltd_modifier_id := l_MODIFIERS_rec.list_line_id;
                   END IF;

		    --dbms_output.put_line('after elsif');
-- Vivek

                QP_Validate_Modifiers.Entity
                (   x_return_status               => l_return_status
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   p_old_MODIFIERS_rec           => l_old_MODIFIERS_rec
                );
			 null;

            END IF;

    oe_debug_pub.add('after entity del from id = '|| to_char(l_MODIFIERS_rec.from_rltd_modifier_id) );
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;


        IF l_control_rec.write_to_db THEN
		oe_debug_pub.add('Pre-write modifierss');
           null;
                                  l_p_MODIFIERS_rec := l_MODIFIERS_rec;
				   QP_MODIFIERS_UTIL.PRE_WRITE_PROCESS
					( p_MODIFIERS_rec      => l_p_MODIFIERS_rec
					, p_old_MODIFIERS_rec  => l_old_MODIFIERS_rec
					, x_MODIFIERS_rec      => l_MODIFIERS_rec);
	   END IF;




        --  Step 4. Write to DB
--dbms_output.put_line('here 4');
    oe_debug_pub.add('after step 4 from id = '|| to_char(l_MODIFIERS_rec.from_rltd_modifier_id) );
        IF l_control_rec.write_to_db THEN

            IF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

    oe_debug_pub.add('from id = '|| to_char(l_MODIFIERS_rec.from_rltd_modifier_id) );
              IF  l_MODIFIERS_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM
		    AND l_MODIFIERS_rec.list_line_type_code <> 'PMR'

		    THEN

                 FND_MESSAGE.SET_NAME('QP','QP_CANNOT_DELETE_MODIFIER_LIST');
                 OE_MSG_PUB.Add;

                 RAISE FND_API.G_EXC_ERROR;
              ELSE

    oe_debug_pub.add('just before deleteee');
                QP_Modifiers_Util.Delete_Row
                (   p_list_line_id                => l_MODIFIERS_rec.list_line_id
                );

              --- Code for delete ends here. Log delayed service request here.
               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_param1 => l_modifiers_rec.list_header_id,
   	            p_entity_id  => l_modifiers_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => l_modifiers_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_MAINTAIN_LIST_HEADER_PHASES,
                 x_return_status => l_return_status);

              END IF;

            ELSE

--dbms_output.put_line('oper = ' || l_MODIFIERS_rec.operation);
                --  Get Who Information

                l_MODIFIERS_rec.last_update_date := SYSDATE;
                l_MODIFIERS_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_MODIFIERS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Modifiers_Util.Update_Row (l_MODIFIERS_rec);

                    -- julin (3411436): updating qp_rltd_modifiers
                    IF   l_MODIFIERS_rec.from_rltd_modifier_id IS NOT NULL
                    AND  l_MODIFIERS_rec.list_line_id IS NOT NULL
                    AND  l_MODIFIERS_rec.rltd_modifier_grp_no  IS NOT NULL
                    AND  l_MODIFIERS_rec.rltd_modifier_grp_type  IS NOT NULL
				THEN


                    oe_debug_pub.add('just before update');

                                QP_RLTD_MODIFIER_PVT.Update_Row(
                               l_MODIFIERS_rec.RLTD_MODIFIER_ID
						 , l_MODIFIERS_rec.creation_date
                               , l_MODIFIERS_rec.created_by
                               , l_MODIFIERS_rec.last_update_date
                               , l_MODIFIERS_rec.last_updated_by
                               , l_MODIFIERS_rec.last_update_login
                               , l_MODIFIERS_rec.rltd_modifier_grp_no
                               , l_MODIFIERS_rec.from_rltd_modifier_id
						 , l_MODIFIERS_rec.to_rltd_modifier_id
                               , l_MODIFIERS_rec.rltd_modifier_grp_type
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               );

               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
   	         p_entity_id  => l_modifiers_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => l_modifiers_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);

                     END IF;

                ELSIF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_MODIFIERS_rec.creation_date  := SYSDATE;
                    l_MODIFIERS_rec.created_by     := FND_GLOBAL.USER_ID;

--dbms_output.put_line('just before insert');
             oe_debug_pub.add('list before  = ' || to_char(l_MODIFIERS_rec.list_line_id));
             oe_debug_pub.add('to before = ' || to_char(l_MODIFIERS_rec.to_rltd_modifier_id));
                    QP_Modifiers_Util.Insert_Row (l_MODIFIERS_rec);

                oe_debug_pub.add('from id= '||to_char(l_MODIFIERS_rec.from_rltd_modifier_id));
                oe_debug_pub.add('grp no= '||to_char(l_MODIFIERS_rec.rltd_modifier_grp_no));


-- For Coupon Issue, the to_rltd_modifier_id is the list_line_id of the benefit modifier.
-- So, to_rltd_modifier_id is passed from the form to the BOI. For all other types of
-- modifiers, the to_rltd_modifier_id is the same as the list_line_id of the current
-- record. This is a CRM requirement
/*
                    IF   l_MODIFIERS_rec.list_line_type_code = 'CIE'
                    THEN

                       l_MODIFIERS_rec.rltd_modifier_grp_type := 'COUPON';
--				   l_to_rltd_modifier_id := l_MODIFIERS_rec.to_rltd_modifier_id;

                    ELSE

				   l_MODIFIERS_rec.to_rltd_modifier_id := l_MODIFIERS_rec.list_line_id;

                    END IF;

             oe_debug_pub.add('list type = ' || l_MODIFIERS_rec.list_line_type_code);
             oe_debug_pub.add('from = ' || to_char(l_MODIFIERS_rec.from_rltd_modifier_id));
             oe_debug_pub.add('list after  = ' || to_char(l_MODIFIERS_rec.list_line_id));
             oe_debug_pub.add('to after = ' || to_char(l_MODIFIERS_rec.to_rltd_modifier_id));
             oe_debug_pub.add('grp_no = ' || to_char(l_MODIFIERS_rec.rltd_modifier_grp_no));
             oe_debug_pub.add('grp_type = ' || l_MODIFIERS_rec.rltd_modifier_grp_type);
             oe_debug_pub.add('parent index = ' || l_MODIFIERS_rec.modifier_parent_index);



		   IF ((l_MODIFIERS_rec.modifier_parent_index IS NOT NULL)
		   AND (l_MODIFIERS_rec.modifier_parent_index <> FND_API.G_MISS_NUM)
		   AND l_MODIFIERS_rec.list_line_type_code not in ('PBH', 'OID','PRG')
		   AND l_MODIFIERS_tbl(l_MODIFIERS_rec.modifier_parent_index).list_line_type_code IN ('PBH', 'OID', 'PRG')) THEN

		    --dbms_output.put_line('inside if');
		    oe_debug_pub.add('in if');

		   		l_MODIFIERS_rec.from_rltd_modifier_id :=
					l_MODIFIERS_tbl(l_MODIFIERS_rec.modifier_parent_index).list_line_id;

		   END IF;
*/
  		--dbms_output.put_line('type  = '||l_MODIFIERS_rec.list_line_type_code);
  		--dbms_output.put_line('from pri = '||to_char(l_MODIFIERS_rec.from_rltd_modifier_id));


                oe_debug_pub.add('before insert');

                    IF   l_MODIFIERS_rec.from_rltd_modifier_id IS NOT NULL
                    AND  l_MODIFIERS_rec.list_line_id IS NOT NULL
                    AND  l_MODIFIERS_rec.rltd_modifier_grp_no  IS NOT NULL
                    AND  l_MODIFIERS_rec.rltd_modifier_grp_type  IS NOT NULL
				THEN

				select QP_RLTD_MODIFIERS_S.nextval
				into   l_rltd_modifiers_s from dual;


                oe_debug_pub.add('just before insert');
                --dbms_output.put_line('just before insert in rltd'||nvl(to_char(l_MODIFIERS_rec.to_rltd_modifier_id), 'aaa'));

                                QP_RLTD_MODIFIER_PVT.Insert_Row(
                                l_rltd_modifiers_s
						 , l_MODIFIERS_rec.creation_date
                               , l_MODIFIERS_rec.created_by
                               , l_MODIFIERS_rec.last_update_date
                               , l_MODIFIERS_rec.last_updated_by
                               , l_MODIFIERS_rec.last_update_login
                               , l_MODIFIERS_rec.rltd_modifier_grp_no
                               , l_MODIFIERS_rec.from_rltd_modifier_id
						 , l_MODIFIERS_rec.to_rltd_modifier_id
                               , l_MODIFIERS_rec.rltd_modifier_grp_type
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               );

               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
   	         p_entity_id  => l_modifiers_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => l_modifiers_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);

                     END IF; -- related lines

                 END IF; -- G_OPR_CREATE
              --- Code for update an create ends here. Log delayed servuce request here.

                 qp_delayed_requests_PVT.log_request(
                   p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
   	              p_entity_id  => l_modifiers_rec.list_line_id,
                   p_param1 => l_modifiers_rec.list_header_id,
                   p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                   p_requesting_entity_id => l_modifiers_rec.list_line_id,
                   p_request_type =>QP_GLOBALS.G_MAINTAIN_LIST_HEADER_PHASES,
                   x_return_status => l_return_status);

                 END IF;

        END IF;

    END IF; -- For Operation Create, Update or Delete

        --  Load tables.

        l_MODIFIERS_tbl(I)             := l_MODIFIERS_rec;
        l_old_MODIFIERS_tbl(I)         := l_old_MODIFIERS_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_ERROR;
            l_MODIFIERS_tbl(I)             := l_MODIFIERS_rec;
            l_old_MODIFIERS_tbl(I)         := l_old_MODIFIERS_rec;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
			p_entity_id => l_MODIFIERS_rec.list_header_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );
            end if;

            -- mkarya for bug 1728764, so that the exception is handled by the calling function.
            RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
            l_MODIFIERS_tbl(I)             := l_MODIFIERS_rec;
            l_old_MODIFIERS_tbl(I)         := l_old_MODIFIERS_rec;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
			p_entity_id => l_MODIFIERS_rec.list_header_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
            l_MODIFIERS_tbl(I)             := l_MODIFIERS_rec;
            l_old_MODIFIERS_tbl(I)         := l_old_MODIFIERS_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Modifierss'
                );
            END IF;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
			p_entity_id => l_MODIFIERS_rec.list_header_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
			p_entity_id => l_MODIFIERS_rec.list_line_id,
			x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_MODIFIERS_tbl                := l_MODIFIERS_tbl;
    x_old_MODIFIERS_tbl            := l_old_MODIFIERS_tbl;

    oe_debug_pub.add('END modifierss in Private');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modifierss'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modifierss;

--  Qualifierss

PROCEDURE Qualifierss
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   p_old_QUALIFIERS_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_old_QUALIFIERS_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_p_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_rec          QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_old_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN qualifierss in Private');
    --  Init local table variables.

    l_QUALIFIERS_tbl               := p_QUALIFIERS_tbl;
    l_old_QUALIFIERS_tbl           := p_old_QUALIFIERS_tbl;

    FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_QUALIFIERS_rec := l_QUALIFIERS_tbl(I);

        IF l_old_QUALIFIERS_tbl.EXISTS(I) THEN
            l_old_QUALIFIERS_rec := l_old_QUALIFIERS_tbl(I);
        ELSE
            l_old_QUALIFIERS_rec := QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_QUALIFIERS_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

    oe_debug_pub.add('test01');
            l_QUALIFIERS_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_QUALIFIERS_rec :=
            QP_Qualifiers_Util.Convert_Miss_To_Null (l_old_QUALIFIERS_rec);

        ELSIF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_QUALIFIERS_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM
            THEN

                l_old_QUALIFIERS_rec := QP_Qualifiers_Util.Query_Row
                (   p_qualifier_id                => l_QUALIFIERS_rec.qualifier_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_QUALIFIERS_rec :=
                QP_Qualifiers_Util.Convert_Miss_To_Null (l_old_QUALIFIERS_rec);

            END IF;

            --  Complete new record from old

    oe_debug_pub.add('before complete rec ');
            l_QUALIFIERS_rec := QP_Qualifiers_Util.Complete_Record
            (   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

    oe_debug_pub.add('before validate qual');
                QP_Validate_Qualifiers.Attributes
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
                );

    oe_debug_pub.add('after validate qual');
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

    oe_debug_pub.add('before util clear');
            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN

    oe_debug_pub.add('before clear depen');
            l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
            QP_Qualifiers_Util.Clear_Dependent_Attr
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

    oe_debug_pub.add('before default attrib');
        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
            QP_Default_Qualifiers.Attributes
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --  Apply attribute changes

    oe_debug_pub.add('before util');
        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
             l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
            QP_Qualifiers_Util.Apply_Attribute_Changes
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Qualifiers.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                );

            ELSE

    oe_debug_pub.add('before entity validate');
                QP_Validate_Qualifiers.Entity
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
                );

            END IF;
    oe_debug_pub.add('after entity validate');

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
    oe_debug_pub.add('after entity validate end if');

        END IF;

        --  Step 3.5. Perform action which need to be performed before
        --            writing to the DB (like Scheduling).

        IF l_control_rec.write_to_db THEN
                   l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
    	          QP_QUALIFIERS_UTIL.PRE_WRITE_PROCESS
                   ( p_QUALIFIERS_rec      => l_p_QUALIFIERS_rec
                   , p_old_QUALIFIERS_rec  => l_old_QUALIFIERS_rec
                   , x_QUALIFIERS_rec      => l_QUALIFIERS_rec);

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Qualifiers_Util.Delete_Row
                (   p_qualifier_id                => l_QUALIFIERS_rec.qualifier_id
                );

            ELSE

                --  Get Who Information

                l_QUALIFIERS_rec.last_update_date := SYSDATE;
                l_QUALIFIERS_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_QUALIFIERS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Qualifiers_Util.Update_Row (l_QUALIFIERS_rec);

                ELSIF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_QUALIFIERS_rec.creation_date := SYSDATE;
                    l_QUALIFIERS_rec.created_by    := FND_GLOBAL.USER_ID;

    oe_debug_pub.add('util . Insert');
                    QP_Qualifiers_Util.Insert_Row (l_QUALIFIERS_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
        l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.list_header_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

               qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.qualifier_id,
			x_return_status => l_return_status );
            end if;

            -- mkarya for bug 1728764, so that the exception is handled by the calling function.
            RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.list_header_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.qualifier_id,
			x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Qualifierss'
                );
            END IF;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.list_header_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_QUALIFIERS_rec.qualifier_id,
			x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    oe_debug_pub.add('exp loop ');
    END;
    END LOOP;

    --  Load OUT parameters

    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_old_QUALIFIERS_tbl           := l_old_QUALIFIERS_tbl;

    oe_debug_pub.add('END qualifierss in Private');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifierss'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    oe_debug_pub.add('EXP qualifierss in Private');
END Qualifierss;

--  Pricing_Attrs

PROCEDURE Pricing_Attrs
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_PRICING_ATTR_tbl              IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
,   p_old_PRICING_ATTR_tbl          IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
,   x_old_PRICING_ATTR_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
)
IS

 --- added by svdeshmu

l_status varchar2(1);
l_parent_list_line_id  number;
l_list_line_type_code varchar2(30);


 ---  end of additions  by svdeshmu


l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_p_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_rec        QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_tbl        QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_continuous_price_break_flag     VARCHAR2(1); --Continuous Price Breaks
BEGIN

    oe_debug_pub.add('BEGIN pricing_attrs in Private');
    --  Init local table variables.

    l_PRICING_ATTR_tbl             := p_PRICING_ATTR_tbl;
    l_old_PRICING_ATTR_tbl         := p_old_PRICING_ATTR_tbl;

    FOR I IN 1..l_PRICING_ATTR_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_PRICING_ATTR_rec := l_PRICING_ATTR_tbl(I);

        IF l_old_PRICING_ATTR_tbl.EXISTS(I) THEN
            l_old_PRICING_ATTR_rec := l_old_PRICING_ATTR_tbl(I);
        ELSE
            l_old_PRICING_ATTR_rec := QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_PRICING_ATTR_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

    oe_debug_pub.add('oper = '|| l_PRICING_ATTR_rec.operation );

        IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_PRICING_ATTR_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_PRICING_ATTR_rec :=
            QP_Pricing_Attr_Util.Convert_Miss_To_Null (l_old_PRICING_ATTR_rec);

        ELSIF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_PRICING_ATTR_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_PRICING_ATTR_rec.pricing_attribute_id = FND_API.G_MISS_NUM
            THEN

    oe_debug_pub.add('before query');
                l_old_PRICING_ATTR_rec := QP_Pricing_Attr_Util.Query_Row
                (   p_pricing_attribute_id        => l_PRICING_ATTR_rec.pricing_attribute_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_PRICING_ATTR_rec :=
                QP_Pricing_Attr_Util.Convert_Miss_To_Null (l_old_PRICING_ATTR_rec);

            END IF;

            --  Complete new record from old

    oe_debug_pub.add('1111');
            l_PRICING_ATTR_rec := QP_Pricing_Attr_Util.Complete_Record
            (   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
            );

        END IF;

        --  Attribute level validation.

    oe_debug_pub.add('2222');
    IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE
    OR    l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN


   --- added by svdeshmu

          oe_debug_pub.add('calling get_parent from apply attribute');
          oe_debug_pub.add('with child as'||l_pricing_attr_rec.list_line_id);
            Get_Parent_List_Line_Id
		  (  p_child_list_line_id =>l_PRICING_ATTR_REC.list_line_id
		   , x_parent_list_line_id =>l_parent_list_line_id
		   , x_list_line_type_code =>l_list_line_type_code
		   , x_status =>l_status
		  );
          oe_debug_pub.add('status of get_parent is'||l_status);

          IF l_status  = 'T' AND l_list_line_type_code = 'PBH' THEN

	     oe_debug_pub.add('calling log request for ob from private ');
	     oe_debug_pub.add('list_line_id is '||l_parent_list_line_id);
	     oe_debug_pub.add(' pr  is '||l_PRICING_ATTR_REC.list_line_id);

          --Added to check whether the PBH is for continuous or
          --non-continuous price breaks
          BEGIN
            select continuous_price_break_flag
            into   l_continuous_price_break_flag
            from   qp_list_lines
            where  list_line_id = l_parent_list_line_id;
          EXCEPTION
            WHEN OTHERS THEN
               l_continuous_price_break_flag := NULL;
          END;

            qp_delayed_requests_PVT.log_request
	       (  p_entity_code => QP_GLOBALS.G_ENTITY_PRICING_ATTR
		   , p_entity_id  => l_PRICING_ATTR_REC.list_line_id
	        , p_param1 =>l_parent_list_line_id
		, p_param2 => l_continuous_price_break_flag
				--Added the param to call the validation
				--function depending upon the break type
             , p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_PRICING_ATTR
             , p_requesting_entity_id => l_PRICING_ATTR_REC.list_line_id
             , p_request_type =>QP_GLOBALS.G_OVERLAPPING_PRICE_BREAKS
	        , x_return_status => l_return_status);

	     END IF;
  -- end of additions by svdeshmu


        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Pricing_Attr.Attributes
                (   x_return_status               => l_return_status
                ,   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
                ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

    oe_debug_pub.add('3333');
            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN
            l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
            QP_Pricing_Attr_Util.Clear_Dependent_Attr
            (   p_PRICING_ATTR_rec            => l_p_PRICING_ATTR_rec
            ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
               l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
            QP_Default_Pricing_Attr.Attributes
            (   p_PRICING_ATTR_rec            => l_p_PRICING_ATTR_rec
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            );

        END IF;

        --  Apply attribute changes

    oe_debug_pub.add('4444');
        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

    oe_debug_pub.add('7777');
             l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
            QP_Pricing_Attr_Util.Apply_Attribute_Changes
            (   p_PRICING_ATTR_rec            => l_p_PRICING_ATTR_rec
            ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            );

        END IF;

        --  Entity level validation.

    oe_debug_pub.add('5555');
        IF l_control_rec.validate_entity THEN

            IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Pricing_Attr.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
                );

            ELSE
		  null;

                QP_Validate_Pricing_Attr.Entity
                (   x_return_status               => l_return_status
                ,   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
                ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
                );
			 null;

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        IF l_control_rec.write_to_db THEN
                 l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
    	          QP_PRICING_ATTR_UTIL.PRE_WRITE_PROCESS
                   ( p_Pricing_Attr_rec      => l_p_Pricing_Attr_rec
                   , p_old_Pricing_Attr_rec  => l_old_Pricing_Attr_rec
                   , x_Pricing_Attr_rec      => l_Pricing_Attr_rec);

        END IF;

        --  Step 4. Write to DB

    oe_debug_pub.add('6666');
        IF l_control_rec.write_to_db THEN

            IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

     --added by svdeshmu


	    --[5069539] Added the check to skip this block when the call is from
	    --UI. The validation for existing break lines is done in the form
	    --itself. This is required because newly inserted break lines must be
	    --allowed for deletion before saving.
	    IF p_control_rec.called_from_ui = 'N' THEN
		-- bug 3563355 start
                Declare

                        x_rltd_modifier_grp_type varchar2(30);

                Begin

                        SELECT null INTO x_rltd_modifier_grp_type
                        FROM qp_rltd_modifiers
                        WHERE to_rltd_modifier_id = l_PRICING_ATTR_rec.list_line_id
                        AND rltd_modifier_grp_type = 'PRICE BREAK'
                        AND ROWNUM = 1;

                        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_DELETE_DETAIL_LINES');
                        OE_MSG_PUB.Add;
                        RAISE FND_API.G_EXC_ERROR;


                Exception

                        WHEN NO_DATA_FOUND THEN
                        Null;
                End;
                -- bug 3563355 end
	    END IF;

           oe_debug_pub.add('calling get_parent from QPXVMLSB while delete');
           oe_debug_pub.add('with child as'||l_pricing_attr_rec.list_line_id);
            Get_Parent_List_Line_Id
		  (  p_child_list_line_id =>l_PRICING_ATTR_REC.list_line_id
		   , x_parent_list_line_id =>l_parent_list_line_id
		   , x_list_line_type_code =>l_list_line_type_code
		   , x_status =>l_status
		  );

           oe_debug_pub.add('status of get_parent is'||l_status);

           IF l_status  = 'T' THEN

	      oe_debug_pub.add('calling log request for ob from private ');
	      oe_debug_pub.add('list_line_id is '||l_parent_list_line_id);
           qp_delayed_requests_PVT.log_request
		 (  p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS
		  , p_entity_id  => l_parent_list_line_id
	       , p_param1 =>l_list_line_type_code
            , p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS
            , p_requesting_entity_id => l_parent_list_line_id
            , p_request_type =>QP_GLOBALS.G_VALIDATE_LINES_FOR_CHILD
	       , x_return_status => l_return_status
		 );
          END IF;


    -- end of additions by svdeshmu



    oe_debug_pub.add('7777');
                QP_Pricing_Attr_Util.Delete_Row
                (   p_pricing_attribute_id        => l_PRICING_ATTR_rec.pricing_attribute_id
                );

            ELSE

                --  Get Who Information

                l_PRICING_ATTR_rec.last_update_date := SYSDATE;
                l_PRICING_ATTR_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_PRICING_ATTR_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Pricing_Attr_Util.Update_Row (l_PRICING_ATTR_rec);

                ELSIF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_PRICING_ATTR_rec.creation_date := SYSDATE;
                    l_PRICING_ATTR_rec.created_by  := FND_GLOBAL.USER_ID;
oe_debug_pub.add(to_char(l_PRICING_ATTR_rec.attribute_grouping_no)||'attr_grp');
                    QP_Pricing_Attr_Util.Insert_Row (l_PRICING_ATTR_rec);

                END IF;

            END IF;

        END IF;

    END IF; -- For Operation Create, Update or Delete
        --  Load tables.

        l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
        l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

    --  For loop exception handler.


    EXCEPTION

	   WHEN NO_DATA_FOUND THEN
	   null;

        WHEN FND_API.G_EXC_ERROR THEN

            l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
            l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

        oe_debug_pub.add('manoj - value of called_from_ui before delete_reqs_for_deleted_entity = ' || l_control_rec.called_from_ui);
        --dbms_output.put_line('manoj - pricing_attr- value of called_from_ui before delete_reqs_for_deleted_entity = ' || l_control_rec.called_from_ui);
            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICING_ATTR,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_parent_list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );
            end if;

            -- mkarya for bug 1728764, so that the exception is handled by the calling function.
            RAISE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
            l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICING_ATTR,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_parent_list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
            l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Pricing_Attrs'
                );
            END IF;

            -- mkarya If process_modifiers has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICING_ATTR,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_parent_list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );

                qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
			p_entity_id => l_PRICING_ATTR_rec.list_line_id,
			x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;
    x_old_PRICING_ATTR_tbl         := l_old_PRICING_ATTR_tbl;

    oe_debug_pub.add('END pricing_attrs in Private');
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attrs'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attrs;

--  Start of Comments
--  API name    Process_Modifiers
--  Type        Private
--  Function
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

PROCEDURE Process_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_MODIFIERS_tbl                 IN  QP_Modifiers_PUB.Modifiers_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_TBL
,   p_old_MODIFIERS_tbl             IN  QP_Modifiers_PUB.Modifiers_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_old_QUALIFIERS_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_TBL
,   p_old_PRICING_ATTR_tbl          IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_list_type_code              VARCHAR2(30);
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Modifiers';
l_return_status               VARCHAR2(1);
l_qp_status                   VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type := p_MODIFIER_LIST_rec;
l_p_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type := p_MODIFIER_LIST_rec;
l_old_MODIFIER_LIST_rec       QP_Modifiers_PUB.Modifier_List_Rec_Type := p_old_MODIFIER_LIST_rec;
l_p_old_MODIFIER_LIST_rec     QP_Modifiers_PUB.Modifier_List_Rec_Type := p_old_MODIFIER_LIST_rec;
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_p_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_old_MODIFIERS_rec           QP_Modifiers_PUB.Modifiers_Rec_Type;
l_old_MODIFIERS_tbl           QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_p_old_MODIFIERS_tbl         QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_rec          QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_old_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_p_old_QUALIFIERS_tbl        QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_p_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_rec        QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_tbl        QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_p_old_PRICING_ATTR_tbl      QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
NO_UPDATE_PRIVILEGE           EXCEPTION;

-- Blanket Agreement
l_qual_exists                 VARCHAR2(1) := 'N';
BEGIN

    oe_debug_pub.add('BEGIN process_modifiers in Private');
    --dbms_output.put_line('BEGIN process_modifiers in Private');
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    -- BOI not available when QP not installed

    l_qp_status := QP_UTIL.GET_QP_STATUS;

    IF l_qp_status = 'N'
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_PRICING_NOT_INSTALLED');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF p_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN
       -- Check the security privilege
       IF QP_security.check_function( p_function_name => QP_Security.G_FUNCTION_UPDATE,
                                    p_instance_type => QP_Security.G_MODIFIER_OBJECT,
                                    p_instance_pk1  => p_MODIFIER_LIST_rec.list_header_id) = 'F'
       THEN
         fnd_message.set_name('QP', 'QP_NO_PRIVILEGE');
         fnd_message.set_token('PRICING_OBJECT', 'Modifier List');
         oe_msg_pub.Add;

         RAISE NO_UPDATE_PRIVILEGE;

       END IF;  -- end of check security privilege
    END IF;


    --  Init local table variables.

    oe_debug_pub.add('Operation in pvt'||l_MODIFIER_LIST_rec.operation);
    l_MODIFIERS_tbl                := p_MODIFIERS_tbl;
    l_old_MODIFIERS_tbl            := p_old_MODIFIERS_tbl;

    --  Init local table variables.

    l_QUALIFIERS_tbl               := p_QUALIFIERS_tbl;
    l_old_QUALIFIERS_tbl           := p_old_QUALIFIERS_tbl;

    --  Init local table variables.

    l_PRICING_ATTR_tbl             := p_PRICING_ATTR_tbl;
    l_old_PRICING_ATTR_tbl         := p_old_PRICING_ATTR_tbl;

    --  Modifier_List

    oe_debug_pub.add('list type1= '|| l_MODIFIER_LIST_rec.list_type_code);
    l_p_MODIFIER_LIST_rec := l_MODIFIER_LIST_rec;
    l_p_old_MODIFIER_LIST_rec := l_old_MODIFIER_LIST_rec;
    Modifier_List
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_MODIFIER_LIST_rec           => l_p_MODIFIER_LIST_rec
    ,   p_old_MODIFIER_LIST_rec       => l_p_old_MODIFIER_LIST_rec
    ,   x_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   x_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
    );

    --  Perform MODIFIER_LIST group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_MODIFIER_LIST)
    THEN

       -- FOR QUALIFICATION_IND
       QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => QP_GLOBALS.G_ENTITY_MODIFIER_LIST
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
--      NULL;

    END IF;

    oe_debug_pub.add('list type2= '|| l_MODIFIER_LIST_rec.list_type_code);
    --dbms_output.put_line('load parent key');
    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_MODIFIERS_tbl.COUNT LOOP

        l_MODIFIERS_rec := l_MODIFIERS_tbl(I);

        IF l_MODIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_MODIFIERS_rec.list_header_id IS NULL OR
            l_MODIFIERS_rec.list_header_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_MODIFIERS_tbl(I).list_header_id := l_MODIFIER_LIST_rec.list_header_id;
        END IF;
    END LOOP;

    --  Modifierss

    oe_debug_pub.add('list type3= '|| l_MODIFIER_LIST_rec.list_type_code);
    l_p_MODIFIERS_tbl := l_MODIFIERS_tbl;
    l_p_old_MODIFIERS_tbl := l_old_MODIFIERS_tbl;
    Modifierss
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_MODIFIERS_tbl               => l_p_MODIFIERS_tbl
    ,   p_old_MODIFIERS_tbl           => l_p_old_MODIFIERS_tbl
    ,   x_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_old_MODIFIERS_tbl           => l_old_MODIFIERS_tbl
    );

    --  Perform MODIFIERS group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_MODIFIERS)
    THEN
oe_debug_pub.add('here1');
        --NULL;

       -- FOR QUALIFICATION_IND
       QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => QP_GLOBALS.G_ENTITY_MODIFIERS
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    oe_debug_pub.add('list type4= '|| l_MODIFIER_LIST_rec.list_type_code);
    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP

oe_debug_pub.add('here2');
        l_QUALIFIERS_rec := l_QUALIFIERS_tbl(I);

        IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_QUALIFIERS_rec.list_header_id IS NULL OR
            l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM)
        THEN

oe_debug_pub.add('here3');
            --  Copy parent_id.

            l_QUALIFIERS_tbl(I).list_header_id := l_MODIFIER_LIST_rec.list_header_id;
        END IF;
    END LOOP;

    --  Qualifierss
    l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
    l_p_old_QUALIFIERS_tbl := l_old_QUALIFIERS_tbl;
    Qualifierss
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   p_old_QUALIFIERS_tbl          => l_p_old_QUALIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_old_QUALIFIERS_tbl          => l_old_QUALIFIERS_tbl
    );

    --  Perform QUALIFIERS group requests.

oe_debug_pub.add('here4');
    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_QUALIFIERS)
    THEN

oe_debug_pub.add('here5');
       -- FOR CHECK_SEGMENT_LEVEL_IN_GROUP
       QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => QP_GLOBALS.G_ENTITY_QUALIFIERS
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_PRICING_ATTR_tbl.COUNT LOOP

        l_PRICING_ATTR_rec := l_PRICING_ATTR_tbl(I);

oe_debug_pub.add(to_char(l_PRICING_ATTR_rec.attribute_grouping_no)||'attr_grp_no');
        IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_PRICING_ATTR_rec.list_line_id IS NULL OR
            l_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM)
        THEN

oe_debug_pub.add('here6');
oe_debug_pub.add(to_char(l_PRICING_ATTR_rec.attribute_grouping_no)||'attr_grp_no');
oe_debug_pub.add(to_char(l_PRICING_ATTR_rec.MODIFIERS_index));
            --  Check If parent exists.

            IF l_MODIFIERS_tbl.EXISTS(l_PRICING_ATTR_rec.MODIFIERS_index) THEN

                --  Copy parent_id.

oe_debug_pub.add('if here6');
                l_PRICING_ATTR_tbl(I).list_line_id := l_MODIFIERS_tbl(l_PRICING_ATTR_rec.MODIFIERS_index).list_line_id;

            ELSE

oe_debug_pub.add('else if here6');
                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('QP','QP_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','PRICING_ATTR');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_PRICING_ATTR_rec.MODIFIERS_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
            END IF;
    END LOOP;
    --  Pricing_Attrs

oe_debug_pub.add('pricing attrhere6');
   l_p_PRICING_ATTR_tbl := l_PRICING_ATTR_tbl;
   l_p_old_PRICING_ATTR_tbl := l_old_PRICING_ATTR_tbl;
    Pricing_Attrs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_PRICING_ATTR_tbl            => l_p_PRICING_ATTR_tbl
    ,   p_old_PRICING_ATTR_tbl        => l_p_old_PRICING_ATTR_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_old_PRICING_ATTR_tbl        => l_old_PRICING_ATTR_tbl
    );

oe_debug_pub.add('after pricing attrhere6');
    --  Perform PRICING_ATTR group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_PRICING_ATTR)
    THEN


       QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => QP_GLOBALS.G_ENTITY_PRICING_ATTR
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
     --   NULL;

    END IF;

    oe_debug_pub.add('list type5= '|| l_MODIFIER_LIST_rec.list_type_code);
    oe_debug_pub.add('before last if');
    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL
    THEN
       -- FOR QUALIFICATION_IND
       QP_DELAYED_REQUESTS_PVT.Process_Delayed_Requests
          (
            x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
/*
     oe_debug_pub.add('calling process_request');
     QP_delayed_requests_pvt.process_request_for_entity(p_entity_code =>QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
									x_return_status=>l_return_status);

     oe_debug_pub.add('return status after calling  process_request' || l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

*/
        NULL;

    END IF;

    -- start bug2091362, bug2119287
    Declare
    l_qp_status VARCHAR2(1);

    Begin
    l_qp_status := QP_UTIL.GET_QP_STATUS;

    IF (fnd_profile.value('QP_ALLOW_DUPLICATE_MODIFIERS') <> 'Y'
        AND (l_qp_status = 'S' OR l_MODIFIER_LIST_rec.gsa_indicator = 'Y')) THEN


          IF p_control_rec.process AND
            p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL
        THEN
    oe_debug_pub.add('Before processing delayed request for duplicate modifiers');
           -- FOR Duplicate Modifier Lines
           QP_DELAYED_REQUESTS_PVT.Process_Delayed_Requests
              (
                x_return_status => l_return_status
              );

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
           END IF;
    oe_debug_pub.add('After processing delayed request for duplicate modifiers');

        END IF;
    ELSE

       NULL;

    END IF;

    END;

    -- end bug2091362


    oe_debug_pub.add('list type6= '|| l_MODIFIER_LIST_rec.list_type_code);


    oe_debug_pub.add('before validation');
    oe_debug_pub.add('oper = '|| l_MODIFIERS_rec.operation);
    oe_debug_pub.add('list type = '|| l_MODIFIER_LIST_rec.list_type_code);
    oe_debug_pub.add('Modifier type  = '|| l_MODIFIERS_rec.list_line_type_code);

    --  Done processing, load OUT parameters.

    x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
    x_MODIFIERS_tbl                := l_MODIFIERS_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN

        NULL;

    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN

        NULL;

    END IF;

    --  Derive return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_MODIFIER_LIST_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_MODIFIERS_tbl.COUNT LOOP

        IF l_MODIFIERS_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP

        IF l_QUALIFIERS_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_PRICING_ATTR_tbl.COUNT LOOP

        IF l_PRICING_ATTR_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    -- Create blanket header qualifier

    IF (     p_control_rec.write_to_db --Bug#3309455
         AND x_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE
         AND x_MODIFIER_LIST_rec.list_source_code = 'BSO'
         AND ( x_MODIFIER_LIST_rec.orig_system_header_ref <> NULL
            OR x_MODIFIER_LIST_rec.orig_system_header_ref <> FND_API.G_MISS_CHAR)
       )
    THEN
        oe_debug_pub.add('inside create qualifier for blanket modifier');

	BEGIN
	  select 'Y' into l_qual_exists
	  from qp_qualifiers
	  where list_header_id = x_MODIFIER_LIST_rec.list_header_id
	   and qualifier_context = 'ORDER'
	   and qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
	   and qualifier_attr_value = x_MODIFIER_LIST_rec.orig_system_header_ref;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    l_qual_exists := 'N';
	  WHEN OTHERS THEN NULL;
	END;

	IF l_qual_exists = 'N' THEN

		QP_Qualifier_Rules_PVT.Create_Blanket_Qualifier
	           (   p_list_header_id            => x_MODIFIER_LIST_rec.list_header_id
	           ,   p_old_list_header_id        => x_MODIFIER_LIST_rec.list_header_id
	           ,   p_blanket_id                => to_number(x_MODIFIER_LIST_rec.orig_system_header_ref)
	           ,   p_operation                 => QP_GLOBALS.G_OPR_CREATE
	           ,   x_return_status             => l_return_status
		   );

	         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           oe_debug_pub.add('Unexp Error while creating blanket qualifier');
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           oe_debug_pub.add('Exp Error while creating blanket qualifier');
	           RAISE FND_API.G_EXC_ERROR;
	         END IF;
	END IF;

    END IF;

    oe_debug_pub.add('END process_modifiers in Private');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        oe_debug_pub.add('manoj - value of called_from_ui before clear_request = ' || p_control_rec.called_from_ui);
        --dbms_output.put_line('manoj - value of called_from_ui before clear_request = ' || p_control_rec.called_from_ui);
        -- mkarya If process_modifiers has been called from public package, then ONLY call clear_request
        if p_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.Clear_Request
		(x_return_status =>  l_return_status);
        end if;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- mkarya If process_modifiers has been called from public package, then ONLY call clear_request
        if p_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.Clear_Request
		(x_return_status =>  l_return_status);
        end if;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN NO_UPDATE_PRIVILEGE THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- mkarya If process_modifiers has been called from public package, then ONLY call clear_request
        if p_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.Clear_Request
		(x_return_status =>  l_return_status);
        end if;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Modifiers'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    oe_debug_pub.add('EXP process_modifiers in Private');
END Process_Modifiers;

--  Start of Comments
--  API name    Lock_Modifiers
--  Type        Private
--  Function
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

PROCEDURE Lock_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
,   p_MODIFIERS_tbl                 IN  QP_Modifiers_PUB.Modifiers_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_TBL
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Modifiers_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_TBL
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Modifiers';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
BEGIN

    oe_debug_pub.add('BEGIN lock_modifiers in Private');
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Modifiers_PVT;

    --  Lock MODIFIER_LIST

    IF p_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Modifier_List_Util.Lock_Row
        (   p_MODIFIER_LIST_rec           => p_MODIFIER_LIST_rec
        ,   x_MODIFIER_LIST_rec           => x_MODIFIER_LIST_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock MODIFIERS

    FOR I IN 1..p_MODIFIERS_tbl.COUNT LOOP

        IF p_MODIFIERS_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Modifiers_Util.Lock_Row
            (   p_MODIFIERS_rec               => p_MODIFIERS_tbl(I)
            ,   x_MODIFIERS_rec               => l_MODIFIERS_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_MODIFIERS_tbl(I)             := l_MODIFIERS_rec;

        END IF;

    END LOOP;

    --  Lock QUALIFIERS

    FOR I IN 1..p_QUALIFIERS_tbl.COUNT LOOP

        IF p_QUALIFIERS_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Qualifiers_Util.Lock_Row
            (   p_QUALIFIERS_rec              => p_QUALIFIERS_tbl(I)
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;

        END IF;

    END LOOP;

    --  Lock PRICING_ATTR

    FOR I IN 1..p_PRICING_ATTR_tbl.COUNT LOOP

        IF p_PRICING_ATTR_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Pricing_Attr_Util.Lock_Row
            (   p_PRICING_ATTR_rec            => p_PRICING_ATTR_tbl(I)
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('END lock_modifiers in Private');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Modifiers_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Modifiers_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Modifiers'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Modifiers_PVT;

END Lock_Modifiers;

--  Start of Comments
--  API name    Get_Modifiers
--  Type        Private
--  Function
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

PROCEDURE Get_Modifiers
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
,   x_MODIFIER_LIST_rec             OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifier_List_Rec_Type
,   x_MODIFIERS_tbl                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Modifiers';
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN get_modifiers in Private');
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Get MODIFIER_LIST ( parent = MODIFIER_LIST )

    l_MODIFIER_LIST_rec :=  QP_Modifier_List_Util.Query_Row
    (   p_list_header_id      => p_list_header_id
    );

        --  Get MODIFIERS ( parent = MODIFIER_LIST )

        l_MODIFIERS_tbl :=  QP_Modifiers_Util.Query_Rows
        (   p_list_header_id        => l_MODIFIER_LIST_rec.list_header_id
        );


        --  Loop over MODIFIERS's children

        FOR I2 IN 1..l_MODIFIERS_tbl.COUNT LOOP

            --  Get PRICING_ATTR ( parent = MODIFIERS )

            l_PRICING_ATTR_tbl :=  QP_Pricing_Attr_Util.Query_Rows
            (   p_list_line_id            => l_MODIFIERS_tbl(I2).list_line_id
            );

            FOR I3 IN 1..l_PRICING_ATTR_tbl.COUNT LOOP
                l_PRICING_ATTR_tbl(I3).MODIFIERS_Index := I2;
                l_x_PRICING_ATTR_tbl
                (l_x_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_tbl(I3);
            END LOOP;


        END LOOP;


        --  Get QUALIFIERS ( parent = MODIFIER_LIST )

        l_QUALIFIERS_tbl :=  QP_Qualifiers_Util_Mod.Query_Rows
        (   p_list_header_id        => l_MODIFIER_LIST_rec.list_header_id
         );


    --  Load out parameters

    x_MODIFIER_LIST_rec            := l_MODIFIER_LIST_rec;
    x_MODIFIERS_tbl                := l_MODIFIERS_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_x_PRICING_ATTR_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Modifiers'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    oe_debug_pub.add('END get_modifiers in Private');
END Get_Modifiers;

END QP_Modifiers_PVT;

/
