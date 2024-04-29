--------------------------------------------------------
--  DDL for Package Body ASO_NOTES_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_NOTES_INT" AS
/* $Header: asoinotb.pls 120.1 2005/06/29 12:34:02 appldev ship $ */

-- Start of Comments
-- Package name     : ASO_NOTES_INT
-- Purpose          :
-- History          :
--                  10/07/2002 - hyang:  2611381, performance fix for 1158.
--                  28-JAN-2003 - subha madapusi : ER 2732010.
--                  01-MAY-2003   Subha Madapusi : bug - 2915604.
-- NOTE             :
-- End of Comments

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'ASO_NOTES_INT';
G_FILE_NAME   CONSTANT VARCHAR2(12) :=  'asoinotb.pls';


/*
 * A quote can have multiple JTF notes attached to it.  When a
 * new version of quote is created from an existing quote, all the JTF
 * notes attached to the existing quote should be attached to the new
 * version of quote, too.
 *
 * This procedure is called when a new version of quote is created from an
 * existing quote.
 *
 * param p_old_quote_header_id: quote header ID of the existing quote.
 * param p_new_quote_header_id: quote header ID of the new version.
 */

PROCEDURE Copy_Notes
(
    p_api_version          IN  NUMBER                     ,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE ,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER                     ,
    p_new_object_id        IN  NUMBER                     ,
    p_old_object_type_code IN  VARCHAR2                   ,
    p_new_object_type_code IN  VARCHAR2                   ,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2                   ,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER                     ,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)
IS

    L_API_NAME    CONSTANT   VARCHAR2(30)    := 'Copy_Notes';
    L_API_VERSION CONSTANT   NUMBER          := 1.0;

    l_sysdate                  DATE          := SYSDATE;
    lx_jtf_note_context_id     NUMBER;

    /*
     * This cursor gets information about all the JTF notes attached
     * to the existing quote.
     *
     * 2611381 fix: using base tables instead of view.
     * 2915604 Fix : removed the JTF context part both cursor and for loop for table
     * population in order to avoid duplicate notes.
     */
    CURSOR  l_notes_csr(p_object_id NUMBER, p_object_type_code VARCHAR2) IS
		select  b.jtf_note_id
		FROM    jtf_notes_b b
		WHERE   b.source_object_id  IN
		(select quote_header_id  from aso_quote_headers_all
		 where quote_number = (select quote_number from aso_quote_headers_all
						   where quote_header_id = p_object_id))
		AND   b.source_object_code = 'ASO_QUOTE';

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Copy_Notes_int;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
        L_API_VERSION,
        p_api_version,
        L_API_NAME   ,
        G_PKG_NAME
    )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: Begin Copy_Notes()', 1, 'Y');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: old_object_id:          ' || p_old_object_id, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: old_object_type_code:   ' || p_old_object_type_code, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: new_object_id:          ' || p_new_object_id, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: new_object_type_code:   ' || p_new_object_type_code, 1, 'N');
    END IF;

    FOR l_note_rec IN l_notes_csr(p_old_object_id, p_old_object_type_code) LOOP

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: l_note_rec.jtf_note_id: ' || l_note_rec.jtf_note_id, 1, 'N');
        END IF;


        JTF_NOTES_PUB.Create_Note_Context(
            	p_validation_level      => FND_API.G_VALID_LEVEL_NONE,
            	x_return_status         => x_return_status           ,
            	p_jtf_note_id           => l_note_rec.jtf_note_id    ,
            	p_last_update_date      => l_sysdate                 ,
            	p_last_updated_by       => FND_Global.USER_ID        ,
            	p_creation_date         => l_sysdate                 ,
			p_created_by            => FND_Global.USER_ID        ,
     		p_last_update_login     => FND_GLOBAL.LOGIN_ID       ,
    			p_note_context_type_id  => p_new_object_id      ,
    			p_note_context_type     => p_new_object_type_code    ,
    			x_note_context_id       => lx_jtf_note_context_id
			);


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: lx_jtf_note_context_id :' || lx_jtf_note_context_id, 1, 'N');
        END IF;

    END LOOP;

    -- End of API body.
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes: End Copy_Notes()', 1, 'Y');
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

     -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

END Copy_Notes;


-- As per the ER 2732010. While creating opportunity to quote in Telesales
-- certain types of notes should NOT be copied over to the quote.
-- Those note types are to be visible only in telesales.
-- Hence the new Api is needed to accomplish this requirement.
-- The types of notes that are copied over to quote from an Opportunity are :
-- 1. Notes types that are not linked to any source objects.
-- 2. Notes types that are Specifically linked to Quoting.

-- This procedure is called only when creating a quote from an opportunity.
-- Bug 2915604. In order to avoid duplicates notes creation removed the context
-- creation part. Removed the code for the context cursor and for loop.

PROCEDURE Copy_Opp_Notes_To_Qte
(
    p_api_version          IN  NUMBER                     ,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE ,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER                     ,
    p_new_object_id        IN  NUMBER                     ,
    p_old_object_type_code IN  VARCHAR2                   ,
    p_new_object_type_code IN  VARCHAR2                   ,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2                   ,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER                     ,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)
IS

    L_API_NAME      CONSTANT   VARCHAR2(30)    := 'Copy_Opp_Notes_To_Qte';
    L_API_VERSION   CONSTANT   NUMBER          := 1.0;

    l_sysdate                  DATE            := SYSDATE;
    lx_jtf_note_context_id     NUMBER;

    CURSOR  l_notes_csr(p_object_id NUMBER, p_object_type_code VARCHAR2) IS
    select  b.jtf_note_id
    FROM    jtf_notes_b b, jtf_notes_tl t
    WHERE   b.source_object_id   = p_object_id
      AND   b.source_object_code = p_object_type_code
      AND   b.jtf_note_id = t.jtf_note_id
      AND   t.language = USERENV('LANG')
      AND   ( EXISTS ( SELECT o.object_id
	                  FROM jtf_object_mappings o
		             WHERE o.object_id = b.note_type
                       AND   o.source_object_code = 'ASO_QUOTE' )

      	       OR   NOT EXISTS ( SELECT om.object_id
			                    FROM JTF_OBJECT_MAPPINGS om
 	 		                    WHERE om.object_id = b.note_type )
            );


BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Copy_Opp_Notes_To_Qte_int;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
        L_API_VERSION,
        p_api_version,
        L_API_NAME   ,
        G_PKG_NAME
    )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: Begin Copy_Notes()', 1, 'Y');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: old_object_id:          ' || p_old_object_id, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: old_object_type_code:   ' || p_old_object_type_code, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: new_object_id:          ' || p_new_object_id, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: new_object_type_code:   ' || p_new_object_type_code, 1, 'N');
    END IF;

    FOR l_note_rec IN l_notes_csr(p_old_object_id, p_old_object_type_code) LOOP

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: l_note_rec.jtf_note_id: ' || l_note_rec.jtf_note_id, 1, 'N');
        END IF;


        JTF_NOTES_PUB.Create_Note_Context(
            	p_validation_level      => FND_API.G_VALID_LEVEL_NONE,
            	x_return_status         => x_return_status           ,
            	p_jtf_note_id           => l_note_rec.jtf_note_id    ,
            	p_last_update_date      => l_sysdate                 ,
            	p_last_updated_by       => FND_Global.USER_ID        ,
            	p_creation_date         => l_sysdate                 ,
			p_created_by            => FND_Global.USER_ID        ,
     		p_last_update_login     => FND_GLOBAL.LOGIN_ID       ,
    			p_note_context_type_id  => p_new_object_id      ,
    			p_note_context_type     => p_new_object_type_code    ,
    			x_note_context_id       => lx_jtf_note_context_id
			);


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: lx_jtf_note_context_id: ' || lx_jtf_note_context_id, 1, 'N');
        END IF;

    END LOOP;

    -- End of API body.
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_NOTES_INT: Copy_Opp_Notes_To_Qte: End Copy_Opp_Notes_To_Qte()', 1, 'Y');
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

     -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

END Copy_Opp_Notes_To_Qte;


PROCEDURE Copy_Notes_copy_quote
(
    p_api_version          IN  NUMBER                     ,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE ,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER                     ,
    p_new_object_id        IN  NUMBER                     ,
    p_old_object_type_code IN  VARCHAR2                   ,
    p_new_object_type_code IN  VARCHAR2                   ,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2                   ,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER                     ,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)
IS

    L_API_NAME    CONSTANT   VARCHAR2(30)    := 'Copy_Notes_copy_quote';
    L_API_VERSION CONSTANT   NUMBER          := 1.0;

    l_notes_detail             VARCHAR2(32767) := NULL;
    l_jtf_note_id              NUMBER;
    l_jtf_note_contexts_tab    JTF_NOTES_PUB.jtf_note_contexts_tbl_type;
    l_sysdate                  DATE            := SYSDATE;
    i                          NUMBER          := 1;

    /*
     * This cursor gets information about all the JTF notes attached
     * to the existing quote.
     *
     * 2611381 fix: using base tables instead of view.
     * 2915604 Fix : removed the JTF context part both cursor and for loop for table
     * population in order to avoid duplicate notes.
     */
    CURSOR  l_notes_csr(p_object_id NUMBER, p_object_type_code VARCHAR2) IS
    SELECT  b.parent_note_id,
            b.jtf_note_id  ,
            t.notes        ,
            b.note_status  ,
            b.attribute1   ,
            b.attribute2   ,
            b.attribute3   ,
            b.attribute4   ,
            b.attribute5   ,
            b.attribute6   ,
            b.attribute7   ,
            b.attribute8   ,
            b.attribute9   ,
            b.attribute10  ,
            b.attribute11  ,
            b.attribute12  ,
            b.attribute13  ,
            b.attribute14  ,
            b.attribute15  ,
            b.context      ,
            b.note_type
       FROM    jtf_notes_b b, jtf_notes_tl t
       WHERE   b.source_object_id  IN
		(select quote_header_id  from aso_quote_headers_all
		 where quote_number = (select quote_number from aso_quote_headers_all
						       where quote_header_id = p_object_id))
      AND   b.source_object_code = p_object_type_code
      AND   b.jtf_note_id = t.jtf_note_id
      AND   t.language = USERENV('LANG');

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Copy_Notes_int;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
        L_API_VERSION,
        p_api_version,
        L_API_NAME   ,
        G_PKG_NAME
    )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: Begin Copy_Notes()', 1, 'Y');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: old_object_id:          ' || p_old_object_id, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: old_object_type_code:   ' || p_old_object_type_code, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: new_object_id:          ' || p_new_object_id, 1, 'N');
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: new_object_type_code:   ' || p_new_object_type_code, 1, 'N');
    END IF;

    FOR l_note_rec IN l_notes_csr(p_old_object_id, p_old_object_type_code) LOOP

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: l_note_rec.jtf_note_id: ' || l_note_rec.jtf_note_id, 1, 'N');
        END IF;

        l_notes_detail := NULL;
        JTF_Notes_Pub.WriteLobToData(l_note_rec.jtf_note_id, l_notes_detail);

        l_jtf_note_contexts_tab := JTF_NOTES_PUB.jtf_note_contexts_tab_dflt;
	   i:=1;


        JTF_NOTES_PUB.Create_Note(
            p_parent_note_id        => l_note_rec.parent_note_id ,
            p_api_version           => 1.0                       ,
            p_init_msg_list         => FND_API.G_FALSE           ,
            p_commit                => FND_API.G_FALSE           ,
            p_validation_level      => FND_API.G_VALID_LEVEL_NONE,
            x_return_status         => x_return_status           ,
            x_msg_count             => x_msg_count               ,
            x_msg_data              => x_msg_data                ,
            p_source_object_id      => p_new_object_id           ,
            p_source_object_code    => p_new_object_type_code    ,
            p_notes                 => l_note_rec.notes          ,
            p_notes_detail          => l_notes_detail            ,
            p_note_status           => l_note_rec.note_status    ,
            p_entered_by            => FND_Global.USER_ID        ,
            p_entered_date          => l_sysdate                 ,
            x_jtf_note_id           => l_jtf_note_id             ,
            p_last_update_date      => l_sysdate                 ,
            p_last_updated_by       => FND_Global.USER_ID        ,
            p_creation_date         => l_sysdate                 ,
            p_attribute1            => l_note_rec.attribute1     ,
            p_attribute2            => l_note_rec.attribute2     ,
            p_attribute3            => l_note_rec.attribute3     ,
            p_attribute4            => l_note_rec.attribute4     ,
            p_attribute5            => l_note_rec.attribute5     ,
            p_attribute6            => l_note_rec.attribute6     ,
            p_attribute7            => l_note_rec.attribute7     ,
            p_attribute8            => l_note_rec.attribute8     ,
            p_attribute9            => l_note_rec.attribute9     ,
            p_attribute10           => l_note_rec.attribute10    ,
            p_attribute11           => l_note_rec.attribute11    ,
            p_attribute12           => l_note_rec.attribute12    ,
            p_attribute13           => l_note_rec.attribute13    ,
            p_attribute14           => l_note_rec.attribute14    ,
            p_attribute15           => l_note_rec.attribute15    ,
            p_context               => l_note_rec.context        ,
            p_note_type             => l_note_rec.note_type      ,
            p_jtf_note_contexts_tab => l_jtf_note_contexts_tab
        );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: l_jtf_note_id:          ' || l_jtf_note_id, 1, 'N');
        END IF;

    END LOOP;

    -- End of API body.
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_NOTES_INT: Copy_Notes_copy_quote: End Copy_Notes_copy_quote()', 1, 'Y');
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

     -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

END Copy_Notes_copy_quote;


END ASO_NOTES_INT;

/
