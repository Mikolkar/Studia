#include<stdio.h>
#include<stdlib.h>
struct node{
    int value;
    struct node* next;
};
typedef struct node node_t;
void printlist(node_t *head){
    node_t *temporary = head;
    while (temporary != NULL)
    {
        printf("%d " , temporary->value);
        temporary = temporary->next;
    }
    printf("\n");
}
node_t *create_new_note(int value){
    node_t *result = malloc(sizeof(node_t));
        result->value = value;
        result->next = NULL;
        return result;
}
int main(){
    node_t *head;
    node_t *tmp;
    tmp = create_new_note(32);
    head = tmp;
    tmp = create_new_note(8);
    tmp->next = head;
    head = tmp;
    printlist(head);
    return 0;
}