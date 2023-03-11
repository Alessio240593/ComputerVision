/****************************************************************************
 * Copyright (C) 2022 by Alessio Zattoni                                    *
 *                                                                          *
 * This file is part of CrossCorrelation.                                   *
 *                                                                          *
 *   CrossCorrelation is free software: you can redistribute it and/or      *
 *   modify it under the terms of the GNU Lesser General Public License as  *
 *   published by the Free Software Foundation, either version 3 of the     * 
 *   License, or (at your option) any later version.                        * 
 *                                                                          *
 *   CrossCorrelation is distributed in the hope that it will be            *
 *   useful, but WITHOUT ANY WARRANTY; without even the implied warranty of *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *   GNU Lesser General Public License for more details.                    *
 *                                                                          *
 *   You should have received a copy of the GNU Lesser General Public       *
 *   License along with Box.  If not, see <http://www.gnu.org/licenses/>.   *
 ****************************************************************************/


/**
 * @file main.cpp
 * @author Alessio Zattoni
 * @date 
 *
 * ...
 */

#include "cuda_cross_correlation.cuh"
#include <iostream>
#include <vector>
#include <cstring>

/// Dimensione del kernel
#define KERNEL_SIZE 3
/// Larghezza della matrice sorgente
#define WIDTH 10
/// Altezza della matrice sorgente
#define HEIGHT 3
/// Incremento delle matrici sorgenti (src3 e src4)
#define INC 2

int main()
{
    std::vector<uint8_t> src1{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    };

    std::vector<uint8_t> src2{
        1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
        1, 1, 1, 0, 0, 0, 1, 0, 0, 0,
        1, 1, 1, 1, 1, 1, 0, 0, 0, 0
    };

    std::vector<uint8_t> src3{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
    };

    std::vector<uint8_t> src4{
        1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
        1, 1, 1, 0, 0, 0, 1, 0, 0, 0,
        1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    };

    std::vector<uint8_t> dst_matrix((WIDTH - (KERNEL_SIZE - 1)) * ((HEIGHT + INC) - (KERNEL_SIZE - 1)), 0);

    crossCorrelation<uint8_t>(src3.data(), src4.data(), dst_matrix.data(), KERNEL_SIZE, (HEIGHT + INC), WIDTH);

    // Stampo la matrice src3
    uint8_t  *pSrc = src3.data();
    std::cout << "\n→ src3:\n";
    for (std::size_t i = 0; i < HEIGHT + INC; i++) {
        for (std::size_t j = 0; j < WIDTH; j++) {
            std::cout << +*(pSrc +(i * WIDTH) + j) << " ";
        }
        std::cout <<"\n";
    }

    // Stampo la matrice src4
    pSrc = src4.data();
    std::cout << "\n→ src4:\n";
    for (std::size_t i = 0; i < HEIGHT + INC; i++) {
        for (std::size_t j = 0; j < WIDTH; j++) {
            std::cout << +*(pSrc +(i * WIDTH) + j) << " ";
        }
        std::cout <<"\n";
    }

    // Stampo il risultato della cross correlazione
    pSrc = dst_matrix.data();
    std::cout <<"\n\n→ Risultato argMaxCorrMat src3, src4:\n";
    for (std::size_t i = 0; i < (HEIGHT + INC) - (KERNEL_SIZE - 1); i++) {
        for (std::size_t j = 0; j < WIDTH - (KERNEL_SIZE - 1); j++) {
            std::cout << +*(pSrc + j + (i * (WIDTH - (KERNEL_SIZE - 1)))) << " ";
        }
        std::cout << std::endl;
    }
    
    exit(EXIT_SUCCESS);
}