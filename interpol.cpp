#include<iostream>

using namespace std;

// Pressupoe array ordenado. Pressupoe valores de array linearmente
// distribuidos em relacao ao seu indice para melhor caso

int interpolation_search(int array[], int key, int size, bool verbose){

    int low = 0, hi = size - 1; // Define primeiro subarray como o array inteiro

    while(low <= hi && array[low] <= key && array[hi] >= key){ // As condicoes de parada implicam falha em busca

        if(low == hi){
            if(array[low] == key){ // Se o subarray entrar em colapso e nao localizar a chave o caso eh uma falha
                return low;
            }else{
                return -1;
            }
        }

        int num = hi - low;
        int inv_m = (hi - low)/(array[hi] - array[low]);
        int inferior_diff = key - array[low];

        int pos = inv_m*(inferior_diff) + low; // Redefine posicao de acordo com o algoritmo de busca por interpolacao

        if(array[pos] == key){return pos;} // Verifica se acertou

        if(array[pos] < key){ // Se nao, redefine subarray de acordo com a porcao onde se sabe estar a chave
            low = pos + 1;
        }else{
            hi = pos - 1;
        }

        if(verbose){
            for(int i=low; i < hi; i++){
               cout<<array[i]<<" ";
            }
            cout<<endl;

        }

    }

    return -1;

}

int main(){

    int array[] = {10, 12, 13, 16, 18, 19, 20, 21,
                 22, 23, 24, 33, 35, 42, 47};

    int size = sizeof(array)/sizeof(int);

    int value = interpolation_search(array, 42, size, true);
}
