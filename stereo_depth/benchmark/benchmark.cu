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
 * @file    benchmark.cu
 * @author  Alessio Zattoni
 * @date 
 * @brief   Questo file contiene il benchmark del progetto di cross-correlazione con matrici da 32x32 a 512x512
 *
 * ...
 */



#include "benchmark.hpp"


#define MIN_SIZE        32
#define MAX_SIZE        512
#define KERNEL_SIZE_MIN 3
#define KERNEL_SIZE_MAX 11
#define BLOCK_DIM_MIN   8
#define DEV             0
#define ITERATIONS      10


int main()
{
    cudaSetDevice(DEV);
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, DEV);
    
    std::size_t max_thread_per_block = std::sqrt(deviceProp.maxThreadsPerBlock);

    // Benchmark di matrici di dimensioni da MIN_SIZE a MAX_SIZE
    std::string title("\n=============================================================================");
    for (size_t rows_cols = MIN_SIZE; rows_cols <= MAX_SIZE; rows_cols *= 2) {
        for (size_t block_dim_x_y = BLOCK_DIM_MIN; block_dim_x_y <= rows_cols && block_dim_x_y <= max_thread_per_block; block_dim_x_y *= 2) {
            for (size_t kernel_size = KERNEL_SIZE_MIN; kernel_size <= (rows_cols) && kernel_size <= KERNEL_SIZE_MAX; kernel_size += 2) {
                benchmark<uint8_t>(rows_cols, rows_cols, kernel_size, block_dim_x_y, block_dim_x_y, "results/32-512_formats", ITERATIONS);
                std::cout << title + "\n\t\tEND\n" + std::string(title.size(), '=') +  "\n\n";
            }
        }
    }
    
    exit(EXIT_SUCCESS);
}