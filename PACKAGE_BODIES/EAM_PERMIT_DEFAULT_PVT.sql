--------------------------------------------------------
--  DDL for Package Body EAM_PERMIT_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PERMIT_DEFAULT_PVT" AS
/* $Header: EAMVWPDB.pls 120.0.12010000.3 2010/04/26 07:49:48 vboddapa noship $ */

/******************************************************************
* Procedure     : Populate_Null_Columns
* Purpose       : This procedure will look at the columns that the user
                  has not filled in and will assign those columns a
                  value from the old record.This procedure is not called for CREATE
********************************************************************/


PROCEDURE Populate_Null_Columns
     		  ( p_eam_wp_rec         IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
          , p_old_eam_wp_rec     IN  EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
          , x_eam_wp_rec         OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
          ) IS

BEGIN

         x_eam_wp_rec:= p_eam_wp_rec;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing null columns prior to update'); END IF;
        IF p_eam_wp_rec.PERMIT_NAME IS NULL OR
                   p_eam_wp_rec.PERMIT_NAME = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.PERMIT_NAME := p_old_eam_wp_rec.PERMIT_NAME;
                END IF;

           IF p_eam_wp_rec.PERMIT_TYPE IS NULL OR
                   p_eam_wp_rec.PERMIT_TYPE = FND_API.G_MISS_NUM
                THEN
                    x_eam_wp_rec.PERMIT_TYPE := p_old_eam_wp_rec.PERMIT_TYPE;
                END IF;

           IF p_eam_wp_rec.DESCRIPTION IS NULL OR
                   p_eam_wp_rec.DESCRIPTION = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.DESCRIPTION := p_old_eam_wp_rec.DESCRIPTION;
                END IF;

           IF p_eam_wp_rec.ORGANIZATION_ID IS NULL OR
                   p_eam_wp_rec.ORGANIZATION_ID = FND_API.G_MISS_NUM
                THEN
                    x_eam_wp_rec.ORGANIZATION_ID := p_old_eam_wp_rec.ORGANIZATION_ID;
                END IF;

           IF p_eam_wp_rec.STATUS_TYPE IS NULL OR
                   p_eam_wp_rec.STATUS_TYPE = FND_API.G_MISS_NUM
                THEN
                    x_eam_wp_rec.STATUS_TYPE := p_old_eam_wp_rec.STATUS_TYPE;
                END IF;

           IF p_eam_wp_rec.VALID_FROM IS NULL OR
                   p_eam_wp_rec.VALID_FROM = FND_API.G_MISS_DATE
                THEN
                    x_eam_wp_rec.VALID_FROM := p_old_eam_wp_rec.VALID_FROM;
                END IF;

           IF p_eam_wp_rec.VALID_TO IS NULL OR
                   p_eam_wp_rec.VALID_TO = FND_API.G_MISS_DATE
                THEN
                    x_eam_wp_rec.VALID_TO := p_old_eam_wp_rec.VALID_TO;
                END IF;

           IF p_eam_wp_rec.COMPLETION_DATE IS NULL OR
                   p_eam_wp_rec.COMPLETION_DATE = FND_API.G_MISS_DATE
                THEN
                    x_eam_wp_rec.COMPLETION_DATE := p_old_eam_wp_rec.COMPLETION_DATE;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE_CATEGORY IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE_CATEGORY = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE_CATEGORY := p_old_eam_wp_rec.ATTRIBUTE_CATEGORY;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE1 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE1 := p_old_eam_wp_rec.ATTRIBUTE1;
                END IF;
           IF p_eam_wp_rec.ATTRIBUTE2 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE2 := p_old_eam_wp_rec.ATTRIBUTE2;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE3 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE3 := p_old_eam_wp_rec.ATTRIBUTE3;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE4 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE4 := p_old_eam_wp_rec.ATTRIBUTE4;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE5 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE5 := p_old_eam_wp_rec.ATTRIBUTE5;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE6 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE6 := p_old_eam_wp_rec.ATTRIBUTE6;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE7 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE7 := p_old_eam_wp_rec.ATTRIBUTE7;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE8 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE8 := p_old_eam_wp_rec.ATTRIBUTE8;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE9 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE9 := p_old_eam_wp_rec.ATTRIBUTE9;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE10 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE10 := p_old_eam_wp_rec.ATTRIBUTE10;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE11 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE11 := p_old_eam_wp_rec.ATTRIBUTE11;
                END IF;

          IF p_eam_wp_rec.ATTRIBUTE12 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE12 := p_old_eam_wp_rec.ATTRIBUTE12;
                END IF;

          IF p_eam_wp_rec.ATTRIBUTE13 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE13 := p_old_eam_wp_rec.ATTRIBUTE13;
                END IF;

          IF p_eam_wp_rec.ATTRIBUTE14 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE14 := p_old_eam_wp_rec.ATTRIBUTE14;
                END IF;

          IF p_eam_wp_rec.ATTRIBUTE15 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE15 := p_old_eam_wp_rec.ATTRIBUTE15;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE16 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE16 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE16 := p_old_eam_wp_rec.ATTRIBUTE16;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE17 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE16 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE16 := p_old_eam_wp_rec.ATTRIBUTE16;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE18 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE18 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE18 := p_old_eam_wp_rec.ATTRIBUTE18;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE19 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE19 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE19 := p_old_eam_wp_rec.ATTRIBUTE19;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE20 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE20 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE20 := p_old_eam_wp_rec.ATTRIBUTE20;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE21 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE21 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE21 := p_old_eam_wp_rec.ATTRIBUTE21;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE22 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE22 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE22 := p_old_eam_wp_rec.ATTRIBUTE22;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE23 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE23 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE23 := p_old_eam_wp_rec.ATTRIBUTE23;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE24 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE24 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE24 := p_old_eam_wp_rec.ATTRIBUTE24;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE25 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE25 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE25 := p_old_eam_wp_rec.ATTRIBUTE25;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE26 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE26 = FND_API.G_MISS_NUM
                THEN
                    x_eam_wp_rec.ATTRIBUTE26 := p_old_eam_wp_rec.ATTRIBUTE26;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE27 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE27 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE27 := p_old_eam_wp_rec.ATTRIBUTE27;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE28 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE28 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE28 := p_old_eam_wp_rec.ATTRIBUTE28;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE29 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE29 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE29 := p_old_eam_wp_rec.ATTRIBUTE29;
                END IF;

           IF p_eam_wp_rec.ATTRIBUTE30 IS NULL OR
                   p_eam_wp_rec.ATTRIBUTE30 = FND_API.G_MISS_CHAR
                THEN
                    x_eam_wp_rec.ATTRIBUTE30 := p_old_eam_wp_rec.ATTRIBUTE30;
           END IF;

          IF p_eam_wp_rec.APPROVED_BY IS NULL OR
                   p_eam_wp_rec.APPROVED_BY = FND_API.G_MISS_NUM
                THEN
                    x_eam_wp_rec.APPROVED_BY := p_old_eam_wp_rec.APPROVED_BY;
                END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Done processing null columns prior update'); END IF;


END Populate_Null_Columns;


END EAM_PERMIT_DEFAULT_PVT ;

/
