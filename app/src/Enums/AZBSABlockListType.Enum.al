// ------------------------------------------------------------------------------------------------
// Copyright (c) Simon "SimonOfHH" Fischer. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
enum 89007 "AZBSA Block List Type"
{
    Extensible = false;

    value(0; committed)
    {
        Caption = 'committed';
    }
    value(1; uncommitted)
    {
        Caption = 'uncommitted';
    }
    value(2; all)
    {
        Caption = 'all';
    }
}